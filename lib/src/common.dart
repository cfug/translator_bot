import 'dart:io';

/// 获取环境变量
///
/// 还可以通过在根目录创建 `.env` 来创建环境变量
String? _envFileTokenOrEnvironment({required String key}) {
  final String? value;
  final envFile = File('.env');
  if (envFile.existsSync()) {
    final env = <String, String>{};
    for (final line in envFile.readAsLinesSync().map((line) => line.trim())) {
      if (line.isEmpty || line.startsWith('#')) continue;
      final split = line.indexOf('=');
      env[line.substring(0, split).trim()] = line.substring(split + 1).trim();
    }
    value = env[key];
  } else {
    value = Platform.environment[key];
  }

  /// 空字符串视为 “未设置”：GitHub Action 未填的 input 会注入空内容。
  if (value == null || value.isEmpty) return null;
  return value;
}

String get githubToken {
  final token = _envFileTokenOrEnvironment(key: 'GH_TOKEN');
  if (token == null) {
    throw StateError(
      'Github access token -'
      'GH_TOKEN 环境变量',
    );
  }
  return token;
}

/// Gemini API Key
String get geminiKey {
  final token = _envFileTokenOrEnvironment(key: 'GEMINI_API_KEY');
  if (token == null) {
    throw StateError(
      'Gemini api key -'
      'GEMINI_API_KEY 环境变量',
    );
  }
  return token;
}

/// OpenAI 协议兼容接口的 API Key
String get openAiKey {
  final token = _envFileTokenOrEnvironment(key: 'OPENAI_API_KEY');
  if (token == null) {
    throw StateError(
      'OpenAI api key -'
      'OPENAI_API_KEY 环境变量',
    );
  }
  return token;
}

/// OpenAI 协议兼容接口的 baseUrl
///
/// 默认 OpenAI 官方，
/// 对接 OpenAI 代理/兼容端点时改此环境变量。
String get openAiBaseUrl =>
    _envFileTokenOrEnvironment(key: 'OPENAI_BASE_URL') ??
    'https://api.openai.com/v1';

class Logger {
  void log(String message) {
    print(message);
  }
}
