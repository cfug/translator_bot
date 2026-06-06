import '../../case.dart';

/// 顶部元数据 基础
class CaseTopMetadata implements Case {
  const CaseTopMetadata();

  @override
  String testText() => '---\ntitle: X\n---';

  @override
  List<String> expectStructures() => const ['topMetadata:0-2'];
}

/// 顶部元数据（中文）基础
class CaseChineseTopMetadata implements Case {
  const CaseChineseTopMetadata();

  @override
  String testText() => '---\ntitle: 中文\n---';

  @override
  List<String> expectStructures() => const ['chineseTopMetadata:0-2'];
}
