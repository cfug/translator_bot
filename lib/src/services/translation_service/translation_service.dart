import 'package:uuid/uuid.dart';

import 'model_session.dart';
import 'placeholder_translator/placeholder_translator.dart';
import 'reformat_text/reformat_text.dart';
import 'text_structure_parser/text_structure_parser.dart';
import 'translation_placeholder/translation_placeholder.dart';

class TranslationService {
  /// 翻译服务
  ///
  /// 串联翻译流水线的各阶段:
  ///
  /// 1. [ReformatText] 预处理文本
  /// 2. [TextStructureParser] 解析文本结构
  /// 3. [TranslationPlaceholder] 插入译文 ID 占位
  /// 4. [PlaceholderTranslator] 分批翻译并回填
  ///
  /// 翻译能力通过注入的 [ModelSession] 提供
  const TranslationService(this.session, this.text);

  /// 模型会话
  final ModelSession session;

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
    final translatedText =
        await PlaceholderTranslator(
          translateBatch: session.translateBatch,
        ).translate(
          translationPlaceholder.placeholderOriginalLines,
          translationPlaceholder.translationPlaceholderData,
        );

    return translatedText ?? text;
  }
}
