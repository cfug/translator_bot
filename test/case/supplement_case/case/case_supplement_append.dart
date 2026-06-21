import 'package:cfug_translator_bot/src/services/translation_service/translation_placeholder/chunkers/front_matter_chunker.dart';

import '../../../mock_uuid.dart';
import '../case.dart';

/// 补充翻译 - 已译文档中补译新增的未译片段
class CaseSupplementAppend implements Case {
  const CaseSupplementAppend();

  @override
  String testText() {
    return '''
---
# title: Getting Started
title: 入门
# description: Learn the basics
description: 学习基础
short-title: Quickstart
---

# Overview

# 概览

Install the package first.

先安装这个包。

## Configuration

Edit the config file.

- Enable the flag
''';
  }

  @override
  String expectText() {
    return '''
---
# title: Getting Started
title: 入门
# description: Learn the basics
description: 学习基础
# short-title: Quickstart
short-title: ${MockUuid.translationChunkId}
$frontMatterAiTranslatedFlag true
---

# Overview

# 概览

Install the package first.

先安装这个包。

## Configuration

## ${MockUuid.translationChunkId}

Edit the config file.

${MockUuid.translationChunkId}

- Enable the flag

${MockUuid.translationChunkId}
''';
  }
}
