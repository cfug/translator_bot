/// 翻译异常
///
/// 各模型适配器应在自身边界把 SDK 专属异常（如 Gemini 的 `GoogleAIException`）映射为本异常。
class TranslationException implements Exception {
  /// 翻译流水线领域异常
  ///
  /// - [message] 错误描述
  /// - [redact] 需要从 [message] 中脱敏的敏感串（如 API key），
  ///   命中处一律替换为 `***`。
  TranslationException(String message, {Iterable<String> redact = const []})
    : message = _redactKnownSecretFields(_redactSecrets(message, redact));

  /// 错误描述（已脱敏）
  final String message;

  /// 把 [message] 中出现的每个非空 [secrets] 替换为 `***`。
  ///
  /// 空串会被跳过，避免把整段文本污染成 `***`。
  static String _redactSecrets(String message, Iterable<String> secrets) {
    var result = message;
    for (final secret in secrets) {
      if (secret.isEmpty) continue;
      result = result.replaceAll(secret, '***');
    }
    return result;
  }

  /// 自动识别错误文本里常见的敏感字段值并替换为 `***`。
  ///
  /// 覆盖 SDK 异常中常见的 URL query、HTTP header 和 JSON 风格字段。
  static String _redactKnownSecretFields(String message) {
    const fieldNames = [
      'key',
      'api_key',
      'apiKey',
      'access_token',
      'accessToken',
      'auth_token',
      'authToken',
      'x-api-key',
      'X-API-Key',
      'token',
      'password',
      'secret',
    ];
    const secretValuePattern = r"""[^\s&;,}\])]+|"[^"]*"|'[^']*'""";
    final fieldPattern = fieldNames.map(RegExp.escape).join('|');
    final secretField = RegExp(
      '((?:$fieldPattern)(?:\\s*[:=]\\s*|=))($secretValuePattern)',
      caseSensitive: false,
    );
    final bearerToken = RegExp(
      r'\b(Bearer\s+)([^\s&;,}\])]+)',
      caseSensitive: false,
    );

    return message
        .replaceAllMapped(secretField, (match) => '${match.group(1)}***')
        .replaceAllMapped(bearerToken, (match) => '${match.group(1)}***');
  }

  @override
  String toString() => 'TranslationException: $message';
}
