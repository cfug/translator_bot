import 'package:cfug_translator_bot/src/services/translation_service/translation_placeholder/chunkers/front_matter_chunker.dart';

import '../../../../mock_uuid.dart';
import '../../case.dart';

class CaseFrontMatter3 implements Case {
  /// 顶部元数据基础 3 - 块内补充翻译
  ///
  /// 已译的元数据中新增了未译字段（`description`）：
  /// 整块虽含中文（`title: 测试`），但新字段仍应被补译，而非整块跳过。
  ///
  /// 期望：已译字段（带 `# title:` 注释 + `title: 测试`）原样保留、不重译；
  /// 新字段 `description` 注释原文 + 插占位；
  /// AI 翻译标记因不存在而补充一次。
  const CaseFrontMatter3();

  @override
  String testText() {
    return '''
---
# title: More thoughts about performance
title: 测试
description: What is performance, and why is performance important
---
''';
  }

  @override
  String expectText() {
    return '''
---
# title: More thoughts about performance
title: 测试
# description: What is performance, and why is performance important
description: ${MockUuid.translationChunkId}
$frontMatterAiTranslatedFlag true
---
''';
  }
}
