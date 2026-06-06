import 'package:test/test.dart';

import '../translation_placeholder_utils.dart';
import 'case/case_liquid_tab_1.dart';
import 'case/case_liquid_tab_2.dart';

void main() {
  group('TranslationPlaceholder Case :: liquid_tab ::', () {
    test('Liquid {% tab "标题" %} 语法基础 1', () {
      const testCase = CaseLiquidTab1();
      final result = getPlaceholderOriginalLines(testCase);
      expect(result, testCase.expectText());
    });

    test('Liquid {% tab "标题" %} 语法 2 - 跳过翻译', () {
      const testCase = CaseLiquidTab2();
      final result = getPlaceholderOriginalLines(testCase);
      expect(result, testCase.expectText());
    });
  });
}
