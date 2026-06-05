import '../../case.dart';

/// Markdown 自定义语法 {:x} 基础
class CaseMarkdownCustom1 implements Case {
  const CaseMarkdownCustom1();

  @override
  String testText() => '{: .class }';

  @override
  List<String> expectStructures() => const ['markdownCustom1:0-0'];
}
