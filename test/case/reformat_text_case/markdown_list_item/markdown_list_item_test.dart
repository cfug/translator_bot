import 'package:test/test.dart';

import '../reformat_text_utils.dart';
import 'case/markdown_list_item_case.dart';

void main() {
  group('ReformatText :: markdownListItem ::', () {
    test('段落后紧接列表项', () {
      const testCase = CaseListAfterParagraph();
      expect(getCaseText(testCase), testCase.expectText());
    });

    test('连续列表项', () {
      const testCase = CaseConsecutiveListItems();
      expect(getCaseText(testCase), testCase.expectText());
    });

    test('代码块内列表标记不处理', () {
      const testCase = CaseListInsideCodeBlock();
      expect(getCaseText(testCase), testCase.expectText());
    });
  });
}
