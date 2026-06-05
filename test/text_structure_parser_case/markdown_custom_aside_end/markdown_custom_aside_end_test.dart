import 'package:test/test.dart';

import '../text_structure_utils.dart';
import 'case/markdown_custom_aside_end_case.dart';

void main() {
  group('TextStructureParser :: markdownCustomAsideEnd ::', () {
    test('Markdown 自定义 aside（结束） 基础', () {
      const testCase = CaseMarkdownCustomAsideEnd();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });
  });
}
