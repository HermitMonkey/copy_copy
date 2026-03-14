// ============================================================================
// summarizer_engine.dart
//
// A pure-Dart, zero-dependency text summarization engine with:
//   1.  Pre-processing pipeline (HTML strip, dedup, normalize, list handling)
//   2.  Metadata-aware scoring
//   3.  Section-aware summarization
//   4.  Multiple output modes (bullets, paragraph, headline, structured)
//   5.  Compression-ratio control
//   6.  TF-IDF keyword / bi-gram keyphrase extraction
//   7.  Readability & stats output
//   8.  Chunked processing for large documents (>50 000 chars)
//   9.  Language-hint stopword support (en, fr, hi, de, es)
//  10.  Flutter SummaryCard widget helper (see summary_card.dart)
//
// Author : HermitMonkey
// License: MIT
// ============================================================================

import 'dart:math' as math;

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// The desired output format for a summary.
enum SummaryMode {
  /// A list of key sentences rendered as bullet points.
  bullets,

  /// A single coherent paragraph.
  paragraph,

  /// The single most-important sentence (TL;DR).
  headline,

  /// A rich map containing text summary, metadata highlights, word count,
  /// and compression ratio.
  structured,
}

// ---------------------------------------------------------------------------
// Data classes
// ---------------------------------------------------------------------------

/// Statistics about a summarization run.
class SummaryStats {
  /// Number of words in the original document.
  final int originalWordCount;

  /// Number of words in the produced summary.
  final int summaryWordCount;

  /// Ratio of summary length to original length (0.0 – 1.0).
  final double compressionRatio;

  /// Estimated minutes to read the original at 200 WPM.
  final double originalReadingTimeMinutes;

  /// Estimated minutes to read the summary at 200 WPM.
  final double summaryReadingTimeMinutes;

  /// Minutes saved by reading the summary instead.
  final double readingTimeSavedMinutes;

  /// The top-5 keywords extracted from the document.
  final List<String> topKeywords;

  const SummaryStats({
    required this.originalWordCount,
    required this.summaryWordCount,
    required this.compressionRatio,
    required this.originalReadingTimeMinutes,
    required this.summaryReadingTimeMinutes,
    required this.readingTimeSavedMinutes,
    required this.topKeywords,
  });

  @override
  String toString() =>
      'SummaryStats(original=$originalWordCount words, summary=$summaryWordCount words, '
      'ratio=${(compressionRatio * 100).toStringAsFixed(1)}%, '
      'saved=${readingTimeSavedMinutes.toStringAsFixed(1)} min)';
}

/// The complete result of a summarization call.
class SummaryResult {
  /// A paragraph-form summary.
  final String paragraphSummary;

  /// Bullet-point summary sentences.
  final List<String> bulletSummary;

  /// Single most-important sentence.
  final String headline;

  /// Rich structured output including metadata highlights.
  final Map<String, dynamic> structuredSummary;

  /// Per-section summaries if section headers were detected; otherwise `null`.
  final Map<String, String>? sectionSummaries;

  /// Statistics about the summarization.
  final SummaryStats stats;

  /// Top-N keywords / keyphrases sorted by relevance.
  final List<String> keywords;

  const SummaryResult({
    required this.paragraphSummary,
    required this.bulletSummary,
    required this.headline,
    required this.structuredSummary,
    this.sectionSummaries,
    required this.stats,
    required this.keywords,
  });
}

// ---------------------------------------------------------------------------
// Stopword lists (hardcoded for portability)
// ---------------------------------------------------------------------------

/// Hardcoded stopword sets keyed by ISO 639-1 language code.
class StopwordLists {
  StopwordLists._();

  static const Map<String, Set<String>> _lists = {
    'en': _english,
    'fr': _french,
    'hi': _hindi,
    'de': _german,
    'es': _spanish,
  };

  /// Returns the stopword set for [lang], falling back to English.
  static Set<String> forLanguage(String lang) =>
      _lists[lang.toLowerCase()] ?? _english;

  // English -----------------------------------------------------------------
  static const Set<String> _english = {
    'a',
    'an',
    'the',
    'and',
    'or',
    'but',
    'in',
    'on',
    'at',
    'to',
    'for',
    'of',
    'with',
    'by',
    'from',
    'is',
    'are',
    'was',
    'were',
    'be',
    'been',
    'being',
    'have',
    'has',
    'had',
    'do',
    'does',
    'did',
    'will',
    'would',
    'could',
    'should',
    'may',
    'might',
    'shall',
    'can',
    'this',
    'that',
    'these',
    'those',
    'it',
    'its',
    'i',
    'me',
    'my',
    'we',
    'our',
    'you',
    'your',
    'he',
    'him',
    'his',
    'she',
    'her',
    'they',
    'them',
    'their',
    'what',
    'which',
    'who',
    'whom',
    'where',
    'when',
    'how',
    'not',
    'no',
    'nor',
    'as',
    'if',
    'then',
    'than',
    'so',
    'just',
    'also',
    'very',
    'too',
    'only',
    'about',
    'up',
    'out',
    'into',
    'over',
    'after',
    'before',
    'between',
    'under',
    'above',
    'such',
    'each',
    'every',
    'all',
    'any',
    'both',
    'few',
    'more',
    'most',
    'other',
    'some',
    'many',
    'much',
    'own',
    'same',
    'well',
    'back',
    'even',
    'still',
    'new',
    'now',
    'old',
    'first',
    'last',
    'long',
    'great',
    'little',
    'already',
  };

