import '../../case.dart';

/// Markdown 定义链接 基础
class CaseMarkdownDefineLink implements Case {
  const CaseMarkdownDefineLink();

  @override
  String testText() => '[ref]: http://example.com';

  @override
  List<String> expectStructures() => const ['markdownDefineLink:0-0'];
}
