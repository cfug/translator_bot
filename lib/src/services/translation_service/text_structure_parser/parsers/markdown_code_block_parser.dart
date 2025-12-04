import '../models/text_structure_model.dart';
import '../../enum.dart';
import '../text_parser.dart';

/// Markdown 代码块解析器
/// ``` 开头和结尾的部分
class MarkdownCodeBlockParser implements TextParser {
  static const delimiter = '```';

  @override
  int get priority => 2;

  @override
  ParseResult parse(ParseContext context) {
    final lineTrim = context.currentLineTrim;

    if (lineTrim.startsWith(delimiter)) {
      if (context.currentType != TextStructureType.markdownCodeBlock) {
        /// Markdown 代码块 - 开始
        context.currentType = TextStructureType.markdownCodeBlock;
        context.startLineIndex = context.currentIndex;
        context.originalText.add(context.currentLine);
      } else {
        /// Markdown 代码块 - 结束
        context.originalText.add(context.currentLine);

        context.addStructure(
          TextStructure(
            type: TextStructureType.markdownCodeBlock,
            start: context.startLineIndex,
            end: context.currentIndex,
            originalText: context.originalText,
          ),
        );

        context.reset();
      }
      return ParseResult.handled;
    }

    /// Markdown 代码块 - 内容
    if (context.currentType == TextStructureType.markdownCodeBlock) {
      context.originalText.add(context.currentLine);
      return ParseResult.handled;
    }

    return ParseResult.notHandled;
  }
}
