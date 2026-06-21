import '../enum.dart';
import 'models/text_structure_model.dart';
import 'parsers/parsers.dart';
import 'text_parser.dart';

/// 文本结构解析器
///
/// 它的设计目标是 **为翻译服务**，而非 **通用文本解析**，
/// 所以在功能上仅覆盖翻译相关的文本结构（标题、列表、代码块、图片、HTML 标签等），
/// 不追求细腻度或全面性（如不区分有序/无序列表、不同级别标题等）。
class TextStructureParser {
  /// 创建解析器（使用默认配置）
  TextStructureParser()
    : _parsers = _defaultParsers(),
      _fallback = ParagraphParser();

  /// 创建解析器（自定义块解析器列表与兜底解析器）
  ///
  /// [parsers] 的顺序仅在 “同一起始行被多个解析器识别” 时作为优先级；
  /// 多行块的内部归属由 “打开中的多行块优先” 调度保证，与顺序无关。
  TextStructureParser.custom(List<TextParser> parsers, {TextParser? fallback})
    : _parsers = List.of(parsers),
      _fallback = fallback ?? ParagraphParser();

  /// 解析器列表
  final List<TextParser> _parsers;

  /// 兜底解析器（任何块解析器都不认领该行时使用）
  final TextParser _fallback;

  /// 默认解析器列表
  ///
  /// 排列顺序仅对 “有歧义的起始行” 生效（靠前者优先）；其余情况可任意排序。
  /// 兜底的段落解析器不在此列表，而由 [_fallback] 持有。
  static List<TextParser> _defaultParsers() {
    return [
      FrontMatterParser(),
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
      // 必须排在 [HtmlTagParser] 之前，`<FileTree>` 同样能被 [HtmlTagParser]
      MdxComponentFileTreeParser(),
      HtmlTagParser(),
      HtmlCommentParser(),
      MarkdownTableParser(),
    ];
  }

  /// 添加解析器
  ///
  /// 默认追加到末尾。
  /// 仅当新解析器与现有解析器存在 “起始行歧义” 时排列顺序才有意义，
  /// 此时可用 [index] 指定插入位置以控制优先级。
  void addParser(TextParser parser, {int? index}) {
    if (index == null) {
      _parsers.add(parser);
    } else {
      _parsers.insert(index, parser);
    }
  }

  /// 移除解析器
  void removeParser<T extends TextParser>() {
    _parsers.removeWhere((p) => p is T);
  }

  /// 解析文本结构
  ///
  /// 采用 “打开中的多行块” 优先调度：
  ///
  /// - 块解析器（[_parsers]）：每行先按列表顺序尝试匹配以开启一个结构；
  ///   一旦某个多行块被打开，后续每一行都 **直接交给这个打开中的块** 处理，直到它自行闭合。
  ///   因此多行块的内部行不会被其他解析器抢走，[_parsers] 的 **排列顺序不影响多行块的正确性**，
  ///   只有在 “同一行能被多个解析器识别为起始” 时，靠前者优先。
  ///   （如 `---` 可能是顶部元数据/分割线、`- - -` 可能是分割线/列表项）
  ///
  /// - 兜底解析器（[_fallback]）：当某行不被任何块解析器认领时使用（默认 [ParagraphParser]）。
  ///   兜底解析器独立于 [_parsers]，因此段落无需 “必须排在最后”。
  List<TextStructure> parse(String content) {
    final lines = content.split('\n');
    final context = ParseContext(lines: lines, parsers: _parsers);

    /// 打开中的多行块解析器（null 表示当前没有打开的多行块）
    TextParser? openBlock;

    for (var i = 0; i < lines.length; i++) {
      context.currentIndex = i;

      /// 打开中的多行块优先：把本行直接交给它
      if (openBlock != null) {
        final result = openBlock.parse(context);
        if (context.currentType == TextStructureType.none) {
          /// 块已闭合
          openBlock = null;
        }
        if (result == ParseResult.handled) {
          continue;
        }

        /// 该多行块未认领本行，清除状态，转入常规匹配。
        ///（防御性代码，正常块解析器不会走到这里）
        openBlock = null;
      }

      /// 常规匹配：按列表顺序尝试开启一个结构
      var handled = false;
      for (final parser in _parsers) {
        if (parser.parse(context) == ParseResult.handled) {
          if (context.currentType != TextStructureType.none) {
            /// 开启了一个多行块，记录它以优先处理后续行
            openBlock = parser;
          }
          handled = true;
          break;
        }
      }

      /// 兜底：任何块解析器都未认领
      if (!handled) {
        _fallback.parse(context);
        if (context.currentType != TextStructureType.none) {
          openBlock = _fallback;
        }
      }
    }

    return context.results;
  }
}
