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

    test('段落（英文为主夹少量中文术语）', () {
      const testCase = CaseEnglishParagraphWithChineseTerm();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });
  });
}
