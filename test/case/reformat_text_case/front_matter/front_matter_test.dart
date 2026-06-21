import 'package:test/test.dart';

import '../reformat_text_utils.dart';
import 'case/front_matter_case.dart';

void main() {
  group('ReformatText :: frontMatter ::', () {
    test('顶部元数据空行过滤', () {
      const testCase = CaseFrontMatterBlankLines();
      expect(getCaseText(testCase), testCase.expectText());
    });

    test('顶部元数据 YAML 列表（all 顺序契约）', () {
      const testCase = CaseFrontMatterYamlList();
      expect(getCaseText(testCase), testCase.expectText());
    });
  });
}
