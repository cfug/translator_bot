import '../../case.dart';

/// Markdown 标题 基础
class CaseMarkdownTitle implements Case {
  const CaseMarkdownTitle();

  @override
  String testText() => '# Heading';

  @override
  List<String> expectStructures() => const ['markdownTitle:0-0'];
}

/// Markdown 标题（中文）基础
class CaseChineseMarkdownTitle implements Case {
  const CaseChineseMarkdownTitle();

  @override
  String testText() => '# 中文标题';

  @override
  List<String> expectStructures() => const ['chineseMarkdownTitle:0-0'];
}
