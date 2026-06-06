import 'package:test/test.dart';

import '../text_structure_utils.dart';
import 'case/markdown_custom_aside_type_title_case.dart';

void main() {
  group('TextStructureParser :: markdownCustomAsideTypeTitle ::', () {
    test('Markdown 自定义 aside（类型+标题）基础', () {
      const testCase = CaseMarkdownCustomAsideTypeTitle();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });

    test('Markdown 自定义 aside（类型+标题，中文）基础', () {
      const testCase = CaseChineseMarkdownCustomAsideTypeTitle();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });
  });
}
