import 'package:test/test.dart';

import '../translation_placeholder_utils.dart';
import 'case/case_markdown_title_1.dart';
import 'case/case_markdown_title_2.dart';
import 'case/case_markdown_title_3.dart';

void main() {
  group('TranslationPlaceholder Case :: markdown_title ::', () {
    test('Markdown 标题基础 1', () {
      const testCase = CaseMarkdownTitle1();
      final result = getPlaceholderOriginalLines(testCase);
      expect(result, testCase.expect());
    });

    test('Markdown 标题基础 2 - 跳过翻译、补充翻译', () {
      const testCase = CaseMarkdownTitle2();
      final result = getPlaceholderOriginalLines(testCase);
      expect(result, testCase.expect());
    });

    test('Markdown 标题基础 3 - 译文无中文的重复防护', () {
      const testCase = CaseMarkdownTitle3();
      final result = getPlaceholderOriginalLines(testCase);
      expect(result, testCase.expect());
    });
  });
}
