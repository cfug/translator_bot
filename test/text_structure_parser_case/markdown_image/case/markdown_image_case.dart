import '../../case.dart';

/// Markdown 图片 基础
class CaseMarkdownImage implements Case {
  const CaseMarkdownImage();

  @override
  String testText() => '![alt](http://x/y.png)';

  @override
  List<String> expectStructures() => const ['markdownImage:0-0'];
}
