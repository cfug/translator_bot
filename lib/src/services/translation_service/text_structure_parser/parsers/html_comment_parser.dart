import '../models/text_structure_model.dart';
import '../../enum.dart';
import '../text_parser.dart';

/// HTML 注释 `<!-- xx -->` 解析器
class HtmlCommentParser implements TextParser {
  @override
  int get priority => 14;

  static bool beginHasMatch(String line) => RegExp(r'^\s*<!--').hasMatch(line);
  static bool endHasMatch(String line) => RegExp(r'-->').hasMatch(line);

  @override
  ParseResult parse(ParseContext context) {
    final lineTrim = context.currentLineTrim;

    /// HTML 注释 - 开始
    if (beginHasMatch(lineTrim) &&
        context.currentType != TextStructureType.htmlComment) {
      context.currentType = TextStructureType.htmlComment;
      context.startLineIndex = context.currentIndex;
      context.originalText.add(context.currentLine);

      /// HTML 注释 - 单行结束
      if (endHasMatch(lineTrim)) {
        /// 添加结构数据
        context.addStructure(
          TextStructure(
            type: TextStructureType.htmlComment,
            start: context.currentIndex,
            end: context.currentIndex,
            originalText: context.originalText,
          ),
        );

        context.reset();
      }
      return ParseResult.handled;
    }

    /// HTML 注释 - 多行结束
    if (endHasMatch(lineTrim) &&
        context.currentType == TextStructureType.htmlComment) {
      context.originalText.add(context.currentLine);

      /// 添加结构数据
      context.addStructure(
        TextStructure(
          type: TextStructureType.htmlComment,
          start: context.startLineIndex,
          end: context.currentIndex,
          originalText: context.originalText,
        ),
      );

      context.reset();
      return ParseResult.handled;
    }

    /// HTML 注释 - 多行内容
    if (context.currentType == TextStructureType.htmlComment) {
      context.originalText.add(context.currentLine);
      return ParseResult.handled;
    }

    return ParseResult.notHandled;
  }
}
