import 'package:test/test.dart';

import '../text_structure_utils.dart';
import 'case/html_comment_case.dart';

void main() {
  group('TextStructureParser :: htmlComment ::', () {
    test('HTML 注释 基础', () {
      const testCase = CaseHtmlComment();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });
  });
}
