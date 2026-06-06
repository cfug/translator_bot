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

/// 段落（以英文为主、仅夹少量中文术语）
class CaseEnglishParagraphWithChineseTerm implements Case {
  const CaseEnglishParagraphWithChineseTerm();

  @override
  String testText() =>
      'This sentence uses the 范围 operator and is mostly English text.';

  @override
  List<String> expectStructures() => const ['paragraph:0-0'];
}
