import '../../case.dart';

/// Liquid 语法1 基础
class CaseLiquid1 implements Case {
  const CaseLiquid1();

  @override
  String testText() => '{% tab "X" %}';

  @override
  List<String> expectStructures() => const ['liquid1:0-0'];
}

/// Liquid 语法1（中文）基础
class CaseChinsesLiquid1 implements Case {
  const CaseChinsesLiquid1();

  @override
  String testText() => '{% tab "中文" %}';

  @override
  List<String> expectStructures() => const ['chinsesLiquid1:0-0'];
}
