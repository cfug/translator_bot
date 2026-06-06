import 'package:test/test.dart';

import '../text_structure_utils.dart';
import 'case/markdown_define_link_case.dart';

void main() {
  group('TextStructureParser :: markdownDefineLink ::', () {
    test('Markdown 定义链接 基础', () {
      const testCase = CaseMarkdownDefineLink();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });
  });
}
