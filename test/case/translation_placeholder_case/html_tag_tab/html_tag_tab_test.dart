import 'package:test/test.dart';

import '../translation_placeholder_utils.dart';
import 'case/case_html_tag_tab_1.dart';

void main() {
  group('TranslationPlaceholder Case :: html_tag_tab ::', () {
    test('HTML 标签 <Tab name="标题"> 语法基础 1', () {
      const testCase = CaseHtmlTagTab1();
      final result = getPlaceholderOriginalLines(testCase);
      expect(result, testCase.expectText());
    });
  });
}
