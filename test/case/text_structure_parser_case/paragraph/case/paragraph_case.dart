import '../../case.dart';

/// 段落 基础
class CaseParagraph implements Case {
  const CaseParagraph();

  @override
  String testText() => 'hello world\nsecond line';

  @override
  List<String> expectStructures() => const ['paragraph:0-1'];
}

/// 段落（中文）基础
class CaseChineseParagraph implements Case {
  const CaseChineseParagraph();

  @override
  String testText() => '这是一个中文段落';

  @override
  List<String> expectStructures() => const ['chineseParagraph:0-0'];
}
