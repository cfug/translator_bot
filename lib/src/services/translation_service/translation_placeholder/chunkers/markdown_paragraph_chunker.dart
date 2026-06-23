import '../../enum.dart';
import '../../models/translation_chunk_model.dart';
import '../placeholder_chunker.dart';

/// Markdown 段落占位处理器
class MarkdownParagraphChunker extends PlaceholderChunker {
  @override
  TextStructureType get type => TextStructureType.paragraph;

  @override
  bool chunk(PlaceholderContext context) {
    var lines = context.current.originalText;
    final textStructureNext2IsChinese =
        context.next(2)?.type.isChinese ?? false;

    /// 处理 `:` 开头的情况
    lines = lines.map((line) {
      return line.trimLeft().startsWith(':')
          ? line.replaceFirst(':', '<br>')
          : line;
    }).toList();

    /// 添加原始内容
    context.addLines(lines);

    if (lines.isNotEmpty && !textStructureNext2IsChinese) {
      final content = lines.join('\n');

      /// 添加翻译块 ID 占位
      final translationChunkId = context.addChunk(
        content,
        indentCount: context.indentCount(lines[0]),
        omitMode: OmitMode.dropLine,
      );
      context.addLine('');
      context.addLine(translationChunkId);

      context.addBlankLineBeforeNext();
    }
    return true;
  }
}
