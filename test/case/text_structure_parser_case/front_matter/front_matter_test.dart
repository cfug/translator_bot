import 'package:test/test.dart';

import '../text_structure_utils.dart';
import 'case/front_matter_case.dart';

void main() {
  group('TextStructureParser :: frontMatter ::', () {
    test('顶部元数据 基础', () {
      const testCase = CaseFrontMatter();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });

    test('顶部元数据（中文）基础', () {
      const testCase = CaseChineseFrontMatter();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });
  });
}
