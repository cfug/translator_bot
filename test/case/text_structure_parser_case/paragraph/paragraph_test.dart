import 'package:test/test.dart';

import '../text_structure_utils.dart';
import 'case/paragraph_case.dart';

void main() {
  group('TextStructureParser :: paragraph ::', () {
    test('段落 基础', () {
      const testCase = CaseParagraph();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });

    test('段落（中文）基础', () {
      const testCase = CaseChineseParagraph();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });
  });
}
