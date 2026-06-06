import 'package:test/test.dart';

import '../text_structure_utils.dart';
import 'case/top_metadata_case.dart';

void main() {
  group('TextStructureParser :: topMetadata ::', () {
    test('顶部元数据 基础', () {
      const testCase = CaseTopMetadata();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });

    test('顶部元数据（中文）基础', () {
      const testCase = CaseChineseTopMetadata();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });
  });
}
