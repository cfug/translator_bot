import '../../case.dart';

/// 空行 基础
class CaseBlankLine implements Case {
  const CaseBlankLine();

  @override
  String testText() => 'a\n\nb';

  @override
  List<String> expectStructures() => const [
    'paragraph:0-0',
    'blankLine:1-1',
    'paragraph:2-2',
  ];
}
