import '../../../../utils.dart';
import '../../enum.dart';
import '../placeholder_chunker.dart';

/// 单行 HTML 标签 `<Tab name="标题">` 占位处理器
class HtmlTagTabChunker extends PlaceholderChunker {
  @override
  TextStructureType get type => TextStructureType.htmlTag;

  @override
  bool chunk(PlaceholderContext context) {
    final lines = context.current.originalText;
    if (lines.isNotEmpty) {
      final content = lines[0];

      // 判定 `<Tab name="标题">`
      if (content.trimLeft().startsWith('<Tab')) {
        /// `<Tab name="标题">`
        final htmlTabRegex = RegExp(
          r'''<Tab\s+name=["']([^"']+)["'][^>]*>(.*)''',
        );
        if (htmlTabRegex.hasMatch(content)) {
          final match = htmlTabRegex.firstMatch(content);
          final title = match?.group(1) ?? '';
          final other = match?.group(2) ?? '';
          final titleTrim = title.trim();

          if (titleTrim != '' && !Utils.isChinese(titleTrim)) {
            /// 添加注释原始内容
            context.addLine(
              '${" " * context.indentCount(content)}<!-- ${content.trimLeft()} -->',
            );

            /// 添加翻译块 ID 占位
            final translationChunkId = context.addChunk(titleTrim);
            context.addLine(
              '${" " * context.indentCount(content)}<Tab name="$translationChunkId">$other',
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
