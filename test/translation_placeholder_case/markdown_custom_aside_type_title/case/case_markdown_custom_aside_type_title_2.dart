import '../../../mock_uuid.dart';
import '../../case.dart';

class CaseMarkdownCustomAsideTypeTitle2 implements Case {
  /// Markdown 自定义 aside/admonition 语法（存在类型、标题）基础 2 - 跳过翻译、补充翻译
  const CaseMarkdownCustomAsideTypeTitle2();

  @override
  String testText() {
    return '''
:::note Title
TextTextTextText
:::

:::note 测试

TextTextTextText

文本文本

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

:::note 测试

TextTextTextText

文本文本

:::
''';
  }
}
