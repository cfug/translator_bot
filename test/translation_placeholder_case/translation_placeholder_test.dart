import 'package:test/test.dart';

import 'package:cfug_translator_bot/src/services/translation_service/reformat_text.dart';
import 'package:cfug_translator_bot/src/services/translation_service/text_structure_parser.dart';
import 'package:cfug_translator_bot/src/services/translation_service/translation_placeholder.dart';

import '../mock_uuid.dart';
import 'case/case_data.dart';

void main() {
  group('TranslationPlaceholder :: case ::', () {
    /// Case 数据
    final caseDataAll = caseDataList;

    for (final caseData in caseDataAll) {
      final testDescription = caseData.testDescription();
      final testText = caseData.testText();
      final expectData = caseData.expectData();

      test(testDescription, () {
        /// 译文 ID 占位修改后的原始行内容
        final placeholderOriginalLines = getPlaceholderOriginalLines(testText);
        expect(placeholderOriginalLines, expectData);
      });
    }
  });
}

/// 获取 - 译文 ID 占位修改后的原始行内容
///
/// - [text] 原文数据
///
/// @return  译文 ID 占位修改后的原始行内容
String getPlaceholderOriginalLines(String text) {
  /// 预处理文本
  final content = ReformatText(text).all();

  /// 解析文本结构
  final structures = TextStructureParser.parse(content);

  /// 处理译文占位 ID
  final translationPlaceholder = TranslationPlaceholder(MockUuid())
    ..execute(structures);

  /// 译文 ID 占位修改后的原始行内容
  final placeholderOriginalLines = translationPlaceholder
      .placeholderOriginalLines
      .join('\n');

  return placeholderOriginalLines;
}
