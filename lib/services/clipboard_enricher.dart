import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:isar/isar.dart';
import 'package:flutter/foundation.dart'; // Needed for compute()
import '../models/clipboard_item.dart';
import 'summarizer_engine.dart';

// 🧠 TOP-LEVEL ISOLATE FUNCTION
// This runs on a separate CPU thread to prevent UI freezing during heavy NLP math
String? _generateSummaryInIsolate(Map<String, dynamic> args) {
  try {
    final text = args['text'] as String;
    final title = args['title'] as String?;

    final engine = SummarizerEngine(
      metadataWeights: const MetadataWeightConfig(defaultWeight: 2.0),
    );

    final result = engine.summarize(
      text: text,
      metadata: title != null ? {'title': title} : null,
      compressionRatio: 0.05, // Use the lowest possible ratio
    );

    if (result.bulletSummary.isNotEmpty) {
      // 🧠 STRICT LIMIT: Force the engine to only return the 3 highest-scoring sentences!
      final bestSentences = result.bulletSummary.take(3).toList();
      return bestSentences.map((b) => '• $b').join('\n\n');
    }
  } catch (e) {
    return null;
  }
  return null;
}

class ClipboardEnricher {
  static const Duration _youtubeTimeout = Duration(seconds: 3);
  static const Duration _fetchTimeout = Duration(seconds: 5);
  static const int _maxContextualImages = 3;
  static const int _minArticleLength = 100;
  static const int _summarizeThreshold = 500;

