import 'package:test/test.dart';

import '../translation_placeholder_utils.dart';
import 'case/case_markdown_table_1.dart';
import 'case/case_markdown_table_2.dart';

void main() {
  group('TranslationPlaceholder Case :: markdown_table ::', () {
    test('Markdown 表格基础 1', () {
      const testCase = CaseMarkdownTable1();
      final result = getPlaceholderOriginalLines(testCase);
      expect(result, testCase.expectText());
    });

    test('Markdown 表格基础 2 - 跳过翻译', () {
      const testCase = CaseMarkdownTable2();
      final result = getPlaceholderOriginalLines(testCase);
      expect(result, testCase.expectText());
    });
  });
}
