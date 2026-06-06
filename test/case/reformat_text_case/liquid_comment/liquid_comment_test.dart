import 'package:test/test.dart';

import '../reformat_text_utils.dart';
import 'case/liquid_comment_case.dart';

void main() {
  group('ReformatText :: liquidComment ::', () {
    test('{% comment %} 块上下补空行', () {
      const testCase = CaseCommentBlock();
      expect(getCaseText(testCase), testCase.expectText());
    });

    test('{%- comment -%} 连字符变体', () {
      const testCase = CaseCommentDashVariant();
      expect(getCaseText(testCase), testCase.expectText());
    });

    test('代码块内 {% comment %} 不处理', () {
      const testCase = CaseCommentInsideCodeBlock();
      expect(getCaseText(testCase), testCase.expectText());
    });
  });
}
