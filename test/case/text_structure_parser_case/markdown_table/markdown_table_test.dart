import 'package:test/test.dart';

import '../text_structure_utils.dart';
import 'case/markdown_table_case.dart';

void main() {
  group('TextStructureParser :: markdownTable ::', () {
    test('Markdown 表格 基础', () {
      const testCase = CaseMarkdownTable();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });

    test('Markdown 表格（中文）基础', () {
      const testCase = CaseChineseMarkdownTable();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });
  });
}
