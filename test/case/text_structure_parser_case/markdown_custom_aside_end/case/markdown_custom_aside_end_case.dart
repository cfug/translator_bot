import '../../case.dart';

/// Markdown 自定义 aside（结束） 基础
class CaseMarkdownCustomAsideEnd implements Case {
  const CaseMarkdownCustomAsideEnd();

  @override
  String testText() => ':::';

  @override
  List<String> expectStructures() => const ['markdownCustomAsideEnd:0-0'];
}
