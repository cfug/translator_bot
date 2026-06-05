import '../../case.dart';

/// Markdown 自定义 aside（仅类型） 基础
class CaseMarkdownCustomAsideType implements Case {
  const CaseMarkdownCustomAsideType();

  @override
  String testText() => ':::note';

  @override
  List<String> expectStructures() => const ['markdownCustomAsideType:0-0'];
}
