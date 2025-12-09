import '../../../../utils.dart';
import '../models/text_structure_model.dart';
import '../../enum.dart';
import '../text_parser.dart';
import 'blank_line_parser.dart';
import 'html_comment_parser.dart';
import 'html_tag_parser.dart';
import 'liquid_1_parser.dart';
import 'markdown_code_block_parser.dart';
import 'markdown_custom_1_parser.dart';
import 'markdown_custom_2_parser.dart';
import 'markdown_custom_aside_type_parser.dart';
import 'markdown_define_link_parser.dart';
import 'markdown_horizontal_rule_parser.dart';
import 'markdown_image_parser.dart';
import 'markdown_list_item_parser.dart';
import 'markdown_table_parser.dart';
import 'markdown_title_parser.dart';

/// 整块段落 - 除其他规则以外无法判定的内容 解析器
class ParagraphParser implements TextParser {
  @override
  int get priority => 16;

  static bool notParagraphHasMatch(String? line) {
    return line == null ||
        BlankLineParser.hasMatch(line) ||
        MarkdownCodeBlockParser.hasMatch(line) ||
        MarkdownListItemParser.hasMatch(line) ||
        MarkdownTitleParser.hasMatch(line) ||
        MarkdownDefineLinkParser.hasMatch(line) ||
        MarkdownImageParser.hasMatch(line) ||
        MarkdownHorizontalRuleParser.hasMatch(line) ||
        MarkdownTableParser.hasMatch(line) ||
        MarkdownCustomAsideTypeParser.hasMatch(line) ||
        MarkdownCustom1Parser.hasMatch(line) ||
        MarkdownCustom2Parser.hasMatch(line) ||
        Liquid1Parser.hasMatch(line) ||
        HtmlTagParser.hasMatch(line) ||
        HtmlCommentParser.beginHasMatch(line);
  }

  @override
  ParseResult parse(ParseContext context) {
    final lineNextTrim = context.nextLineTrim;

    if (context.currentType != TextStructureType.paragraph) {
      /// 段落开始
      context.currentType = TextStructureType.paragraph;
      context.startLineIndex = context.currentIndex;
    }
    if (context.currentType == TextStructureType.paragraph) {
      /// 段落内容
      context.originalText.add(context.currentLine);

      /// 判定是否结束段落
      var isParagraphEnd = false;

      /// 下一行是否可判定为其他类型
      final isNextLineNotParagraph = notParagraphHasMatch(lineNextTrim);
      if (isNextLineNotParagraph) {
        isParagraphEnd = true;
      }

      /// 结束段落
      if (isParagraphEnd) {
        /// 标记中文
        final isChinese = Utils.isChinese(context.originalText.join());
        final textStructureType = isChinese
            ? TextStructureType.chineseParagraph
            : TextStructureType.paragraph;

        /// 添加结构数据
        context.addStructure(
          TextStructure(
            type: textStructureType,
            start: context.startLineIndex,
            end: context.currentIndex,
            originalText: context.originalText,
          ),
        );

        context.reset();
        return ParseResult.handled;
      }
    }
    return ParseResult.notHandled;
  }
}
