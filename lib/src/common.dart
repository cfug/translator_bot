import 'dart:io';

/// 获取环境变量
///
/// 还可以通过在根目录创建 `.env` 来创建环境变量
String? _envFileTokenOrEnvironment({required String key}) {
  final envFile = File('.env');
  if (envFile.existsSync()) {
    final env = <String, String>{};
    for (final line in envFile.readAsLinesSync().map((line) => line.trim())) {
      if (line.isEmpty || line.startsWith('#')) continue;
      final split = line.indexOf('=');
      env[line.substring(0, split).trim()] = line.substring(split + 1).trim();
    }
    return env[key];
  } else {
    return Platform.environment[key];
  }
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

class Logger {
  void log(String message) {
    print(message);
  }
}
