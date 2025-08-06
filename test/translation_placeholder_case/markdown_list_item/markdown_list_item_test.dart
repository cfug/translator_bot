import 'package:test/test.dart';

import '../translation_placeholder_utils.dart';
import 'case/case_markdown_list_item_1.dart';
import 'case/case_markdown_list_item_2.dart';

void main() {
  group('TranslationPlaceholder Case :: markdown_list_item ::', () {
    test('Markdown 列表项基础 1', () {
      const testCase = CaseMarkdownListItem1();
      final result = getPlaceholderOriginalLines(testCase);
      expect(result, testCase.expectText());
    });

    test('Markdown 列表项基础 2 - 跳过翻译、补充翻译', () {
      const testCase = CaseMarkdownListItem2();
      final result = getPlaceholderOriginalLines(testCase);
      expect(result, testCase.expectText());
    });
  });
}
