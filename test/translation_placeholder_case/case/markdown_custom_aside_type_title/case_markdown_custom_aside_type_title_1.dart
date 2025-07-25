import '../../../mock_uuid.dart';
import '../case.dart';

/// Markdown 自定义 aside/admonition 语法（存在类型、标题）基础 1
class CaseMarkdownCustomAsideTypeTitle1 implements Case {
  @override
  String testDescription() => 'Markdown 自定义 aside/admonition 语法（存在类型、标题）基础 1';

  @override
  String testText() {
    return '''
:::note Title
TextTextTextText
:::
''';
  }

  @override
  String expectData() {
    return '''
<!-- :::note Title -->
:::note ${MockUuid.translationChunkId}

TextTextTextText

${MockUuid.translationChunkId}

:::
''';
  }
}
