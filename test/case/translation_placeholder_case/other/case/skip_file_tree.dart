import '../../case.dart';

/// 跳过 FileTree 组件
class SkipFileTree implements Case {
  const SkipFileTree();

  @override
  String testText() {
    return '''
<FileTree>

- my_flutter/
   - .ios/
   - Flutter/
      - podhelper.rb
- MyApp/
   - Podfile

</FileTree>
''';
  }

  @override
  String expectText() {
    return '''
<FileTree>

- my_flutter/
   - .ios/
   - Flutter/
      - podhelper.rb
- MyApp/
   - Podfile

</FileTree>
''';
  }
}
