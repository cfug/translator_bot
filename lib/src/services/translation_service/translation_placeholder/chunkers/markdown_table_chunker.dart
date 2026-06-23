import '../../enum.dart';
import '../../models/translation_chunk_model.dart';
import '../placeholder_chunker.dart';

/// Markdown 表格占位处理器
class MarkdownTableChunker extends PlaceholderChunker {
  @override
  TextStructureType get type => TextStructureType.markdownTable;

  @override
  bool chunk(PlaceholderContext context) {
    final lines = context.current.originalText;

    /// 至少 3 行（表头 分割 主内容）
    if (lines.length >= 3) {
      final tableHeader = lines[0];
      final tableSeparator = lines[1];
      final indentText = ' ' * context.indentCount(tableHeader);

      /// 处理表头
      final modifiedTableHeader = tableHeader
          .split('|')
          .map((cell) {
            final cellTrim = cell.trim();
            if (cellTrim != '') {
              /// 添加翻译块 ID 占位
              final translationChunkId = context.addChunk(
                cellTrim,
                omitMode: OmitMode.collapseTableCell,
              );
              return '<t>$cellTrim</t><t>$translationChunkId</t>';
            } else {
              return cell;
            }
          })
          .join('|');
      context.addLine('$indentText$modifiedTableHeader');
      context.addLine('$indentText$tableSeparator');

      /// 处理表主体内容
      for (var i = 2; i < lines.length; i++) {
        final tableData = lines[i];

        /// 添加原始行
        context.addLine(tableData);

        /// 添加翻译占位 ID 行
        final modifiedTableData = tableData
            .split('|')
            .map((cell) {
              final cellTrim = cell.trim();

              if (cellTrim != '') {
                /// 添加翻译块 ID 占位
                final translationChunkId = context.addChunk(
                  cellTrim,
                  omitMode: OmitMode.dropLine,
                );
                return translationChunkId;
              } else {
                return cell;
              }
            })
            .join('|');
        context.addLine('$indentText$modifiedTableData');
      }
    }

    context.addBlankLineBeforeNext();
    return true;
  }
}
