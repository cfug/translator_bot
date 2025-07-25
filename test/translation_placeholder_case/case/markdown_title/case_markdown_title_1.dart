import '../../../mock_uuid.dart';
import '../case.dart';

/// Markdown 标题基础 1
class CaseMarkdownTitle1 implements Case {
  @override
  String testDescription() => 'Markdown 标题基础 1';

  @override
  String testText() {
    return '''
# Demo 1
## Demo 2
### Demo 3
''';
  }

  @override
  String expectData() {
    return '''
# Demo 1

# ${MockUuid.translationChunkId}

## Demo 2

## ${MockUuid.translationChunkId}

### Demo 3

### ${MockUuid.translationChunkId}
''';
  }
}
