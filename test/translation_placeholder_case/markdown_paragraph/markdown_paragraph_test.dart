import 'package:test/test.dart';

import '../translation_placeholder_utils.dart';
import 'case/case_markdown_paragraph_1.dart';
import 'case/case_markdown_paragraph_2.dart';

void main() {
  group('TranslationPlaceholder Case :: markdown_paragraph ::', () {
    test('Markdown 段落基础 1', () {
      const testCase = CaseMarkdownParagraph1();
      final result = getPlaceholderOriginalLines(testCase);
      expect(result, testCase.expectText());
    });

    test('Markdown 段落基础 2 - 跳过翻译、补充翻译', () {
      const testCase = CaseMarkdownParagraph2();
      final result = getPlaceholderOriginalLines(testCase);
      expect(result, testCase.expectText());
    });
  });
}
