import 'package:http/http.dart' as http;

import '../../common.dart';
import 'gemini/gemini_service.dart';
import 'model_service.dart';
import 'openai/openai_service.dart';

/// 按 [ModelType] 装配对应的 [ModelService] 实现。
///
/// 各模型所需的 API Key 从的环境配置解析（如 Gemini 取 [geminiKey]）。
///
/// - [type] 目标模型协议类型
/// - [httpClient] HTTP 客户端
ModelService createModelService(
  ModelType type, {
  required http.Client httpClient,
}) {
  switch (type) {
    case ModelType.gemini:
      return GeminiService(apiKey: geminiKey, httpClient: httpClient);
    case ModelType.openai:
      return OpenAiService(
        apiKey: openAiKey,
        baseUrl: openAiBaseUrl,
        httpClient: httpClient,
      );
  }
}
