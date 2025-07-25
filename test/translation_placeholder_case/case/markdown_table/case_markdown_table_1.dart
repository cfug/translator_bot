import '../../../mock_uuid.dart';
import '../case.dart';

/// Markdown 表格基础 1
class CaseMarkdownTable1 implements Case {
  @override
  String testDescription() => 'Markdown 表格基础 1';

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
  String expectData() {
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
