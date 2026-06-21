import '../../case.dart';

/// 顶部元数据内的空行：过滤掉
class CaseFrontMatterBlankLines implements ReformatCase {
  const CaseFrontMatterBlankLines();

  @override
  String testText() => '---\ntitle: x\n\ntags: y\n---\nbody';

  @override
  String expectText() => '---\ntitle: x\ntags: y\n---\nbody';
}

/// 顶部元数据内的 YAML 列表：listItem 先补空行，再由 frontMatter 收尾清理
///（验证 all() 的顺序契约）
class CaseFrontMatterYamlList implements ReformatCase {
  const CaseFrontMatterYamlList();

  @override
  String testText() => '---\ntags:\n  - a\n  - b\n---\nbody';

  @override
  String expectText() => '---\ntags:\n  - a\n  - b\n---\nbody';
}