  // French ------------------------------------------------------------------
  static const Set<String> _french = {
    'le',
    'la',
    'les',
    'un',
    'une',
    'des',
    'du',
    'de',
    'et',
    'ou',
    'mais',
    'en',
    'dans',
    'sur',
    'pour',
    'par',
    'avec',
    'ce',
    'cette',
    'ces',
    'il',
    'elle',
    'ils',
    'elles',
    'je',
    'tu',
    'nous',
    'vous',
    'on',
    'qui',
    'que',
    'quoi',
    'dont',
    'où',
    'ne',
    'pas',
    'plus',
    'moins',
    'très',
    'aussi',
    'être',
    'avoir',
    'faire',
    'dire',
    'aller',
    'voir',
    'savoir',
    'pouvoir',
    'vouloir',
    'tout',
    'tous',
    'toute',
    'toutes',
    'autre',
    'autres',
    'même',
    'son',
    'sa',
    'ses',
    'mon',
    'ma',
    'mes',
    'ton',
    'ta',
    'tes',
    'notre',
    'votre',
    'leur',
    'leurs',
  };

  // Hindi (transliterated) --------------------------------------------------
  static const Set<String> _hindi = {
    'ka',
    'ki',
    'ke',
    'ko',
    'se',
    'me',
    'ne',
    'hai',
    'hain',
    'tha',
    'thi',
    'the',
    'ye',
    'wo',
    'is',
    'us',
    'ek',
    'aur',
    'par',
    'ho',
    'ja',
    'kya',
    'nahi',
    'bhi',
    'koi',
    'kuch',
    'sab',
    'yeh',
    'woh',
    'hum',
    'tum',
    'ap',
    'mera',
    'tera',
    'uska',
    'iske',
    'unke',
    'jab',
    'tab',
    'ab',
    'phir',
    'lekin',
    'magar',
    'ya',
    'to',
    'hi',
    'tak',
  };

  // German ------------------------------------------------------------------
  static const Set<String> _german = {
    'der',
    'die',
    'das',
    'ein',
    'eine',
    'und',
    'oder',
    'aber',
    'in',
    'auf',
    'an',
    'zu',
    'für',
    'von',
    'mit',
    'aus',
    'bei',
    'nach',
    'über',
    'vor',
    'ist',
    'sind',
    'war',
    'waren',
    'sein',
    'haben',
    'hat',
    'hatte',
    'wird',
    'werden',
    'kann',
    'können',
    'soll',
    'sollen',
    'muss',
    'müssen',
    'darf',
    'dürfen',
    'ich',
    'du',
    'er',
    'sie',
    'es',
    'wir',
    'ihr',
    'Sie',
    'mein',
    'dein',
    'unser',
    'euer',
    'nicht',
    'kein',
    'auch',
    'noch',
    'schon',
    'nur',
    'sehr',
    'wie',
    'was',
    'wer',
    'wo',
    'wann',
    'warum',
    'wenn',
    'als',
    'da',
    'so',
    'dann',
    'doch',
    'mal',
    'ja',
    'nein',
    'hier',
    'dort',
    'jetzt',
    'immer',
    'nie',
    'alle',
    'dieser',
    'jener',
    'welcher',
    'jeder',
    'mancher',
    'solcher',
  };

  // Spanish -----------------------------------------------------------------
  static const Set<String> _spanish = {
    'el',
    'la',
    'los',
    'las',
    'un',
    'una',
    'unos',
    'unas',
    'y',
    'o',
    'pero',
    'en',
    'de',
    'del',
    'al',
    'a',
    'por',
    'para',
    'con',
    'sin',
    'sobre',
    'entre',
    'es',
    'son',
    'fue',
    'ser',
    'estar',
    'ha',
    'han',
    'hay',
    'tiene',
    'tener',
    'hacer',
    'haber',
    'poder',
    'decir',
    'ir',
    'ver',
    'dar',
    'saber',
    'querer',
    'yo',
    'tú',
    'él',
    'ella',
    'nosotros',
    'vosotros',
    'ellos',
    'ellas',
    'usted',
    'ustedes',
    'me',
    'te',
    'se',
    'nos',
    'le',
    'les',
    'lo',
    'mi',
    'tu',
    'su',
    'nuestro',
    'vuestro',
    'que',
    'cual',
    'quien',
    'donde',
    'cuando',
    'como',
    'no',
    'ni',
    'si',
    'más',
    'menos',
    'muy',
    'también',
    'ya',
    'aún',
    'todo',
    'toda',
    'todos',
    'todas',
    'otro',
    'otra',
    'otros',
    'otras',
    'este',
    'esta',
    'estos',
    'estas',
    'ese',
    'esa',
    'esos',
    'esas',
    'aquel',
    'aquella',
  };
}

// ---------------------------------------------------------------------------
// Pre-processing pipeline
// ---------------------------------------------------------------------------

/// Cleans and normalises raw input text before summarization.
class TextPreprocessor {
  TextPreprocessor._();

