import '../../../mock_uuid.dart';
import '../case.dart';

/// Markdown 段落基础 2 - 跳过翻译、补充翻译
class CaseMarkdownParagraph2 implements Case {
  @override
  String testDescription() => 'Markdown 段落基础 1 - 跳过翻译、补充翻译';

  @override
  String testText() {
    return '''
More thoughts about performance 1
What is performance, and why is performance important 1

测试测试测试

More thoughts about performance 2
What is performance, and why is performance important 2
''';
  }

  @override
  String expectData() {
    return '''
More thoughts about performance 1
What is performance, and why is performance important 1

测试测试测试

More thoughts about performance 2
What is performance, and why is performance important 2

${MockUuid.translationChunkId}
''';
  }
}
