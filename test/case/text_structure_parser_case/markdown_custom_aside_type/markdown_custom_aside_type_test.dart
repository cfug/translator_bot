import 'package:test/test.dart';

import '../text_structure_utils.dart';
import 'case/markdown_custom_aside_type_case.dart';

void main() {
  group('TextStructureParser :: markdownCustomAsideType ::', () {
    test('Markdown 自定义 aside（仅类型） 基础', () {
      const testCase = CaseMarkdownCustomAsideType();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });
  });
}