  /// Master entry point — runs the full pipeline on [raw] and returns a list
  /// of clean, deduplicated sentences.
  static List<String> process(String raw) {
    String text = raw;
    text = _stripHtml(text);
    text = _decodeHtmlEntities(text);
    text = _normalizeUnicode(text);
    text = _handleLists(text);
    text = _collapseWhitespace(text);
    List<String> sentences = splitSentences(text);
    sentences = _deduplicateSentences(sentences);
    sentences = _truncateLongSentences(sentences);
    sentences = sentences.where((s) => s.trim().length > 2).toList();
    return sentences;
  }

  // -- HTML / XML tag stripping ---------------------------------------------
  static final RegExp _htmlTagRe = RegExp(r'<[^>]*>', multiLine: true);

  static String _stripHtml(String text) => text.replaceAll(_htmlTagRe, ' ');

  // -- HTML entity decoding -------------------------------------------------
  static const Map<String, String> _entities = {
    '&amp;': '&',
    '&lt;': '<',
    '&gt;': '>',
    '&quot;': '"',
    '&nbsp;': ' ',
    '&#39;': "'",
    '&apos;': "'",
  };

  static String _decodeHtmlEntities(String text) {
    String out = text;
    _entities.forEach((entity, replacement) {
      out = out.replaceAll(entity, replacement);
    });
    // Numeric entities: &#123; or &#x1F;
    out = out.replaceAllMapped(
      RegExp(r'&#(\d+);'),
      (m) => String.fromCharCode(int.parse(m.group(1)!)),
    );
    out = out.replaceAllMapped(
      RegExp(r'&#x([0-9a-fA-F]+);'),
      (m) => String.fromCharCode(int.parse(m.group(1)!, radix: 16)),
    );
    return out;
  }

  // -- Unicode normalisation ------------------------------------------------
  static String _normalizeUnicode(String text) {
    return text
        .replaceAll('\u2018', "'") // left single curly quote
        .replaceAll('\u2019', "'") // right single curly quote
        .replaceAll('\u201C', '"') // left double curly quote
        .replaceAll('\u201D', '"') // right double curly quote
        .replaceAll('\u2013', '-') // en-dash
        .replaceAll('\u2014', ' - ') // em-dash
        .replaceAll('\u2026', '...') // ellipsis
        .replaceAll('\u00A0', ' ') // non-breaking space
        .replaceAll('\u200B', ''); // zero-width space
  }

  // -- List detection & joining --------------------------------------------
  static final RegExp _listItemRe = RegExp(
    r'^[\s]*([-*•]|\d+[.)]|[a-zA-Z][.)]) ',
    multiLine: true,
  );

  /// Converts bullet / numbered list lines into proper sentences by
  /// stripping the list marker, capitalising, and ensuring a period.
  static String _handleLists(String text) {
    final lines = text.split('\n');
    final buffer = StringBuffer();
    for (final line in lines) {
      final trimmed = line.trim();
      if (_listItemRe.hasMatch(trimmed)) {
        String item = trimmed
            .replaceFirst(RegExp(r'^([-*•]|\d+[.)]|[a-zA-Z][.)]) '), '')
            .trim();
        if (item.isEmpty) continue;
        // Capitalise first letter.
        item = item[0].toUpperCase() + item.substring(1);
        // Ensure trailing period.
        if (!RegExp(r'[.!?]$').hasMatch(item)) item += '.';
        buffer.write('$item ');
      } else {
        buffer.write('$trimmed ');
      }
    }
    return buffer.toString();
  }

  // -- Whitespace collapse --------------------------------------------------
  static String _collapseWhitespace(String text) =>
      text.replaceAll(RegExp(r'\s+'), ' ').trim();

  // -- Sentence splitting ---------------------------------------------------
  /// Known abbreviations that should NOT trigger a sentence split.
  static final Set<String> _abbreviations = {
    'mr',
    'mrs',
    'ms',
    'dr',
    'prof',
    'sr',
    'jr',
    'st',
    'vs',
    'etc',
    'inc',
    'ltd',
    'co',
    'corp',
    'dept',
    'est',
    'approx',
    'govt',
    'gen',
    'sgt',
    'cpl',
    'pvt',
    'capt',
    'col',
    'lt',
    'cmdr',
    'adm',
    'maj',
    'rev',
    'e.g',
    'i.e',
    'fig',
    'vol',
    'no',
    'op',
    'ed',
    'al',
  };

  /// Splits [text] into individual sentences with awareness of abbreviations,
  /// decimal numbers, and ellipses.
  static List<String> splitSentences(String text) {
    final List<String> results = [];
    // Regex: split on `.` / `!` / `?` (possibly followed by quotes) when followed by
    // whitespace and an uppercase letter or end-of-string.
    // We process character-by-character for robustness.
    final buffer = StringBuffer();
    final chars = text.codeUnits;
    for (int i = 0; i < chars.length; i++) {
      final c = String.fromCharCode(chars[i]);
      buffer.write(c);

      if (c == '!' || c == '?') {
        // Definite sentence end (unless inside quotes, which we approximate).
        _flushBuffer(buffer, results);
        continue;
      }

      if (c == '.') {
        // Check for ellipsis `...`
        if (i + 2 < chars.length && chars[i + 1] == 46 && chars[i + 2] == 46) {
          buffer.write('..');
          i += 2;
          _flushBuffer(buffer, results);
          continue;
        }

        // Check for decimal number: digit.digit
        if (i > 0 &&
            i + 1 < chars.length &&
            _isDigit(chars[i - 1]) &&
            _isDigit(chars[i + 1])) {
          continue; // Not a sentence boundary.
        }

        // Check for abbreviation
        final wordBefore = _wordBeforeDot(buffer.toString());
        if (wordBefore != null &&
            _abbreviations.contains(wordBefore.toLowerCase())) {
          continue; // Abbreviation — not a boundary.
        }

        // Check for U.S.-style abbreviations (single letter followed by dot)
        if (wordBefore != null && wordBefore.length == 1) {
          continue;
        }

        // Otherwise, treat as sentence end.
        _flushBuffer(buffer, results);
      }
    }
    // Flush remaining text.
    _flushBuffer(buffer, results);
    return results;
  }

