import 'package:test/test.dart';

import '../text_structure_utils.dart';
import 'case/markdown_custom_2_case.dart';

void main() {
  group('TextStructureParser :: markdownCustom2 ::', () {
    test('Markdown 自定义语法 <?x 基础', () {
      const testCase = CaseMarkdownCustom2();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });
  });
}
