import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:isar/isar.dart';
import '../models/clipboard_item.dart';

class ClipboardEnricher {
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

      // --- THE YOUTUBE FAST-PATH ---
      if (uri.host.contains('youtube.com') || uri.host.contains('youtu.be')) {
        try {
          final oembedUrl = Uri.parse(
            'https://www.youtube.com/oembed?url=$url&format=json',
          );
          final response = await http
              .get(oembedUrl)
              .timeout(const Duration(seconds: 3));
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            pageTitle = data['title'];
            heroImageUrl = data['thumbnail_url']; // High-res YT thumbnail
          }
        } catch (e) {
          print("YouTube enrichment failed: $e");
        }
      }
      // --- GENERAL WEB SCRAPING ---
      else {
        try {
          final response = await http
              .get(
                uri,
                headers: {
                  'User-Agent':
                      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                },
              )
              .timeout(const Duration(seconds: 5));

          if (response.statusCode == 200) {
            final document = html_parser.parse(response.body);

            // 1. Scrape Title
            pageTitle =
                document
                    .querySelector('meta[property="og:title"]')
                    ?.attributes['content'] ??
                document.querySelector('title')?.text.trim();

            // 2. Scrape Hero Image (OpenGraph / Twitter Cards)
            heroImageUrl =
                document
                    .querySelector('meta[property="og:image"]')
                    ?.attributes['content'] ??
                document
                    .querySelector('meta[name="twitter:image"]')
                    ?.attributes['content'];

            // 3. Scrape Clean Content
            // Remove noise before extracting text
            document
                .querySelectorAll(
                  'script, style, nav, footer, header, aside, noscript, .ads, .comments',
                )
                .forEach((e) => e.remove());

            var articleNode =
                document.querySelector('article') ??
                document.querySelector('main') ??
                document.querySelector('[role="main"]') ??
                document.body;

            if (articleNode != null) {
              // Convert multiple spaces/newlines into a single clean block for the Magazine View
              cleanArticleText = articleNode.text
                  .replaceAll(RegExp(r'\s+'), ' ')
                  .trim();

              // Only keep if it's substantial
              if (cleanArticleText!.length < 100) cleanArticleText = null;
            }
          }
        } catch (e) {
          print("Enricher failed to scrape $url: $e");
        }
      }

      // Save findings back to Isar
      await isar.writeTxn(() async {
        final latestItem = await isar.clipboardItems.get(itemId);
        if (latestItem != null) {
          latestItem.faviconUrl = favicon;
          if (pageTitle != null) latestItem.title = pageTitle;
          if (cleanArticleText != null)
            latestItem.articleText = cleanArticleText;
          if (heroImageUrl != null) latestItem.heroImageUrl = heroImageUrl;
          await isar.clipboardItems.put(latestItem);
        }
      });
    } catch (e) {
      print("Critical error in ClipboardEnricher: $e");
    }
  }
}
