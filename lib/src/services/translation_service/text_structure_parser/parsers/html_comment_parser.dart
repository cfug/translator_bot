import '../../enum.dart';
import '../text_parser.dart';

/// HTML 注释 `<!-- xx -->` 解析器
///
/// 起始与结束界定符不同（`<!--` / `-->`），可在同一行内开闭，也可跨多行。
class HtmlCommentParser extends DelimitedBlockParser {
  static final RegExp _begin = RegExp(r'^\s*<!--');
  static final RegExp _end = RegExp(r'-->');

  @override
  TextStructureType get blockType => TextStructureType.htmlComment;

  @override
  bool isBegin(String lineTrim) => _begin.hasMatch(lineTrim);

  @override
  bool isEnd(String lineTrim) => _end.hasMatch(lineTrim);

  @override
  bool get allowSingleLine => true;
}
