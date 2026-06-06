import '../../enum.dart';
import '../placeholder_chunker.dart';

/// Markdown 标题占位处理器
class MarkdownTitleChunker extends PlaceholderChunker {
  @override
  TextStructureType get type => TextStructureType.markdownTitle;

  @override
  bool chunk(PlaceholderContext context) {
    final lines = context.current.originalText;
    final textStructureNext2 = context.next(2);

    /// 添加原始内容
    context.addLines(lines);

    if (lines.isEmpty) return true;

    /// 处理需要翻译的内容
    final content = lines.join('\n');

    /// 匹配标题前缀
    final markdownTitleRegex = RegExp(r'^\s*(#{1,6})\s*(.*?)\s*$');

    /// 匹配当前行标题
    final markdownTitleMatch = markdownTitleRegex.firstMatch(content);
    if (markdownTitleMatch == null) return true;
    final titlePrefix = markdownTitleMatch.group(1);
    final titleText = markdownTitleMatch.group(2);
    if (titlePrefix == null || titleText == null) return true;

    /// 下两行标题是否存在中文
    final textStructureNext2IsChinese =
        textStructureNext2?.type.isChinese ?? false;

    /// 下两行标题前缀
    String? titlePrefixNext2;
    if (textStructureNext2 != null) {
      final contentNext2 = textStructureNext2.originalText.join('\n');
      final markdownTitleMatch = markdownTitleRegex.firstMatch(contentNext2);
      if (markdownTitleMatch != null) {
        titlePrefixNext2 = markdownTitleMatch.group(1);
      }
    }

    /// 下两行标题前缀可匹配并且为中文的情况，可匹配则跳过翻译
    if (titlePrefix == titlePrefixNext2 && textStructureNext2IsChinese) {
      return true;
    }

    /// 添加翻译块 ID 占位
    final translationChunkId = context.addChunk(titleText);
    context.addLine('');
    context.addLine('$titlePrefix $translationChunkId');

    context.addBlankLineBeforeNext();
    return true;
  }
}
