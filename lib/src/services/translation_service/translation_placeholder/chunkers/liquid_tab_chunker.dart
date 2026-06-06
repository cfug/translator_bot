import '../../enum.dart';
import '../placeholder_chunker.dart';

/// Liquid `{% tab "标题" %}` 占位处理器
class LiquidTabChunker extends PlaceholderChunker {
  @override
  TextStructureType get type => TextStructureType.liquid1;

  @override
  bool chunk(PlaceholderContext context) {
    final lines = context.current.originalText;
    if (lines.isNotEmpty) {
      final content = lines[0];

      // 判定 `{% tab "标题" %}`
      if (content.trimLeft().startsWith('{% tab ')) {
        /// 添加注释原始内容
        context.addLine(
          '${" " * context.indentCount(content)}<!-- ${content.trimLeft()} -->',
        );

        /// `{% tab "标题" %}`
        final liquidTabRegex = RegExp(r'^\s*\{%\s+tab\s+"([^"]+)"\s*%\}$');
        if (liquidTabRegex.hasMatch(content)) {
          final match = liquidTabRegex.firstMatch(content);
          final title = match!.group(1)!;

          if (title.trim() != '') {
            /// 添加翻译块 ID 占位
            final translationChunkId = context.addChunk(title.trim());
            context.addLine(
              '${" " * context.indentCount(content)}{% tab "$translationChunkId" %}',
            );
            return true;
          }
        }
      }
      context.addLines(lines);
    }
    return true;
  }
}