  static void _flushBuffer(StringBuffer buffer, List<String> results) {
    final s = buffer.toString().trim();
    if (s.isNotEmpty) results.add(s);
    buffer.clear();
  }

  static bool _isDigit(int code) => code >= 48 && code <= 57;

  static String? _wordBeforeDot(String text) {
    // Text includes the trailing dot; we want the word just before it.
    final stripped = text.substring(0, text.length - 1).trim();
    if (stripped.isEmpty) return null;
    final parts = stripped.split(RegExp(r'\s+'));
    return parts.last;
  }

  // -- Near-duplicate removal (Jaccard > 0.8) --------------------------------
  static List<String> _deduplicateSentences(List<String> sentences) {
    final List<String> unique = [];
    for (final sentence in sentences) {
      final words = _wordSet(sentence);
      bool isDup = false;
      for (final existing in unique) {
        final existingWords = _wordSet(existing);
        if (_jaccard(words, existingWords) > 0.8) {
          isDup = true;
          break;
        }
      }
      if (!isDup) unique.add(sentence);
    }
    return unique;
  }

  static Set<String> _wordSet(String sentence) => sentence
      .toLowerCase()
      .split(RegExp(r'\W+'))
      .where((w) => w.isNotEmpty)
      .toSet();

  static double _jaccard(Set<String> a, Set<String> b) {
    if (a.isEmpty && b.isEmpty) return 1.0;
    final intersection = a.intersection(b).length;
    final union = a.union(b).length;
    return union == 0 ? 0.0 : intersection / union;
  }

  // -- Long-sentence truncation (> 60 words) --------------------------------
  static const int _maxWordsPerSentence = 60;
  static final RegExp _clauseBreakRe = RegExp(
    r'[,;:\-]|\band\b|\bbut\b|\bor\b|\bwhich\b|\bthat\b|\bbecause\b|\bhowever\b',
    caseSensitive: false,
  );

  static List<String> _truncateLongSentences(List<String> sentences) {
    final List<String> result = [];
    for (final sentence in sentences) {
      final words = sentence.split(RegExp(r'\s+'));
      if (words.length <= _maxWordsPerSentence) {
        result.add(sentence);
        continue;
      }
      // Find the last clause-break position within the first 60 words.
      final truncated = words.take(_maxWordsPerSentence).join(' ');
      final matches = _clauseBreakRe.allMatches(truncated).toList();
      if (matches.isNotEmpty) {
        final lastBreak = matches.last;
        String clause = truncated.substring(0, lastBreak.start).trim();
        if (!RegExp(r'[.!?]$').hasMatch(clause)) clause += '.';
        result.add(clause);
      } else {
        result.add('$truncated.');
      }
    }
    return result;
  }
}

// ---------------------------------------------------------------------------
// Keyword / keyphrase extraction
// ---------------------------------------------------------------------------

/// Extracts keywords (single-word) and keyphrases (bi-gram) from text using
/// a TF-IDF–like scoring approach.
class KeywordExtractor {
  KeywordExtractor._();

