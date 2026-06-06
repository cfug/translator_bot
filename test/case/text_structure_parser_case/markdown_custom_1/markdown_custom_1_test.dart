import 'package:test/test.dart';

import '../text_structure_utils.dart';
import 'case/markdown_custom_1_case.dart';

void main() {
  group('TextStructureParser :: markdownCustom1 ::', () {
    test('Markdown 自定义语法 {:x} 基础', () {
      const testCase = CaseMarkdownCustom1();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });
  });
}
