import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

import 'prompts/prompts.dart';

class GeminiService {
  GeminiService({required String apiKey, required http.Client httpClient})
    : _translatorModel = GenerativeModel(
        // TODO(Amos): 之后也许可以换成微调后的模型、
        //             Gemini 1.5 Pro、Gemini 2.5 Pro 效果不错
        model: translatorModel,
        apiKey: apiKey,
        systemInstruction: Content.system(translatorPrompt),
        generationConfig: GenerationConfig(temperature: 0, topP: 0),
        httpClient: httpClient,
      );

  static const String translatorModel = 'models/gemini-2.0-flash';
  static const String startText = '准备完成';
  static const String stopText = '全部输出完毕';

  final GenerativeModel _translatorModel;

  /// 调用 translator 的 prompt
  ///
  /// 捕获异常: [GenerativeAIException].
  Future<String> translator(String prompt) {
    return _query(_translatorModel, prompt);
  }

  /// 调用 translator 分块处理的 prompt
  ///
  /// 捕获异常: [GenerativeAIException].
  ///
  /// @return
  /// - [outputText] 全部输出内容
  /// - [totalTokenCount] 当前消耗的总 Token
  Future<({String outputText, int totalTokenCount})?> translatorChunk(
    String prompt,
  ) {
    return _queryChunk(_translatorModel, prompt);
  }

  /// 单次输出
  Future<String> _query(GenerativeModel model, String prompt) async {
    final response = await model.generateContent([Content.text(prompt)]);
    return (response.text ?? '').trim();
  }

  /// 分块输出
  ///
  /// @return
  /// - [outputText] 全部输出内容
  /// - [totalTokenCount] 当前消耗的总 Token
  Future<({String outputText, int totalTokenCount})?> _queryChunk(
    GenerativeModel model,
    String prompt,
  ) async {
    var text = '';
    final chat = model.startChat();

    /// 开始输出
    final responseStart = await chat.sendMessage(Content.text(prompt));
    if (responseStart.text?.trim() != startText) {
      return null;
    }

    const maxChunk = 50;
    for (var i = 1; i <= maxChunk; i++) {
      print('💬 正在输出: 第 $i 分块');
      final responseNext = await chat.sendMessage(
        Content.text(chunkNextPrompt),
      );
      print('✅ 完成输出: 第 $i 分块');
      final textNext = responseNext.text ?? '';
      if (textNext.trim() == stopText) {
        break;
      }
      text += textNext;
    }

    final countTokensResponse = await model.countTokens(chat.history);

    return (
      outputText: text.trim(),
      totalTokenCount: countTokensResponse.totalTokens,
    );
  }
}
