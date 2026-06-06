import 'package:test/test.dart';

import '../text_structure_utils.dart';
import 'case/markdown_list_item_case.dart';

void main() {
  group('TextStructureParser :: markdownListItem ::', () {
    test('Markdown 列表项 基础', () {
      const testCase = CaseMarkdownListItem();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });

    test('Markdown 列表项（中文）基础', () {
      const testCase = CaseChineseMarkdownListItem();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });
  });
}
