import '../../enum.dart';
import '../text_parser.dart';

/// Markdown 代码块解析器
/// ``` 开头和结尾的部分
class MarkdownCodeBlockParser extends DelimitedBlockParser {
  @override
  TextStructureType get blockType => TextStructureType.markdownCodeBlock;

  @override
  bool isBegin(String lineTrim) => lineTrim.startsWith('```');
}
