import '../../enum.dart';
import '../placeholder_chunker.dart';

/// Markdown 列表项占位处理器
class MarkdownListItemChunker extends PlaceholderChunker {
  @override
  TextStructureType get type => TextStructureType.markdownListItem;

  @override
  bool chunk(PlaceholderContext context) {
    final lines = context.current.originalText;
    final textStructureNext2IsChinese =
        context.next(2)?.type.isChinese ?? false;

    /// 添加原始内容
    context.addLines(lines);

    if (lines.isNotEmpty && !textStructureNext2IsChinese) {
      final markdownListItemRegex = RegExp(r'^\s*([*\-+]|\d+\.)\s+(.+)$');
      final markdownListItemMatch = markdownListItemRegex.firstMatch(lines[0]);
      if (markdownListItemMatch != null) {
        final listItemPrefix = markdownListItemMatch.group(1);
        final listItemTextFirstLine = markdownListItemMatch.group(2);
        if (listItemPrefix == null || listItemTextFirstLine == null) {
          return true;
        }

        /// 计算缩进空格数（列表项符号 + 列表项符号前后的空格）
        /// 与原文缩进保持一致
        final indentCount =
            listItemPrefix.length +
            context.indentCount(lines[0].replaceFirst(listItemPrefix, ''));

        /// 翻译原始内容
        final content =
            '$listItemTextFirstLine\n${lines.where((value) => value != lines[0]).join('\n')}';

        /// 添加翻译块 ID 占位
        final translationChunkId = context.addChunk(
          content,
          indentCount: indentCount,
        );
        context.addLine('');
        context.addLine(translationChunkId);

        context.addBlankLineBeforeNext();
      }
    }
    return true;
  }
}
