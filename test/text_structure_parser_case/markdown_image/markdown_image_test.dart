import 'package:test/test.dart';

import '../text_structure_utils.dart';
import 'case/markdown_image_case.dart';

void main() {
  group('TextStructureParser :: markdownImage ::', () {
    test('Markdown 图片 基础', () {
      const testCase = CaseMarkdownImage();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });
  });
}
