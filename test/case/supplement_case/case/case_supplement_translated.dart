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
---

:::note

本篇文档由 AI 翻译。

:::

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