  static Future<void> enrichItem(Isar isar, int itemId) async {
    try {
      final item = await isar.clipboardItems.get(itemId);
      if (item == null || item.contentType != 'url' || item.isSensitive) return;

      String url = item.content.trim();
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      final uri = Uri.tryParse(url);
      if (uri == null) return;

      String favicon =
          'https://www.google.com/s2/favicons?domain=${uri.host}&sz=128';
      String? pageTitle;
      String? cleanArticleText;
      String? heroImageUrl;
      String? summaryData;
      List<String> extractedImages = [];
      List<String> extractedPdfs = [];

      // 🧠 1. THE DIRECT PDF FAST-PATH
      if (uri.path.toLowerCase().endsWith('.pdf')) {
        extractedPdfs.add(url);
        pageTitle = uri.pathSegments.last;
      } else if (uri.host.contains('youtube.com') ||
          uri.host.contains('youtu.be')) {
        try {
          final oembedUrl = Uri.parse(
            'https://www.youtube.com/oembed?url=$url&format=json',
          );
          final response = await http.get(oembedUrl).timeout(_youtubeTimeout);
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            pageTitle = data['title'];
            heroImageUrl = data['thumbnail_url'];
          }
        } catch (e) {
          debugPrint("YouTube enrichment failed: $e");
        }
      } else {
        try {
          final response = await http
              .get(
                uri,
                headers: {
                  'User-Agent':
                      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)',
                },
              )
              .timeout(_fetchTimeout);

          if (response.statusCode == 200) {
            final document = html_parser.parse(response.body);

            pageTitle =
                document
                    .querySelector('meta[property="og:title"]')
                    ?.attributes['content'] ??
                document.querySelector('title')?.text.trim();

            heroImageUrl =
                document
                    .querySelector('meta[property="og:image"]')
                    ?.attributes['content'] ??
                document
                    .querySelector('meta[name="twitter:image"]')
                    ?.attributes['content'];

            document.querySelectorAll('a').forEach((a) {
              final href = a.attributes['href'];
              if (href != null &&
                  href.toLowerCase().split('?').first.endsWith('.pdf')) {
                String absolutePdf = href.startsWith('//')
                    ? '${uri.scheme}:$href'
                    : href.startsWith('/')
                    ? '${uri.scheme}://${uri.host}$href'
                    : href.startsWith('http')
                    ? href
                    : '${uri.scheme}://${uri.host}/$href';
                extractedPdfs.add(absolutePdf);
              }
            });
            extractedPdfs = extractedPdfs.toSet().toList();

            // 🧠 2. SURGICAL SCRAPING (The Britannica Fix)
            // Destroy absolutely everything that isn't core content
            final selectorsToNuke = [
              'nav',
              'footer',
              'header',
              'aside',
              'script',
              'style',
              'noscript',
              'iframe',
              'form',
              'button',
              '.ad',
              '.ads',
              '.advertisement',
              '.social-share',
              '.newsletter',
              '.cookie-banner',
              '.menu',
              '.sidebar',
              '.comments',
              '.related-posts',
              '.author-bio',
              '[role="navigation"]',
              '[role="banner"]',
              '[role="complementary"]',
              '[id*="menu"]',
              '[class*="menu"]',
            ];
            document
                .querySelectorAll(selectorsToNuke.join(', '))
                .forEach((e) => e.remove());

            var articleNode =
                document.querySelector('article') ??
                document.querySelector('main') ??
                document.querySelector('[role="main"]') ??
                document.body;

            if (articleNode != null) {
              articleNode.querySelectorAll('img').forEach((img) {
                final src = img.attributes['src'] ?? img.attributes['data-src'];
                if (src != null) {
                  String absoluteUrl = src.startsWith('//')
                      ? '${uri.scheme}:$src'
                      : src.startsWith('/')
                      ? '${uri.scheme}://${uri.host}$src'
                      : src;
                  if (absoluteUrl.startsWith('http')) {
                    final lowerUrl = absoluteUrl.toLowerCase();
                    if (!lowerUrl.endsWith('.svg') &&
                        !lowerUrl.contains('logo') &&
                        !lowerUrl.contains('icon') &&
                        !lowerUrl.contains('avatar') &&
                        absoluteUrl != heroImageUrl) {
                      extractedImages.add(absoluteUrl);
                    }
                  }
                }
              });

              extractedImages = extractedImages.toSet().toList();
              if (extractedImages.length > _maxContextualImages) {
                extractedImages = extractedImages.sublist(
                  0,
                  _maxContextualImages,
                );
              }

              // 🧠 3. THE BEAUTIFYING AGENT
              // Force headings to uppercase and add bullets to lists before extracting text
              articleNode.querySelectorAll('h1, h2, h3, h4').forEach((h) {
                h.text = '\n\n${h.text.trim().toUpperCase()}\n\n';
              });
              articleNode.querySelectorAll('li').forEach((li) {
                li.text = '\n• ${li.text.trim()}';
              });
              articleNode.querySelectorAll('p, div, section').forEach((p) {
                p.append(html_parser.parseFragment('\n\n'));
              });

              String rawText = articleNode.text;
              rawText = rawText.replaceAll(
                RegExp(r'\bAdvertisement\b', caseSensitive: false),
                '',
              );
              rawText = rawText.replaceAll(
                RegExp(r'\bRead more:.*', caseSensitive: false),
                '',
              );
              rawText = rawText.replaceAll(RegExp(r'[ \t]+'), ' ');

              cleanArticleText = rawText
                  .replaceAll(RegExp(r'\n\s*\n+'), '\n\n')
                  .trim();

              if (cleanArticleText!.length < _minArticleLength) {
                cleanArticleText = null;
              } else if (cleanArticleText!.length > _summarizeThreshold) {
                summaryData = await compute(_generateSummaryInIsolate, {
                  'text': cleanArticleText,
                  'title': pageTitle,
                });
              }
            }
          }
        } catch (e) {
          debugPrint("Enricher failed to scrape $url: $e");
        }
      }

      await isar.writeTxn(() async {
        final latestItem = await isar.clipboardItems.get(itemId);
        if (latestItem != null) {
          latestItem.faviconUrl = favicon;
          if (pageTitle != null) latestItem.title = pageTitle;
          if (cleanArticleText != null)
            latestItem.articleText = cleanArticleText;
          if (heroImageUrl != null) latestItem.heroImageUrl = heroImageUrl;
          if (extractedImages.isNotEmpty)
            latestItem.contextualImages = extractedImages;
          if (summaryData != null) latestItem.generatedSummary = summaryData;
          if (extractedPdfs.isNotEmpty) latestItem.attachedPdfs = extractedPdfs;
          await isar.clipboardItems.put(latestItem);
        }
      });
    } catch (e) {
      debugPrint("Critical error in ClipboardEnricher: $e");
    }
  }
}
