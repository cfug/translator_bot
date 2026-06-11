import 'package:test/test.dart';

import '../translation_placeholder_utils.dart';
import 'case/case_top_metadata_1.dart';
import 'case/case_top_metadata_2.dart';
import 'case/case_top_metadata_3.dart';
import 'case/case_top_metadata_list_item_1.dart';

void main() {
  group('TranslationPlaceholder Case :: top_metadata ::', () {
    test('顶部元数据基础 1', () {
      const testCase = CaseTopMetadata1();
      final result = getPlaceholderOriginalLines(testCase);
      expect(result, testCase.expectText());
    });

    test('顶部元数据基础 2 - 已存在 AI 翻译标记', () {
      const testCase = CaseTopMetadata2();
      final result = getPlaceholderOriginalLines(testCase);
      expect(result, testCase.expectText());
    });

    test('顶部元数据基础 3 - 块内补充翻译', () {
      const testCase = CaseTopMetadata3();
      final result = getPlaceholderOriginalLines(testCase);
      expect(result, testCase.expectText());
    });

    test('顶部元数据带列表项 1', () {
      const testCase = CaseTopMetadataListItem1();
      final result = getPlaceholderOriginalLines(testCase);
      expect(result, testCase.expectText());
    });
  });
}
