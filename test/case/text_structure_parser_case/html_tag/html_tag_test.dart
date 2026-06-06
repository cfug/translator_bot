import 'package:test/test.dart';

import '../text_structure_utils.dart';
import 'case/html_tag_case.dart';

void main() {
  group('TextStructureParser :: htmlTag ::', () {
    test('HTML 标签 基础', () {
      const testCase = CaseHtmlTag();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });
  });
}
