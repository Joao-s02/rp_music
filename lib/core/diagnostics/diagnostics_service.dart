enum DiagnosticLevel { debug, info, warning, error }

class DiagnosticLogEntry {
  final DateTime timestamp;
  final DiagnosticLevel level;
  final String category;
  final String message;
  final Map<String, dynamic>? metadata;

  const DiagnosticLogEntry({
    required this.timestamp,
    required this.level,
    required this.category,
    required this.message,
    this.metadata,
  });

  Map<String, dynamic> toJson({bool redactSensitive = true}) {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'category': category,
      'message': redactSensitive ? _redact(message) : message,
      if (metadata != null)
        'metadata': redactSensitive ? _redactMap(metadata!) : metadata,
    };
  }

  static String _redact(String text) {
    // Redact Windows paths (C:\Users\username\...)
    var redacted = text.replaceAllMapped(
      RegExp(r'[a-zA-Z]:\\Users\\[^\\]+\\', caseSensitive: false),
      (match) => r'C:\Users\<redacted>\',
    );
    // Redact Unix home paths (/home/username/ or /Users/username/)
    redacted = redacted.replaceAllMapped(
      RegExp(r'/(?:home|Users)/[^/]+/', caseSensitive: false),
      (match) => '/Users/<redacted>/',
    );
    // Redact sensitive content URIs if containing personal IDs
    redacted = redacted.replaceAllMapped(
      RegExp(r'(content://[^/]+/)([^/?]+)', caseSensitive: false),
      (match) => '${match[1]}<redacted>',
    );
    return redacted;
  }

  static Map<String, dynamic> _redactMap(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    for (final entry in map.entries) {
      if (entry.value is String) {
        result[entry.key] = _redact(entry.value as String);
      } else if (entry.value is Map<String, dynamic>) {
        result[entry.key] = _redactMap(entry.value as Map<String, dynamic>);
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }
}

class DiagnosticsService {
  static final DiagnosticsService _instance = DiagnosticsService._();
  factory DiagnosticsService() => _instance;
  DiagnosticsService._();

  final List<DiagnosticLogEntry> _logs = [];
  final int maxLogs = 500;

  List<DiagnosticLogEntry> get logs => List.unmodifiable(_logs);

  void log(DiagnosticLevel level, String category, String message, [Map<String, dynamic>? metadata]) {
    final entry = DiagnosticLogEntry(
      timestamp: DateTime.now().toUtc(),
      level: level,
      category: category,
      message: message,
      metadata: metadata,
    );
    _logs.add(entry);
    if (_logs.length > maxLogs) {
      _logs.removeAt(0);
    }
  }

  void debug(String category, String message, [Map<String, dynamic>? meta]) =>
      log(DiagnosticLevel.debug, category, message, meta);

  void info(String category, String message, [Map<String, dynamic>? meta]) =>
      log(DiagnosticLevel.info, category, message, meta);

  void warning(String category, String message, [Map<String, dynamic>? meta]) =>
      log(DiagnosticLevel.warning, category, message, meta);

  void error(String category, String message, [Map<String, dynamic>? meta]) =>
      log(DiagnosticLevel.error, category, message, meta);

  List<Map<String, dynamic>> exportLogsJson({bool redactSensitive = true}) {
    return _logs.map((e) => e.toJson(redactSensitive: redactSensitive)).toList();
  }

  void clear() {
    _logs.clear();
  }
}
