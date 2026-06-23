import 'package:cfug_translator_bot/src/services/translation_service/translation_placeholder/chunkers/front_matter_chunker.dart';

import '../../../../mock_uuid.dart';
import '../../case.dart';

class CaseFrontMatter1 implements Case {
  /// 顶部元数据基础 1
  const CaseFrontMatter1();

  @override
  String testText() {
    return '''
---
title: More thoughts about performance
description: >- 
  Use the legacy plugin_ffi template and dart:ffi to bind to
  native C code in your Flutter plugin or app.
---
''';
  }

  @override
  String expect() {
    return '''
---
# title: More thoughts about performance
title: ${MockUuid.translationChunkId}
# description: >- 
#   Use the legacy plugin_ffi template and dart:ffi to bind to
#   native C code in your Flutter plugin or app.
description: ${MockUuid.translationChunkId}
$frontMatterAiTranslatedFlag true
---
''';
  }
}
