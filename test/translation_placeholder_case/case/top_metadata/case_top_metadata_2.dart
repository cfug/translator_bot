import 'package:cfug_translator_bot/src/services/translation_service/translation_placeholder.dart';

import '../../../mock_uuid.dart';
import '../case.dart';

/// 顶部元数据基础 2 - 已存在翻译说明
class CaseTopMetadata2 implements Case {
  @override
  String testDescription() => '顶部元数据基础 2 - 已存在翻译说明';

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
---
${TranslationPlaceholder(MockUuid()).translationNote}
''';
  }

  @override
  String expectData() {
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
---
${TranslationPlaceholder(MockUuid()).translationNote}
''';
  }
}