  /// Returns the top [n] keywords/keyphrases from [sentences], excluding
  /// words in [stopwords].
  static List<String> extract({
    required List<String> sentences,
    required Set<String> stopwords,
    int n = 10,
  }) {
    final int totalSentences = sentences.length;
    if (totalSentences == 0) return [];

    // ---- Single-word TF-IDF -----------------------------------------------
    final Map<String, int> termFreq = {};
    final Map<String, int> sentenceFreq = {};
    int totalTerms = 0;

    for (final sentence in sentences) {
      final words = _tokenize(sentence);
      final seenInSentence = <String>{};
      for (final w in words) {
        if (stopwords.contains(w) || w.length < 2) continue;
        termFreq[w] = (termFreq[w] ?? 0) + 1;
        totalTerms++;
        seenInSentence.add(w);
      }
      for (final w in seenInSentence) {
        sentenceFreq[w] = (sentenceFreq[w] ?? 0) + 1;
      }
    }

    final Map<String, double> tfidf = {};
    termFreq.forEach((word, tf) {
      final df = sentenceFreq[word] ?? 1;
      final idf = math.log((totalSentences + 1) / (df + 1)) + 1.0;
      tfidf[word] = (tf / math.max(totalTerms, 1)) * idf;
    });

    // ---- Bi-gram keyphrases -----------------------------------------------
    final Map<String, int> bigramFreq = {};
    final Map<String, int> bigramSentenceFreq = {};

    for (final sentence in sentences) {
      final words = _tokenize(
        sentence,
      ).where((w) => !stopwords.contains(w) && w.length >= 2).toList();
      final seenBigrams = <String>{};
      for (int i = 0; i < words.length - 1; i++) {
        final bigram = '${words[i]} ${words[i + 1]}';
        bigramFreq[bigram] = (bigramFreq[bigram] ?? 0) + 1;
        seenBigrams.add(bigram);
      }
      for (final bg in seenBigrams) {
        bigramSentenceFreq[bg] = (bigramSentenceFreq[bg] ?? 0) + 1;
      }
    }

    final Map<String, double> bigramScores = {};
    bigramFreq.forEach((bigram, count) {
      if (count < 2) return; // Only consider bi-grams appearing 2+ times.
      final parts = bigram.split(' ');
      final avg = ((tfidf[parts[0]] ?? 0) + (tfidf[parts[1]] ?? 0)) / 2.0;
      final cooccurrenceBonus = count >= 3 ? 1.5 : 1.0;
      bigramScores[bigram] = avg * cooccurrenceBonus;
    });

    // ---- Merge and rank ---------------------------------------------------
    final Map<String, double> combined = {...tfidf};
    bigramScores.forEach((bigram, score) {
      combined[bigram] = score * 1.2; // Slight preference for phrases.
    });

    final sorted = combined.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(n).map((e) => e.key).toList();
  }

  static List<String> _tokenize(String text) => text
      .toLowerCase()
      .split(RegExp(r'\W+'))
      .where((w) => w.isNotEmpty)
      .toList();
}

// ---------------------------------------------------------------------------
// Core summarizer engine
// ---------------------------------------------------------------------------

/// Configuration for metadata key boost weights.
class MetadataWeightConfig {
  /// A map from metadata key name to its boost multiplier (1.0 – 3.0).
  /// Keys not listed default to [defaultWeight].
  final Map<String, double> weights;

  /// Fallback weight for metadata keys not present in [weights].
  final double defaultWeight;

  const MetadataWeightConfig({
    this.weights = const {},
    this.defaultWeight = 1.5,
  });
}

/// The main summarization engine.
///
/// Usage:
/// ```dart
/// final engine = SummarizerEngine();
/// final result = engine.summarize(
///   text: longDocument,
///   metadata: {'indication': 'diabetes', 'phase': 'Phase III'},
///   compressionRatio: 0.2,
///   topN: 10,
///   languageHint: 'en',
/// );
/// print(result.headline);
/// ```
class SummarizerEngine {
  /// Configures per-key boost multipliers for metadata-aware scoring.
  final MetadataWeightConfig metadataWeights;

  /// Creates a new [SummarizerEngine] with optional [metadataWeights].
  SummarizerEngine({this.metadataWeights = const MetadataWeightConfig()});

  // ---- Chunked processing constants --------------------------------------
  static const int _chunkThreshold = 50000;
  static const int _chunkSize = 3000;
  static const int _chunkOverlap = 200;

  // ---- Public API --------------------------------------------------------

  /// Summarizes [text] and returns a complete [SummaryResult].
  ///
  /// * [metadata] — optional key/value pairs whose string values boost
  ///   matching sentences.
  /// * [sectionHeaders] — optional list of expected section titles; if found
  ///   in the text the engine produces per-section summaries.
  /// * [compressionRatio] — target ratio (0.05–0.5, default 0.2).
  /// * [topN] — number of keywords/keyphrases to extract (default 10).
  /// * [languageHint] — ISO 639-1 code for stopword selection (default 'en').
  SummaryResult summarize({
    required String text,
    Map<String, dynamic>? metadata,
    List<String>? sectionHeaders,
    double compressionRatio = 0.2,
    int topN = 10,
    String languageHint = 'en',
  }) {
    // Clamp compression ratio.
    compressionRatio = compressionRatio.clamp(0.05, 0.5);

    final Set<String> stopwords = StopwordLists.forLanguage(languageHint);

    // Check for large-document chunked processing.
    if (text.length > _chunkThreshold) {
      return _chunkedSummarize(
        text: text,
        metadata: metadata,
        sectionHeaders: sectionHeaders,
        compressionRatio: compressionRatio,
        topN: topN,
        stopwords: stopwords,
      );
    }

    return _coreSummarize(
      text: text,
      metadata: metadata,
      sectionHeaders: sectionHeaders,
      compressionRatio: compressionRatio,
      topN: topN,
      stopwords: stopwords,
    );
  }

  // ---- Convenience: single-mode output -----------------------------------

  /// Summarizes and returns only the output for [mode].
  dynamic summarizeAs({
    required String text,
    required SummaryMode mode,
    Map<String, dynamic>? metadata,
    List<String>? sectionHeaders,
    double compressionRatio = 0.2,
    int topN = 10,
    String languageHint = 'en',
  }) {
    final result = summarize(
      text: text,
      metadata: metadata,
      sectionHeaders: sectionHeaders,
      compressionRatio: compressionRatio,
      topN: topN,
      languageHint: languageHint,
    );
    switch (mode) {
      case SummaryMode.bullets:
        return result.bulletSummary;
      case SummaryMode.paragraph:
        return result.paragraphSummary;
      case SummaryMode.headline:
        return result.headline;
      case SummaryMode.structured:
        return result.structuredSummary;
    }
  }

