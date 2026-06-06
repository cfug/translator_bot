import '../../case.dart';

/// Markdown 自定义 aside（类型+标题）基础
class CaseMarkdownCustomAsideTypeTitle implements Case {
  const CaseMarkdownCustomAsideTypeTitle();

  @override
  String testText() => ':::note Title here';

  @override
  List<String> expectStructures() => const ['markdownCustomAsideTypeTitle:0-0'];
}

/// Markdown 自定义 aside（类型+标题，中文）基础
class CaseChineseMarkdownCustomAsideTypeTitle implements Case {
  const CaseChineseMarkdownCustomAsideTypeTitle();

  @override
  String testText() => ':::note 中文标题';

  @override
  List<String> expectStructures() => const [
    'chineseMarkdownCustomAsideTypeTitle:0-0',
  ];
}
