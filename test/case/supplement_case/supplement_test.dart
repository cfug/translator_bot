import 'package:test/test.dart';

import 'case/case_supplement_append.dart';
import 'case/case_supplement_translated.dart';
import 'supplement_utils.dart';

void main() {
  group('Supplement Case :: 混合文档补充翻译 ::', () {
    test('补充翻译 1 - 完全已译文档', () {
      const testCase = CaseSupplementTranslated();
      final result = getSupplementResult(testCase);
      expect(result, testCase.expectText());
    });

    test('补充翻译 2 - 已译文档中补译新增的未译片段', () {
      const testCase = CaseSupplementAppend();
      final result = getSupplementResult(testCase);
      expect(result, testCase.expectText());
    });
  });
}
