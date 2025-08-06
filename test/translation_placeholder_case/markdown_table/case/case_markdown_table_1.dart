import '../../../mock_uuid.dart';
import '../../case.dart';

class CaseMarkdownTable1 implements Case {
  /// Markdown 表格基础 1
  const CaseMarkdownTable1();

  @override
  String testText() {
    return '''
| Title | Title |
| --- | --- |
| Text | Text |
| Text | Text |
''';
  }

  @override
  String expectText() {
    return '''
|<t>Title</t><t>${MockUuid.translationChunkId}</t>|<t>Title</t><t>${MockUuid.translationChunkId}</t>|
| --- | --- |
| Text | Text |
|${MockUuid.translationChunkId}|${MockUuid.translationChunkId}|
| Text | Text |
|${MockUuid.translationChunkId}|${MockUuid.translationChunkId}|
''';
  }
}
