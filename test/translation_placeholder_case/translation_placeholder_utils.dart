import 'package:cfug_translator_bot/src/services/translation_service/reformat_text.dart';
import 'package:cfug_translator_bot/src/services/translation_service/text_structure_parser/text_structure_parser.dart';
import 'package:cfug_translator_bot/src/services/translation_service/translation_placeholder.dart';

import '../mock_uuid.dart';
import 'case.dart';

/// 获取 - 译文 ID 占位修改后的原始行内容
///
/// - [testCase] 需要获取的 Case
///
/// @return  译文 ID 占位修改后的原始行内容
String getPlaceholderOriginalLines(Case testCase) {
  final testText = testCase.testText();

  /// 预处理文本
  final content = ReformatText(testText).all();

  /// 解析文本结构
  final parser = TextStructureParser();
  final structures = parser.parse(content);

  /// 处理译文占位 ID
  final translationPlaceholder = TranslationPlaceholder(MockUuid())
    ..execute(structures);

  /// 译文 ID 占位修改后的原始行内容
  final placeholderOriginalLines = translationPlaceholder
      .placeholderOriginalLines
      .join('\n');

  return placeholderOriginalLines;
}
