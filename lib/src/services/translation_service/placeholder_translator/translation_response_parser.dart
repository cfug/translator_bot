import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/translation_chunk_model.dart';

/// AI 翻译响应解析器
///
/// 把 AI 返回的 JSON 数组文本解析为译文块列表。
/// 空白响应视为无译文返回空列表，非法 JSON 抛出 [GenerativeAIException]。
class TranslationResponseParser {
  const TranslationResponseParser();

  /// 解析 AI 响应文本为译文块列表。
  ///
  /// - [responseText] AI 返回的原始文本(内部会先 `trim`)
  ///
  /// @return 译文块列表(空白响应返回空列表)
  List<TranslationChunk> parse(String responseText) {
    final text = responseText.trim();

    if (text.isEmpty) return [];

    try {
      final jsonList = jsonDecode(text) as List;
      return jsonList.map((value) => TranslationChunk.fromJson(value)).toList();
    } catch (e) {
      throw GenerativeAIException(
        'AI 响应输出的 json 格式处理错误\n'
        '$e\n',
      );
    }
  }
}
