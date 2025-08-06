import '../../../mock_uuid.dart';
import '../../case.dart';

class CaseMarkdownTitle1 implements Case {
  /// Markdown 标题基础 1
  const CaseMarkdownTitle1();

  @override
  String testText() {
    return '''
# Demo 1
## Demo 2
### Demo 3
''';
  }

  @override
  String expectText() {
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
