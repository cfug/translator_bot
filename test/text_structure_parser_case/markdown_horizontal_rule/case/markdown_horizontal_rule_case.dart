import '../../case.dart';

/// Markdown 分割线 基础
class CaseMarkdownHorizontalRule implements Case {
  const CaseMarkdownHorizontalRule();

  @override
  String testText() => '* * *';

  @override
  List<String> expectStructures() => const ['markdownHorizontalRule:0-0'];
}
