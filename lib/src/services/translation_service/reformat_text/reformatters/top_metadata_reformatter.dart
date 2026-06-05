import '../reformatter.dart';

/// 顶部元数据预处理器
///
/// 移除顶部 `---` front matter 块内部多余的空行。
/// 不属于「标记行间隔」家族（是区域级正则替换），故直接实现 [TextReformatter]。
class TopMetadataReformatter implements TextReformatter {
  /// 匹配顶部的 `---` 块，确保结束的 `---` 后紧跟换行或结尾。
  static final RegExp _frontMatter = RegExp(
    r'^---\r?\n(.*?)\r?\n---(?=\r?\n|$)',
    dotAll: true,
  );

  @override
  String reform(String text) {
    return text.replaceFirstMapped(_frontMatter, (match) {
      final content = match.group(1);
      if (content == null) return '';
      final cleanedContent = content
          .split('\n')
          .where((line) => line.trim().isNotEmpty) // 过滤所有空行
          .join('\n');
      return '---\n$cleanedContent\n---';
    });
  }
}
