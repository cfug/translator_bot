import 'package:test/test.dart';

import '../translation_placeholder_utils.dart';
import 'case/case_markdown_custom_aside_type_title_1.dart';
import 'case/case_markdown_custom_aside_type_title_2.dart';

void main() {
  group(
    'TranslationPlaceholder Case :: markdown_custom_aside_type_title ::',
    () {
      test('Markdown 自定义 aside/admonition 语法（存在类型、标题）基础 1', () {
        const testCase = CaseMarkdownCustomAsideTypeTitle1();
        final result = getPlaceholderOriginalLines(testCase);
        expect(result, testCase.expectText());
      });

      test('Markdown 自定义 aside/admonition 语法（存在类型、标题）基础 2 - 跳过翻译、补充翻译', () {
        const testCase = CaseMarkdownCustomAsideTypeTitle2();
        final result = getPlaceholderOriginalLines(testCase);
        expect(result, testCase.expectText());
      });
    },
  );
}
