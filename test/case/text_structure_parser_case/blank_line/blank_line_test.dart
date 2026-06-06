import 'package:test/test.dart';

import '../text_structure_utils.dart';
import 'case/blank_line_case.dart';

void main() {
  group('TextStructureParser :: blankLine ::', () {
    test('空行 基础', () {
      const testCase = CaseBlankLine();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });
  });
}
