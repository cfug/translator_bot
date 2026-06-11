import 'package:test/test.dart';

import '../text_structure_utils.dart';
import 'case/mdx_component_file_tree_case.dart';

void main() {
  group('TextStructureParser :: mdxComponentFileTree ::', () {
    test('FileTree 整块识别', () {
      const testCase = CaseMdxComponentFileTree();
      expect(getCaseStructures(testCase), testCase.expectStructures());
    });
  });
}
