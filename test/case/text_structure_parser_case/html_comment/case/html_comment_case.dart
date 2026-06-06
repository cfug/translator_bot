import '../../case.dart';

/// HTML 注释 基础
class CaseHtmlComment implements Case {
  const CaseHtmlComment();

  @override
  String testText() => '<!-- a comment -->';

  @override
  List<String> expectStructures() => const ['htmlComment:0-0'];
}
