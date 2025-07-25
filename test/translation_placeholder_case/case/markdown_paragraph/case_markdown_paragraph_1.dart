import '../../../mock_uuid.dart';
import '../case.dart';

/// Markdown 段落基础 1
class CaseMarkdownParagraph1 implements Case {
  @override
  String testDescription() => 'Markdown 段落基础 1';

  @override
  String testText() {
    return '''
More thoughts about performance 1
What is performance, and why is performance important 1

More thoughts about performance 2
What is performance, and why is performance important 2
''';
  }

  @override
  String expectData() {
    return '''
More thoughts about performance 1
What is performance, and why is performance important 1

${MockUuid.translationChunkId}

More thoughts about performance 2
What is performance, and why is performance important 2

${MockUuid.translationChunkId}
''';
  }
}
