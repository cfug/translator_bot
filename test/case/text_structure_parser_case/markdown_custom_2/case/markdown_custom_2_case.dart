import '../../case.dart';

/// Markdown 自定义语法 <?x 基础
class CaseMarkdownCustom2 implements Case {
  const CaseMarkdownCustom2();

  @override
  String testText() => '<?xxx echo 1;';

  @override
  List<String> expectStructures() => const ['markdownCustom2:0-0'];
}
