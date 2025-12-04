import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';

import 'models/translation_chunk_model.dart';
import 'reformat_text.dart';
import 'text_structure_parser/text_structure_parser.dart';
import 'translation_placeholder.dart';

/// 翻译服务
class TranslationService {
  /// 翻译服务
  const TranslationService(this.chat, this.text);

  /// 模型会话
  final ChatSession chat;

  /// 需要处理的原始内容
  final String text;

  /// 运行翻译
  ///
  /// @return 翻译后的文本
  Future<String> run() async {
    /// 预处理文本
    final content = ReformatText(text).all();

    /// 解析文本结构
    final parser = TextStructureParser();
    final structures = parser.parse(content);

    /// 处理译文占位 ID
    final translationPlaceholder = TranslationPlaceholder(const Uuid())
      ..execute(structures);

    /// 译文 ID 占位修改后的原始行内容
    final placeholderOriginalLines =
        translationPlaceholder.placeholderOriginalLines;

    /// 译文 ID 占位块的数据
    final translationPlaceholderData =
        translationPlaceholder.translationPlaceholderData;

    /// 已翻译的译文 ID 占位块数据
    final translatedPlaceholderData = await _translatePlaceholder(
      translationPlaceholderData,
    );

    /// 应用翻译结果
    final translatedText = _applyTranslations(
      placeholderOriginalLines,
      translatedPlaceholderData,
    );

    return translatedText ?? text;
  }

  /// 翻译处理译文 ID 占位块数据
  ///
  /// - [translationPlaceholderData] 译文 ID 占位块的数据
  ///
  /// @return 翻译完成的译文 ID 占位块数据
  Future<List<TranslationChunk>> _translatePlaceholder(
    List<TranslationChunk> translationPlaceholderData,
  ) async {
    /// 最大输入计数（防止输出超出限制）
    const maxInputCount = 10 * 1024;

    /// 需要分批翻译的文本
    final batchInputTextList = <String>[];

    /// 分批次翻译
    /// 处理成 AI 需要输入的格式内容
    var batchText = '';
    for (var i = 0; i < translationPlaceholderData.length; i++) {
      final chunk = translationPlaceholderData[i];
      batchText += _formatChunkInput(chunk);

      /// 分批输入
      if (batchText.length >= maxInputCount ||
          i == translationPlaceholderData.length - 1) {
        if (batchText != '') {
          batchInputTextList.add(batchText);
          batchText = '';
        }
      }
    }

    if (batchInputTextList.isEmpty) return [];

    /// 已翻译完成的占位数据
    final translatedPlaceholderList = <TranslationChunk>[];

    print('🚀 总共需要翻译的数据：${batchInputTextList.length} 批');

    /// 开始翻译
    for (var i = 0; i < batchInputTextList.length; i++) {
      print('📄 开始翻译第 ${i + 1} 批数据');
      final batchInputText = batchInputTextList[i];

      /// TODO: 限制最多请求 10 次就暂停 1 分钟
      try {
        final translatedChunk = await _translateBatch(batchInputText);
        translatedPlaceholderList.addAll(translatedChunk);
      } catch (e) {
        throw GenerativeAIException('$e\n');
      }
      print('✅ 完成翻译第 ${i + 1} 批数据');
    }

    return translatedPlaceholderList;
  }

  /// 格式化分块输入（处理成 AI 需要输入的格式内容）
  ///
  /// - [chunk] 单个需要处理的译文 ID 占位块数据
  ///
  /// @return 格式化后的内容
  String _formatChunkInput(TranslationChunk chunk) {
    return '<INPUT>\n'
        'id: ${chunk.id}\n'
        'indentCount: ${chunk.indentCount}\n'
        'text: ${chunk.text.split('\n').join('\\n')}\n'
        '</INPUT>\n'
        '\n';
  }

  /// 按批次翻译
  ///
  /// - [input] 格式化后的输入 [_formatChunkInput]
  ///
  /// @return 翻译完成的译文 ID 占位块数据
  Future<List<TranslationChunk>> _translateBatch(String input) async {
    final response = await chat.sendMessage(Content.text(input));
    final text = response.text?.trim() ?? '';

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

  /// 应用翻译的结果
  ///
  /// - [placeholderOriginalLines] 译文 ID 占位修改后的原始行内容
  /// - [translatedPlaceholderData] 已翻译完成的译文 ID 占位块数据
  ///
  /// @return 翻译后的文本，`null`: 翻译为空
  String? _applyTranslations(
    List<String> placeholderOriginalLines,
    List<TranslationChunk> translatedPlaceholderData,
  ) {
    if (translatedPlaceholderData.isEmpty) return null;
    var result = placeholderOriginalLines.join('\n');
    for (final chunk in translatedPlaceholderData) {
      final translatedText = chunk.text
          .trim()
          .split('\n')
          .map((line) => '${" " * chunk.indentCount}${line.trim()}')
          .join('\n');
      result = result.replaceAll(chunk.id, translatedText);
    }
    return result;
  }
}
