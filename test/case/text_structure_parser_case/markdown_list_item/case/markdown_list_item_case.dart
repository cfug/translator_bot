import '../../case.dart';

/// Markdown 列表项 基础
class CaseMarkdownListItem implements Case {
  const CaseMarkdownListItem();

  @override
  String testText() => '- item';

  @override
  List<String> expectStructures() => const ['markdownListItem:0-0'];
}

/// Markdown 列表项（中文）基础
class CaseChineseMarkdownListItem implements Case {
  const CaseChineseMarkdownListItem();

  @override
  String testText() => '- 中文列表项';

  @override
  List<String> expectStructures() => const ['chineseMarkdownListItem:0-0'];
}
