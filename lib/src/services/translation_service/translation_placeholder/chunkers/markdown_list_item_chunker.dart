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
        final indentCount =
            context.indentCount(lines[0]) + listItemPrefix.length + 1;

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
