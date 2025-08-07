import '../../../mock_uuid.dart';
import '../../case.dart';

class CaseMarkdownParagraph3 implements Case {
  /// Markdown 段落基础 3 - 冒号（`:`）转为换行（`<br>`）
  const CaseMarkdownParagraph3();

  @override
  String testText() {
    return '''
More thoughts about performance 1
What is performance, and why is performance important 1

测试测试测试

[Text]
: TextTextText

[Text]
<br> TextTextText


[文本]
<br> 文本

More thoughts about performance 2
What is performance, and why is performance important 2
''';
  }

  @override
  String expectText() {
    return '''
More thoughts about performance 1
What is performance, and why is performance important 1

测试测试测试

[Text]
<br> TextTextText

${MockUuid.translationChunkId}

[Text]
<br> TextTextText

${MockUuid.translationChunkId}


[文本]
<br> 文本

More thoughts about performance 2
What is performance, and why is performance important 2

${MockUuid.translationChunkId}
''';
  }
}
