import 'dart:convert';

import '../models/translation_chunk_model.dart';
import '../translation_exception.dart';

class TranslationResponseParser {
  /// AI 翻译响应解析器
  ///
  /// 把 AI 返回的 JSON 文本解析为译文块列表
  ///
  /// 空白响应视为无译文返回空列表，无法解析时抛出 [TranslationException]。
  const TranslationResponseParser();

  /// 对象包数组时优先读取的键名
  static const String _wrappedKey = 'translations';

  /// 解析 AI 响应文本为译文块列表
  ///
  /// - [responseText] AI 返回的原始文本（内部会先 `trim`）
  ///
  /// @return 译文块列表（空白响应返回空列表）
  List<TranslationChunk> parse(String responseText) {
    final text = responseText.trim();

    if (text.isEmpty) return [];

    try {
      final jsonList = _extractList(jsonDecode(text));
      return jsonList.map((value) => TranslationChunk.fromJson(value)).toList();
    } catch (e) {
      throw TranslationException(
        'AI 响应输出的 json 格式处理错误\n'
        '$e\n',
      );
    }
  }

  /// 从解码后的 JSON 中取出译文块数组
  ///
  /// 纯数组直接返回；
  /// 对象则取 [_wrappedKey]，缺失时回退首个数组值；
  /// 都取不到则抛出 [FormatException]（由 [parse] 统一包装）
  List _extractList(Object? decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map) {
      final wrapped = decoded[_wrappedKey];
      if (wrapped is List) return wrapped;
      for (final value in decoded.values) {
        if (value is List) return value;
      }
    }
    throw const FormatException('未找到译文块数组');
  }
}
