import 'package:cfug_translator_bot/src/services/translation_service/translation_placeholder.dart';

import '../../../mock_uuid.dart';
import '../case.dart';

/// 顶部元数据基础 1
class CaseTopMetadata1 implements Case {
  @override
  String testDescription() => '顶部元数据基础 1';

  @override
  String testText() {
    return '''
---
title: More thoughts about performance
short-title: Text
description: >- 
  What is performance, 
  and why is performance important
---
''';
  }

  @override
  String expectData() {
    return '''
---
# title: More thoughts about performance
title: ${MockUuid.translationChunkId}
# short-title: Text
short-title: ${MockUuid.translationChunkId}
# description: >- 
#   What is performance, 
#   and why is performance important
description: ${MockUuid.translationChunkId}
---
${TranslationPlaceholder(MockUuid()).translationNote}
''';
  }
}
