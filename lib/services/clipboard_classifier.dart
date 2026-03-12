class ClipboardClassifier {
  // --- SENSITIVE DATA FIREWALL ---
  static final RegExp _creditCardRegExp = RegExp(r'\b(?:\d[ -]*?){13,16}\b');
  static final RegExp _apiKeyRegExp = RegExp(
    r'\b(?:AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35})\b',
  );
  static final RegExp _passwordHeuristic = RegExp(
    r'(password|secret|api_key)\s*[:=]',
  );

  static bool isSensitive(String text) {
    if (_creditCardRegExp.hasMatch(text)) return true;
    if (_apiKeyRegExp.hasMatch(text)) return true;
    if (_passwordHeuristic.hasMatch(text.toLowerCase())) return true;
    return false;
  }

  // --- CONTENT TYPE DETECTION ---

  // UPGRADED URL REGEX: Now accepts query parameters (?, =, &), port numbers, and hashes.
  static final RegExp _urlRegExp = RegExp(
    r'^(https?:\/\/)?([\w\-]+(\.[\w\-]+)+)([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?$',
    caseSensitive: false,
  );

  static final RegExp _codeRegExp = RegExp(
    r'(\b(func|function|class|void|import|export|const|let|var|Widget)\b)|([{};=])',
  );

  static String determineContentType(String text) {
    String trimmed = text.trim();

    // 1. Is it a URL? (Must not have spaces in the middle of it)
    if (!trimmed.contains(' ') && _urlRegExp.hasMatch(trimmed)) {
      return 'url';
    }

    // 2. Is it a block of code?
    if (trimmed.split('\n').length > 1 &&
        _codeRegExp.allMatches(trimmed).length > 3) {
      return 'code';
    }

    // 3. Default fallback
    return 'text';
  }
}
