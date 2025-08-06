import '../../../mock_uuid.dart';
import '../../case.dart';

class CaseMarkdownListItem1 implements Case {
  /// Markdown 列表项基础 1
  const CaseMarkdownListItem1();

  @override
  String testText() {
    return '''
- Demo 1
- Demo 2
- Demo 3

- Demo 1
  - Demo 1.1
  - Demo 1.2
- Demo 2
- Demo 3


分割

* Demo 1
* Demo 2
* Demo 3

* Demo 1
  * Demo 1.1
  * Demo 1.2
* Demo 2
* Demo 3


分割

1. Demo 1
1. Demo 2
1. Demo 3

1. Demo 1
  1. Demo 1.1
  1. Demo 1.2
1. Demo 2
1. Demo 3


分割

1. Demo 1
2. Demo 2
3. Demo 3

1. Demo 1
  1. Demo 1.1
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

${MockUuid.translationChunkId}

- Demo 3

${MockUuid.translationChunkId}

- Demo 1

${MockUuid.translationChunkId}

  - Demo 1.1

${MockUuid.translationChunkId}

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

${MockUuid.translationChunkId}

* Demo 3

${MockUuid.translationChunkId}

* Demo 1

${MockUuid.translationChunkId}

  * Demo 1.1

${MockUuid.translationChunkId}

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

${MockUuid.translationChunkId}

1. Demo 3

${MockUuid.translationChunkId}

1. Demo 1

${MockUuid.translationChunkId}

  1. Demo 1.1

${MockUuid.translationChunkId}

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

${MockUuid.translationChunkId}

3. Demo 3

${MockUuid.translationChunkId}

1. Demo 1

${MockUuid.translationChunkId}

  1. Demo 1.1

${MockUuid.translationChunkId}

  2. Demo 1.2

${MockUuid.translationChunkId}

2. Demo 2

${MockUuid.translationChunkId}

3. Demo 3

${MockUuid.translationChunkId}
''';
  }
}
