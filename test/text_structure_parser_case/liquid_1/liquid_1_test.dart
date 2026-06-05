import 'package:test/test.dart';

import '../text_structure_utils.dart';
import 'case/liquid_1_case.dart';

void main() {
  group('TextStructureParser :: liquid1 ::', () {
    test('Liquid 语法1 基础', () {
      const testCase = CaseLiquid1();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });

    test('Liquid 语法1（中文）基础', () {
      const testCase = CaseChinsesLiquid1();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });
  });
}
