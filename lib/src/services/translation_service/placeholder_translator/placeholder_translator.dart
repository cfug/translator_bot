import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/translation_chunk_model.dart';
import 'batch_splitter.dart';
import 'translation_applier.dart';
import 'translation_response_parser.dart';

/// 单批翻译函数
///
/// 输入一批格式化后的文本，返回该批翻译完成的译文块列表。
typedef BatchTranslator = Future<List<TranslationChunk>> Function(String input);

/// 译文占位翻译编排器
///
/// 衔接占位之后的两个阶段：分批翻译 与 译文回填。
///
/// - 分批由 [BatchSplitter] 完成
/// - 每批翻译委托给注入的 [BatchTranslator]([PlaceholderTranslator.gemini]
///   工厂将其接到 Gemini `ChatSession` + [TranslationResponseParser]);
/// - 回填由 [TranslationApplier] 完成。
///
/// 进度通过 [onProgress] 回调输出。
class PlaceholderTranslator {
  PlaceholderTranslator({
    required BatchTranslator translateBatch,
    BatchSplitter splitter = const BatchSplitter(),
    TranslationApplier applier = const TranslationApplier(),
    void Function(String message)? onProgress,
  }) : _translateBatch = translateBatch,
       _splitter = splitter,
       _applier = applier,
       _onProgress = onProgress ?? print;

  /// 基于 Gemini `ChatSession` 的编排器
  ///
  /// 把网络调用与 JSON 响应解析包装为 [BatchTranslator]。
  ///
  /// - [chat] 模型会话
  factory PlaceholderTranslator.gemini(
    ChatSession chat, {
    BatchSplitter splitter = const BatchSplitter(),
    TranslationApplier applier = const TranslationApplier(),
    TranslationResponseParser parser = const TranslationResponseParser(),
    void Function(String message)? onProgress,
  }) {
    return PlaceholderTranslator(
      splitter: splitter,
      applier: applier,
      onProgress: onProgress,
      translateBatch: (input) async {
        final response = await chat.sendMessage(Content.text(input));
        return parser.parse(response.text ?? '');
      },
    );
  }

  final BatchTranslator _translateBatch;
  final BatchSplitter _splitter;
  final TranslationApplier _applier;

  /// 进度信息回调
  final void Function(String message) _onProgress;

  /// 翻译并回填
  ///
  /// - [placeholderOriginalLines] 译文 ID 占位修改后的原始行内容
  /// - [translationPlaceholderData] 译文 ID 占位块的数据
  ///
  /// @return 翻译后的文本，`null`: 无译文(无数据或译文为空)
  Future<String?> translate(
    List<String> placeholderOriginalLines,
    List<TranslationChunk> translationPlaceholderData,
  ) async {
    /// 需要分批翻译的文本
    final batchInputTextList = _splitter.split(translationPlaceholderData);

    /// 已翻译完成的占位数据
    final translatedPlaceholderList = <TranslationChunk>[];

    if (batchInputTextList.isNotEmpty) {
      _onProgress('🚀 总共需要翻译的数据：${batchInputTextList.length} 批');

      /// 开始翻译
      for (var i = 0; i < batchInputTextList.length; i++) {
        _onProgress('📄 开始翻译第 ${i + 1} 批数据');
        final batchInputText = batchInputTextList[i];

        /// TODO: 限制最多请求 10 次就暂停 1 分钟
        try {
          final translatedChunk = await _translateBatch(batchInputText);
          translatedPlaceholderList.addAll(translatedChunk);
        } catch (e) {
          throw GenerativeAIException('$e\n');
        }
        _onProgress('✅ 完成翻译第 ${i + 1} 批数据');
      }
    }

    /// 应用翻译结果
    return _applier.apply(placeholderOriginalLines, translatedPlaceholderList);
  }
}
