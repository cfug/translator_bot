import 'package:cfug_translator_bot/src/services/translation_service/translation_placeholder/chunkers/top_metadata_chunker.dart';

import '../case.dart';

/// 补充翻译 - 完全已译文档
///
/// 再次跑占位流水线时不应产生任何新占位，输出与输入逐字一致。
class CaseSupplementTranslated implements Case {
  const CaseSupplementTranslated();

  @override
  String testText() {
    return '''
---
# title: Getting Started
title: 入门
# description: Learn the basics
description: 学习基础
$topMetadataAiTranslatedFlag true
---

# Overview

# 概览

## API

## API

Install the package first.

先安装这个包。

- Run the command

  运行命令
''';
  }

  /// 已译内容原样保留，零新增占位（与 [testText] 逐字一致）
  @override
  String expectText() => testText();
}
