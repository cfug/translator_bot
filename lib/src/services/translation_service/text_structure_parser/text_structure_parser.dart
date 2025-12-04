import 'models/text_structure_model.dart';
import 'parsers/parsers.dart';
import 'text_parser.dart';

/// 文本结构解析器
class TextStructureParser {
  /// 创建解析器（使用默认解析器列表）
  /// TODO: 用 AST tree 来实现，识别特征
  TextStructureParser() : _parsers = _defaultParsers();

  /// 创建解析器（自定义解析器列表）
  TextStructureParser.custom(List<TextParser> parsers)
    : _parsers = List.from(parsers)
        ..sort((a, b) => a.priority.compareTo(b.priority));

  /// 解析器列表
  final List<TextParser> _parsers;

  /// 默认解析器列表
  static List<TextParser> _defaultParsers() {
    return [
      TopMetadataParser(),
      MarkdownCodeBlockParser(),
      BlankLineParser(),
      MarkdownHorizontalRuleParser(),
      MarkdownListItemParser(),
      MarkdownTitleParser(),
      MarkdownDefineLinkParser(),
      MarkdownImageParser(),
      MarkdownCustomAsideTypeParser(),
      MarkdownCustom1Parser(),
      MarkdownCustom2Parser(),
      Liquid1Parser(),
      HtmlTagParser(),
      HtmlCommentParser(),
      MarkdownTableParser(),
      ParagraphParser(),
    ]..sort((a, b) => a.priority.compareTo(b.priority));
  }

  /// 添加解析器
  void addParser(TextParser parser) {
    _parsers.add(parser);
    _parsers.sort((a, b) => a.priority.compareTo(b.priority));
  }

  /// 移除解析器
  void removeParser<T extends TextParser>() {
    _parsers.removeWhere((p) => p is T);
  }

  /// 解析文本结构
  List<TextStructure> parse(String content) {
    final lines = content.split('\n');
    final context = ParseContext(lines: lines);

    for (var i = 0; i < lines.length; i++) {
      context.currentIndex = i;

      for (final parser in _parsers) {
        if (parser.parse(context) == ParseResult.handled) {
          break;
        }
      }
    }

    return context.results;
  }
}
