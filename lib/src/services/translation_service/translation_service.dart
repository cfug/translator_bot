import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';

import 'placeholder_translator/placeholder_translator.dart';
import 'reformat_text/reformat_text.dart';
import 'text_structure_parser/text_structure_parser.dart';
import 'translation_placeholder/translation_placeholder.dart';

/// 翻译服务
///
/// 串联翻译流水线的各阶段:
///
/// 1. [ReformatText] 预处理 →
/// 2. [TextStructureParser] 解析文本结构 →
/// 3. [TranslationPlaceholder] 插入译文 ID 占位 →
/// 4. [PlaceholderTranslator] 分批翻译并回填。
///
/// 各阶段为独立、可单测的模块,本类只负责把它们编排起来。
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
    final content = ReformatText().run(text);

    /// 解析文本结构
    final parser = TextStructureParser();
    final structures = parser.parse(content);

    /// 处理译文占位 ID
    final translationPlaceholder = TranslationPlaceholder(const Uuid())
      ..execute(structures);

    /// 分批翻译并回填译文
    final translatedText = await PlaceholderTranslator.gemini(chat).translate(
      translationPlaceholder.placeholderOriginalLines,
      translationPlaceholder.translationPlaceholderData,
    );

    return translatedText ?? text;
  }
}
