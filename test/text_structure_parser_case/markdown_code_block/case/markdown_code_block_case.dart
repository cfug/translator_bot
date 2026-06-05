import '../../case.dart';

/// Markdown 代码块 基础
class CaseMarkdownCodeBlock implements Case {
  const CaseMarkdownCodeBlock();

  @override
  String testText() => '```dart\nvar x = 1;\n```';

  @override
  List<String> expectStructures() => const ['markdownCodeBlock:0-2'];
}