  // ---- Core summarization logic ------------------------------------------

  SummaryResult _coreSummarize({
    required String text,
    Map<String, dynamic>? metadata,
    List<String>? sectionHeaders,
    required double compressionRatio,
    required int topN,
    required Set<String> stopwords,
  }) {
    final int originalWordCount = _wordCount(text);

    // Pre-process.
    final List<String> sentences = TextPreprocessor.process(text);
    if (sentences.isEmpty) {
      return _emptyResult(originalWordCount, topN);
    }

    // Extract metadata boost terms.
    final Map<String, double> boostTerms = _buildBoostTerms(
      metadata,
      stopwords,
    );

    // Attempt section-aware summarization.
    Map<String, String>? sectionSummaries;
    if (sectionHeaders != null && sectionHeaders.isNotEmpty) {
      sectionSummaries = _sectionSummarize(
        sentences: sentences,
        headers: sectionHeaders,
        boostTerms: boostTerms,
        compressionRatio: compressionRatio,
        stopwords: stopwords,
      );
    }

    // Full-document scoring.
    final scored = _scoreSentences(
      sentences: sentences,
      boostTerms: boostTerms,
      stopwords: stopwords,
      sectionHeaders: sectionHeaders,
    );

    // Select top sentences.
    final int maxSentences = (sentences.length * compressionRatio).ceil().clamp(
      1,
      20,
    );
    final topSentences = _selectTop(scored, maxSentences);

    // Preserve original order for paragraph output.
    final ordered = _preserveOrder(topSentences, sentences);

    // Build outputs.
    final String paragraph = ordered.join(' ');
    final List<String> bullets = List<String>.from(ordered);
    final String headline = topSentences.isNotEmpty ? topSentences.first : '';

    // Keywords.
    final List<String> keywords = KeywordExtractor.extract(
      sentences: sentences,
      stopwords: stopwords,
      n: topN,
    );

    // Stats.
    final int summaryWordCount = _wordCount(paragraph);
    final stats = _buildStats(
      originalWordCount: originalWordCount,
      summaryWordCount: summaryWordCount,
      keywords: keywords,
    );

    // Metadata highlights.
    final List<String> metadataHighlights = _extractMetadataHighlights(
      boostTerms,
      ordered,
    );

    // Structured output.
    final Map<String, dynamic> structured = {
      'summary': paragraph,
      'metadataHighlights': metadataHighlights,
      'wordCount': summaryWordCount,
      'originalWordCount': originalWordCount,
      'compressionRatio': stats.compressionRatio,
      'keywords': keywords.take(5).toList(),
    };

    return SummaryResult(
      paragraphSummary: paragraph,
      bulletSummary: bullets,
      headline: headline,
      structuredSummary: structured,
      sectionSummaries: sectionSummaries,
      stats: stats,
      keywords: keywords,
    );
  }

  // ---- Sentence scoring ---------------------------------------------------

  /// Scored sentence: original text + computed score.
  List<_ScoredSentence> _scoreSentences({
    required List<String> sentences,
    required Map<String, double> boostTerms,
    required Set<String> stopwords,
    List<String>? sectionHeaders,
  }) {
    final int total = sentences.length;
    if (total == 0) return [];

    // Word frequency map (non-stopword).
    final Map<String, int> wordFreq = {};
    for (final s in sentences) {
      for (final w in _tokenize(s)) {
        if (!stopwords.contains(w) && w.length >= 2) {
          wordFreq[w] = (wordFreq[w] ?? 0) + 1;
        }
      }
    }
    final int maxFreq = wordFreq.values.fold(1, (a, b) => a > b ? a : b);

    // Header words for overlap scoring.
    final Set<String> headerWords = {};
    if (sectionHeaders != null) {
      for (final h in sectionHeaders) {
        headerWords.addAll(_tokenize(h));
      }
    }
    headerWords.removeAll(stopwords);

    final List<_ScoredSentence> scored = [];
    for (int i = 0; i < total; i++) {
      final sentence = sentences[i];
      double score = 0.0;

      // 1. Position score: first and last sentences of the document score higher.
      if (i == 0 || i == total - 1) {
        score += 1.5;
      } else if (i < total * 0.2 || i > total * 0.8) {
        score += 0.5;
      }

      // 2. Word frequency score.
      final words = _tokenize(sentence);
      final nonStop = words
          .where((w) => !stopwords.contains(w) && w.length >= 2)
          .toList();
      if (nonStop.isNotEmpty) {
        final freqSum = nonStop.fold<double>(
          0,
          (s, w) => s + (wordFreq[w] ?? 0) / maxFreq,
        );
        score += freqSum / nonStop.length;
      }

      // 3. Metadata boost.
      for (final entry in boostTerms.entries) {
        if (sentence.toLowerCase().contains(entry.key)) {
          score += entry.value;
        }
      }

      // 4. Header overlap.
      if (headerWords.isNotEmpty) {
        final overlap = nonStop.where((w) => headerWords.contains(w)).length;
        score += overlap * 0.3;
      }

      // 5. Sentence-length bell curve: prefer medium length (10–30 words).
      final int len = words.length;
      if (len >= 10 && len <= 30) {
        score += 0.5;
      } else if (len >= 5 && len <= 50) {
        score += 0.2;
      }
      // Very short sentences (< 5 words) get a penalty.
      if (len < 5) {
        score -= 0.3;
      }

      scored.add(_ScoredSentence(sentence, score, i));
    }

    // Sort descending by score.
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored;
  }

