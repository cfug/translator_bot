import '../../case.dart';

/// FileTree 组件 - 整块识别为单一结构
///
/// `<FileTree> ... </FileTree>` 及其内部的文件树列表应作为一个整体。
class CaseMdxComponentFileTree implements Case {
  const CaseMdxComponentFileTree();

  @override
  String testText() => '''
<FileTree>

- my_flutter/
   - .ios/
   - Flutter/
      - podhelper.rb
- MyApp/
   - Podfile

</FileTree>''';

  @override
  List<String> expectStructures() => const ['mdxComponentFileTree:0-9'];
}
