import '../../enum.dart';
import '../placeholder_chunker.dart';

/// Markdown 自定义 aside/admonition 语法（存在类型、标题）占位处理器
///
/// `:::类型 标题`
class MarkdownCustomAsideTypeTitleChunker extends PlaceholderChunker {
  @override
  TextStructureType get type => TextStructureType.markdownCustomAsideTypeTitle;

  @override
  bool chunk(PlaceholderContext context) {
    final lines = context.current.originalText;

    if (lines.isNotEmpty) {
      final content = lines[0];

      /// 添加注释原始内容
      context.addLine(
        '${" " * context.indentCount(content)}<!-- ${content.trimLeft()} -->',
      );

      /// `:::类型 标题`
      final markdownCustomAsideRegex = RegExp(
        r'^\s*(:::)\s*([a-zA-Z0-9-]*)\s*(.*)$',
      );
      if (markdownCustomAsideRegex.hasMatch(content)) {
        final match = markdownCustomAsideRegex.firstMatch(content);
        final delimiter = match!.group(1)!; // 必为 :::
        final asideType = match.group(2)?.trim() != '' ? match.group(2) : null;
        final title = match.group(3)?.trim() != '' ? match.group(3) : null;

        if (asideType != null && title != null) {
          /// 添加翻译块 ID 占位
          final translationChunkId = context.addChunk(title);
          context.addLine(
            '${" " * context.indentCount(content)}$delimiter$asideType $translationChunkId',
          );

          context.addBlankLineBeforeNext();
        }
      }
    }
    return true;
  }
}