  // ---- Section-aware summarization ---------------------------------------

  Map<String, String>? _sectionSummarize({
    required List<String> sentences,
    required List<String> headers,
    required Map<String, double> boostTerms,
    required double compressionRatio,
    required Set<String> stopwords,
  }) {
    // Build a map of section name → sentences.
    final Map<String, List<String>> sections = {};
    String currentSection = '_preamble';
    final headerLower = headers.map((h) => h.toLowerCase()).toSet();

    for (final sentence in sentences) {
      // Check if this sentence IS a section header.
      final sentenceLower = sentence
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
          .trim();
      bool isHeader = false;
      for (final h in headerLower) {
        final hClean = h.replaceAll(RegExp(r'[^a-z0-9 ]'), '').trim();
        if (sentenceLower == hClean || sentenceLower.startsWith(hClean)) {
          currentSection = headers.firstWhere(
            (orig) =>
                orig
                    .toLowerCase()
                    .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
                    .trim() ==
                hClean,
            orElse: () => h,
          );
          isHeader = true;
          break;
        }
      }
      if (isHeader) {
        sections.putIfAbsent(currentSection, () => []);
        continue;
      }
      sections.putIfAbsent(currentSection, () => []);
      sections[currentSection]!.add(sentence);
    }

    // Remove preamble key if empty.
    if (sections['_preamble']?.isEmpty ?? true) sections.remove('_preamble');

    // If we found no real sections, return null to trigger full-doc fallback.
    if (sections.length <= 1 && sections.containsKey('_preamble')) return null;
    if (sections.isEmpty) return null;

    // Summarize each section.
    final Map<String, String> result = {};
    for (final entry in sections.entries) {
      final sectionSentences = entry.value;
      if (sectionSentences.isEmpty) {
        result[entry.key] = '';
        continue;
      }
      final scored = _scoreSentences(
        sentences: sectionSentences,
        boostTerms: boostTerms,
        stopwords: stopwords,
      );
      final int max = (sectionSentences.length * compressionRatio).ceil().clamp(
        1,
        10,
      );
      final top = _selectTop(scored, max);
      final ordered = _preserveOrder(top, sectionSentences);
      result[entry.key] = ordered.join(' ');
    }
    return result;
  }

  // ---- Chunked processing ------------------------------------------------

  SummaryResult _chunkedSummarize({
    required String text,
    Map<String, dynamic>? metadata,
    List<String>? sectionHeaders,
    required double compressionRatio,
    required int topN,
    required Set<String> stopwords,
  }) {
    // Split into overlapping chunks.
    final List<String> chunks = [];
    int start = 0;
    while (start < text.length) {
      final end = math.min(start + _chunkSize, text.length);
      chunks.add(text.substring(start, end));
      start += _chunkSize - _chunkOverlap;
    }

    // First pass: summarize each chunk.
    final List<String> chunkSummaries = [];
    for (final chunk in chunks) {
      final result = _coreSummarize(
        text: chunk,
        metadata: metadata,
        compressionRatio: compressionRatio,
        topN: 5,
        stopwords: stopwords,
      );
      if (result.paragraphSummary.isNotEmpty) {
        chunkSummaries.add(result.paragraphSummary);
      }
    }

    // Second pass: summarize the merged chunk summaries.
    final mergedText = chunkSummaries.join(' ');
    return _coreSummarize(
      text: mergedText.isNotEmpty
          ? mergedText
          : text.substring(0, math.min(text.length, _chunkSize)),
      metadata: metadata,
      sectionHeaders: sectionHeaders,
      compressionRatio: compressionRatio,
      topN: topN,
      stopwords: stopwords,
    );
  }

  // ---- Metadata helpers --------------------------------------------------

  /// Extracts boost terms from [metadata] string values, tokenises them, and
  /// maps each token to its configured weight.
  Map<String, double> _buildBoostTerms(
    Map<String, dynamic>? metadata,
    Set<String> stopwords,
  ) {
    if (metadata == null) return {};
    final Map<String, double> terms = {};
    for (final entry in metadata.entries) {
      if (entry.value is! String) continue;
      final weight =
          metadataWeights.weights[entry.key] ?? metadataWeights.defaultWeight;
      final tokens = _tokenize(entry.value as String);
      for (final t in tokens) {
        if (!stopwords.contains(t) && t.length >= 2) {
          // If the same token appears under multiple keys, take the max weight.
          terms[t] = math.max(terms[t] ?? 0, weight);
        }
      }
      // Also add the raw multi-word value (lowercased) so that phrases like
      // "Phase III" match as a whole.
      final raw = (entry.value as String).toLowerCase().trim();
      if (raw.contains(' ')) {
        terms[raw] = math.max(terms[raw] ?? 0, weight);
      }
    }
    return terms;
  }

