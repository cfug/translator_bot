import '../../../mock_uuid.dart';
import '../../case.dart';

class CaseMarkdownTitle2 implements Case {
  /// Markdown 标题基础 2 - 跳过翻译、补充翻译
  const CaseMarkdownTitle2();

  @override
  String testText() {
    return '''
# Demo 1
## Demo 2

## 测试

### Demo 3

# 测试
''';
  }

  @override
  String expectText() {
    return '''
# Demo 1

# ${MockUuid.translationChunkId}

## Demo 2

## 测试

### Demo 3

### ${MockUuid.translationChunkId}

# 测试
''';
  }
}
