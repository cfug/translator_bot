import '../../enum.dart';
import '../text_parser.dart';

/// 单行 Markdown 分割横线解析器
/// `---`、`- - -`、`* * *`、`_ _ _`
class MarkdownHorizontalRuleParser extends SingleLineParser {
  static final RegExp _pattern = RegExp(r'^\s*([-*_])(?:\s*\1){2,}\s*$');

  @override
  TextStructureType get type => TextStructureType.markdownHorizontalRule;

  @override
  bool matches(String lineTrim) => _pattern.hasMatch(lineTrim);
}
