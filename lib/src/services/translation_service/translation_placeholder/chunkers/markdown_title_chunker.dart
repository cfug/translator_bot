import '../../enum.dart';
import '../../text_structure_parser/models/text_structure_model.dart';
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

    /// 解析相邻标题为 (前缀, 文本)
    ({String prefix, String text})? parseTitle(TextStructure? structure) {
      if (structure == null) return null;
      final match = markdownTitleRegex.firstMatch(
        structure.originalText.join('\n'),
      );
      final prefix = match?.group(1);
      final text = match?.group(2);
      if (prefix == null || text == null) return null;
      return (prefix: prefix, text: text);
    }

    final next2 = parseTitle(textStructureNext2);
    final prev2 = parseTitle(context.next(-2));

    /// 相邻标题是否与本标题同级（前缀一致）
    bool isSameLevel(({String prefix, String text})? sibling) =>
        sibling != null && sibling.prefix == titlePrefix;

    /// 相邻标题正文是否与本标题等值
    bool isSameText(({String prefix, String text})? sibling) =>
        sibling != null &&
        PlaceholderContext.textEquals(sibling.text, titleText);

    final next2IsChinese = textStructureNext2?.type.isChinese ?? false;

    /// 下两行是本标题的译文 -> 本行是已译原文，
    /// 跳过：同级标题，且其为中文译文，或与本标题等值。
    final isAlreadyTranslated =
        isSameLevel(next2) && (next2IsChinese || isSameText(next2));

    /// 上两行是与本标题等值的同级标题，跳过避免重复。
    final isTranslationCopy = isSameLevel(prev2) && isSameText(prev2);

    if (isAlreadyTranslated || isTranslationCopy) return true;

    /// 添加翻译块 ID 占位
    final translationChunkId = context.addChunk(titleText);
    context.addLine('');
    context.addLine('$titlePrefix $translationChunkId');

    context.addBlankLineBeforeNext();
    return true;
  }
}
