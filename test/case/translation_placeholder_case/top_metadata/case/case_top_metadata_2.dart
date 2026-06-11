import 'package:cfug_translator_bot/src/services/translation_service/translation_placeholder/chunkers/top_metadata_chunker.dart';

import '../../case.dart';

class CaseTopMetadata2 implements Case {
  /// 顶部元数据基础 2 - 已存在 AI 翻译标记
  const CaseTopMetadata2();

  @override
  String testText() {
    return '''
---
# title: More thoughts about performance
title: 测试
# short-title: Text
short-title: 测试
# description: >-
#   What is performance,
#   and why is performance important
description: 测试
$topMetadataAiTranslatedFlag false
---
''';
  }

  @override
  String expectText() {
    return '''
---
# title: More thoughts about performance
title: 测试
# short-title: Text
short-title: 测试
# description: >-
#   What is performance,
#   and why is performance important
description: 测试
$topMetadataAiTranslatedFlag false
---
''';
  }
}
