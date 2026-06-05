import 'package:test/test.dart';

import '../text_structure_utils.dart';
import 'case/markdown_horizontal_rule_case.dart';

void main() {
  group('TextStructureParser :: markdownHorizontalRule ::', () {
    test('Markdown 分割线 基础', () {
      const testCase = CaseMarkdownHorizontalRule();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });
  });
}