  List<String> _extractMetadataHighlights(
    Map<String, double> boostTerms,
    List<String> summarySentences,
  ) {
    if (boostTerms.isEmpty) return [];
    final Set<String> found = {};
    for (final sentence in summarySentences) {
      final lower = sentence.toLowerCase();
      for (final term in boostTerms.keys) {
        if (lower.contains(term)) found.add(term);
      }
    }
    return found.toList()..sort();
  }

  // ---- Utilities ----------------------------------------------------------

  List<String> _selectTop(List<_ScoredSentence> scored, int max) {
    return scored.take(max).map((s) => s.text).toList();
  }

  /// Re-orders [selected] sentences to match their original order in
  /// [allSentences].
  List<String> _preserveOrder(
    List<String> selected,
    List<String> allSentences,
  ) {
    final Set<String> selSet = selected.toSet();
    return allSentences.where((s) => selSet.contains(s)).toList();
  }

  static int _wordCount(String text) =>
      text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

  static List<String> _tokenize(String text) => text
      .toLowerCase()
      .split(RegExp(r'\W+'))
      .where((w) => w.isNotEmpty)
      .toList();

  SummaryStats _buildStats({
    required int originalWordCount,
    required int summaryWordCount,
    required List<String> keywords,
  }) {
    final double ratio = originalWordCount > 0
        ? summaryWordCount / originalWordCount
        : 0.0;
    const double wpm = 200.0;
    final double origTime = originalWordCount / wpm;
    final double sumTime = summaryWordCount / wpm;
    return SummaryStats(
      originalWordCount: originalWordCount,
      summaryWordCount: summaryWordCount,
      compressionRatio: ratio,
      originalReadingTimeMinutes: origTime,
      summaryReadingTimeMinutes: sumTime,
      readingTimeSavedMinutes: origTime - sumTime,
      topKeywords: keywords.take(5).toList(),
    );
  }

  SummaryResult _emptyResult(int originalWordCount, int topN) {
    return SummaryResult(
      paragraphSummary: '',
      bulletSummary: [],
      headline: '',
      structuredSummary: {
        'summary': '',
        'metadataHighlights': <String>[],
        'wordCount': 0,
        'originalWordCount': originalWordCount,
        'compressionRatio': 0.0,
        'keywords': <String>[],
      },
      sectionSummaries: null,
      stats: SummaryStats(
        originalWordCount: originalWordCount,
        summaryWordCount: 0,
        compressionRatio: 0.0,
        originalReadingTimeMinutes: originalWordCount / 200.0,
        summaryReadingTimeMinutes: 0.0,
        readingTimeSavedMinutes: originalWordCount / 200.0,
        topKeywords: [],
      ),
      keywords: [],
    );
  }
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

class _ScoredSentence {
  final String text;
  final double score;
  final int originalIndex;

  const _ScoredSentence(this.text, this.score, this.originalIndex);
}

// ===========================================================================
// USAGE EXAMPLE
// ===========================================================================
//
// void main() {
//   final engine = SummarizerEngine(
//     metadataWeights: MetadataWeightConfig(
//       weights: {
//         'indication': 2.5,
//         'phase': 2.0,
//         'sponsor': 1.5,
//       },
//     ),
//   );
//
//   const document = '''
//   <p>Background: Diabetes affects millions of people worldwide.
//   Roche has initiated a Phase III clinical trial to evaluate a novel
//   treatment for Type 2 diabetes.</p>
//
//   <p>Methods: The study enrolled 5,000 patients across 120 sites in
//   North America, Europe, and Asia. Participants were randomized 1:1
//   to receive either the experimental drug or placebo.</p>
//
//   <p>Results: After 52 weeks of treatment, the experimental group
//   showed a statistically significant reduction in HbA1c levels
//   compared to placebo (p < 0.001). The mean reduction was 1.2%
//   versus 0.3% in the placebo arm.</p>
//
//   <p>Conclusion: This Phase III trial demonstrates that the Roche
//   compound is effective in reducing blood glucose levels in patients
//   with Type 2 diabetes and has an acceptable safety profile.</p>
//   ''';
//
//   final result = engine.summarize(
//     text: document,
//     metadata: {
//       'indication': 'diabetes',
//       'phase': 'Phase III',
//       'sponsor': 'Roche',
//     },
//     sectionHeaders: ['Background', 'Methods', 'Results', 'Conclusion'],
//     compressionRatio: 0.3,
//     topN: 10,
//     languageHint: 'en',
//   );
//
//   print('=== HEADLINE ===');
//   print(result.headline);
//   print('');
//
//   print('=== BULLET SUMMARY ===');
//   for (final bullet in result.bulletSummary) {
//     print('  • $bullet');
//   }
//   print('');
//
//   print('=== PARAGRAPH SUMMARY ===');
//   print(result.paragraphSummary);
//   print('');
//
//   if (result.sectionSummaries != null) {
//     print('=== SECTION SUMMARIES ===');
//     result.sectionSummaries!.forEach((section, summary) {
//       print('  [$section] $summary');
//     });
//     print('');
//   }
//
//   print('=== KEYWORDS ===');
//   print(result.keywords.join(', '));
//   print('');
//
//   print('=== STATS ===');
//   print(result.stats);
//   print('');
//
//   print('=== STRUCTURED OUTPUT ===');
//   result.structuredSummary.forEach((k, v) => print('  $k: $v'));
// }
