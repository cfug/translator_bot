import '../../case.dart';

/// 顶部元数据 基础
class CaseFrontMatter implements Case {
  const CaseFrontMatter();

  @override
  String testText() => '---\ntitle: X\n---';

  @override
  List<String> expectStructures() => const ['frontMatter:0-2'];
}

/// 顶部元数据（中文）基础
class CaseChineseFrontMatter implements Case {
  const CaseChineseFrontMatter();

  @override
  String testText() => '---\ntitle: 中文\n---';

  @override
  List<String> expectStructures() => const ['chineseFrontMatter:0-2'];
}
