import 'package:test/test.dart';

import '../translation_placeholder_utils.dart';
import 'case/case_markdown_title_1.dart';
import 'case/case_markdown_title_2.dart';

void main() {
  group('TranslationPlaceholder Case :: markdown_title ::', () {
    test('Markdown 标题基础 1', () {
      const testCase = CaseMarkdownTitle1();
      final result = getPlaceholderOriginalLines(testCase);
      expect(result, testCase.expectText());
    });

    test('Markdown 标题基础 2 - 跳过翻译、补充翻译', () {
      const testCase = CaseMarkdownTitle2();
      final result = getPlaceholderOriginalLines(testCase);
      expect(result, testCase.expectText());
    });
  });
}
