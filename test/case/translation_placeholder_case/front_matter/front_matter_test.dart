import 'package:test/test.dart';

import '../translation_placeholder_utils.dart';
import 'case/case_front_matter_1.dart';
import 'case/case_front_matter_2.dart';
import 'case/case_front_matter_3.dart';
import 'case/case_front_matter_list_item_1.dart';

void main() {
  group('TranslationPlaceholder Case :: top_metadata ::', () {
    test('顶部元数据基础 1', () {
      const testCase = CaseFrontMatter1();
      final result = getPlaceholderOriginalLines(testCase);
      expect(result, testCase.expect());
    });

    test('顶部元数据基础 2 - 已存在 AI 翻译标记', () {
      const testCase = CaseFrontMatter2();
      final result = getPlaceholderOriginalLines(testCase);
      expect(result, testCase.expect());
    });

    test('顶部元数据基础 3 - 块内补充翻译', () {
      const testCase = CaseFrontMatter3();
      final result = getPlaceholderOriginalLines(testCase);
      expect(result, testCase.expect());
    });

    test('顶部元数据带列表项 1', () {
      const testCase = CaseFrontMatterListItem1();
      final result = getPlaceholderOriginalLines(testCase);
      expect(result, testCase.expect());
    });
  });
}
