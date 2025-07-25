import 'package:cfug_translator_bot/src/services/translation_service/translation_placeholder.dart';

import '../../../mock_uuid.dart';
import '../case.dart';

/// 顶部元数据带列表项 1
class CaseTopMetadataListItem1 implements Case {
  @override
  String testDescription() => '顶部元数据带列表项 1';

  @override
  String testText() {
    return '''
---
title: More thoughts about performance
tag:
  - tag 1
  - tag 2
  - tag 3
description: What is performance, and why is performance important
---
''';
  }

  @override
  String expectData() {
    return '''
---
# title: More thoughts about performance
title: ${MockUuid.translationChunkId}
tag:
  - tag 1
  - tag 2
  - tag 3
# description: What is performance, and why is performance important
description: ${MockUuid.translationChunkId}
---
${TranslationPlaceholder(MockUuid()).translationNote}
''';
  }
}
