import 'package:test/test.dart';

import '../text_structure_utils.dart';
import 'case/markdown_title_case.dart';

void main() {
  group('TextStructureParser :: markdownTitle ::', () {
    test('Markdown 标题 基础', () {
      const testCase = CaseMarkdownTitle();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });

    test('Markdown 标题（中文）基础', () {
      const testCase = CaseChineseMarkdownTitle();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });
  });
}
