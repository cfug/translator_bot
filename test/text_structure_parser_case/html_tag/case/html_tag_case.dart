import '../../case.dart';

/// HTML 标签 基础
class CaseHtmlTag implements Case {
  const CaseHtmlTag();

  @override
  String testText() => '<div class="x">';

  @override
  List<String> expectStructures() => const ['htmlTag:0-0'];
}
