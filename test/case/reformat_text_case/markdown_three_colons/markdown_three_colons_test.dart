import 'package:test/test.dart';

import '../reformat_text_utils.dart';
import 'case/markdown_three_colons_case.dart';

void main() {
  group('ReformatText :: markdownThreeColons ::', () {
    test(':::块上下补空行', () {
      const testCase = CaseColonsAroundContent();
      expect(getCaseText(testCase), testCase.expectText());
    });

    test('代码块内 ::: 不处理', () {
      const testCase = CaseColonsInsideCodeBlock();
      expect(getCaseText(testCase), testCase.expectText());
    });
  });
}
