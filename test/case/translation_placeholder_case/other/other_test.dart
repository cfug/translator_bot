import 'package:test/test.dart';

import '../translation_placeholder_utils.dart';
import 'case/skip_file_tree.dart';
import 'case/skip_paragraph.dart';

void main() {
  group('TranslationPlaceholder Case :: other ::', () {
    test('跳过段落', () {
      const testCase = SkipParagraph();
      final result = getPlaceholderOriginalLines(testCase);
      expect(result, testCase.expectText());
    });

    test('跳过 FileTree', () {
      const testCase = SkipFileTree();
      final result = getPlaceholderOriginalLines(testCase);
      expect(result, testCase.expectText());
    });
  });
}
