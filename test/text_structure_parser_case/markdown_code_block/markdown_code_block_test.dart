import 'package:test/test.dart';

import '../text_structure_utils.dart';
import 'case/markdown_code_block_case.dart';

void main() {
  group('TextStructureParser :: markdownCodeBlock ::', () {
    test('Markdown 代码块 基础', () {
      const testCase = CaseMarkdownCodeBlock();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });
  });
}
