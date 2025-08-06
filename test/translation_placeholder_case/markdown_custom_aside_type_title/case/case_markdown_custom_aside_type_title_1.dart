import '../../../mock_uuid.dart';
import '../../case.dart';

class CaseMarkdownCustomAsideTypeTitle1 implements Case {
  /// Markdown 自定义 aside/admonition 语法（存在类型、标题）基础 1
  const CaseMarkdownCustomAsideTypeTitle1();

  @override
  String testText() {
    return '''
:::note Title
TextTextTextText
:::
''';
  }

  @override
  String expectText() {
    return '''
<!-- :::note Title -->
:::note ${MockUuid.translationChunkId}

TextTextTextText

${MockUuid.translationChunkId}

:::
''';
  }
}
