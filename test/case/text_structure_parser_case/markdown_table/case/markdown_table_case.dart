import '../../case.dart';

/// Markdown 表格 基础
class CaseMarkdownTable implements Case {
  const CaseMarkdownTable();

  @override
  String testText() => '| h1 | h2 |\n| --- | --- |\n| a | b |';

  @override
  List<String> expectStructures() => const ['markdownTable:0-2'];
}

/// Markdown 表格（中文）基础
class CaseChineseMarkdownTable implements Case {
  const CaseChineseMarkdownTable();

  @override
  String testText() => '| 列一 | 列二 |\n| --- | --- |\n| 甲 | 乙 |';

  @override
  List<String> expectStructures() => const ['chineseMarkdownTable:0-2'];
}
