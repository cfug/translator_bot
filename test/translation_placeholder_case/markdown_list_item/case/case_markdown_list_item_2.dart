import '../../../mock_uuid.dart';
import '../../case.dart';

class CaseMarkdownListItem2 implements Case {
  /// Markdown 列表项基础 2 - 跳过翻译、补充翻译
  const CaseMarkdownListItem2();

  @override
  String testText() {
    return '''
- Demo 1
- Demo 2

- 测试

- Demo 3

- Demo 1
  - Demo 1.1

  - 测试

  - Demo 1.2
- Demo 2
- Demo 3


分割

* Demo 1
* Demo 2

* 测试

* Demo 3

* Demo 1
  * Demo 1.1

  * 测试

  * Demo 1.2
* Demo 2
* Demo 3


分割

1. Demo 1
1. Demo 2

1. 测试

1. Demo 3

1. Demo 1
  1. Demo 1.1

  1. 测试

  1. Demo 1.2
1. Demo 2
1. Demo 3


分割

1. Demo 1
2. Demo 2

2. 测试

3. Demo 3

1. Demo 1
  1. Demo 1.1

  1. 测试

  2. Demo 1.2
2. Demo 2
3. Demo 3
''';
  }

  @override
  String expectText() {
    return '''
- Demo 1

${MockUuid.translationChunkId}

- Demo 2

- 测试

- Demo 3

${MockUuid.translationChunkId}

- Demo 1

${MockUuid.translationChunkId}

  - Demo 1.1

  - 测试

  - Demo 1.2

${MockUuid.translationChunkId}

- Demo 2

${MockUuid.translationChunkId}

- Demo 3

${MockUuid.translationChunkId}


分割

* Demo 1

${MockUuid.translationChunkId}

* Demo 2

* 测试

* Demo 3

${MockUuid.translationChunkId}

* Demo 1

${MockUuid.translationChunkId}

  * Demo 1.1

  * 测试

  * Demo 1.2

${MockUuid.translationChunkId}

* Demo 2

${MockUuid.translationChunkId}

* Demo 3

${MockUuid.translationChunkId}


分割

1. Demo 1

${MockUuid.translationChunkId}

1. Demo 2

1. 测试

1. Demo 3

${MockUuid.translationChunkId}

1. Demo 1

${MockUuid.translationChunkId}

  1. Demo 1.1

  1. 测试

  1. Demo 1.2

${MockUuid.translationChunkId}

1. Demo 2

${MockUuid.translationChunkId}

1. Demo 3

${MockUuid.translationChunkId}


分割

1. Demo 1

${MockUuid.translationChunkId}

2. Demo 2

2. 测试

3. Demo 3

${MockUuid.translationChunkId}

1. Demo 1

${MockUuid.translationChunkId}

  1. Demo 1.1

  1. 测试

  2. Demo 1.2

${MockUuid.translationChunkId}

2. Demo 2

${MockUuid.translationChunkId}

3. Demo 3

${MockUuid.translationChunkId}
''';
  }
}
