import 'models/text_structure_model.dart';
import '../enum.dart';

/// 解析结果
enum ParseResult {
  /// 已处理，继续下一行
  handled,

  /// 未处理，交给下一个解析器
  notHandled,
}

/// 文本解析器接口
///
/// 解析按解析器在列表中的顺序逐个尝试，首个返回 [ParseResult.handled] 的解析器胜出。
/// 因此 “列表顺序” 即调度优先级，兜底解析器须排在最后。
abstract class TextParser {
  /// 该行是否是本解析器块的起始/归属
  ///
  /// 用于让调度上下文统一询问 “某行是否被某个解析器认领”，
  /// 从而避免解析器之间相互硬编码枚举（参见 [ParseContext.isLineClaimedByOther]）。
  ///
  /// - [line] 需要判定的行（通常传入去除首尾空格后的内容）
  bool matchesLineStart(String line);

  /// 尝试解析当前行
  ParseResult parse(ParseContext context);
}

/// 解析上下文
/// 用于在解析器之间共享状态
class ParseContext {
  ParseContext({
    required this.lines,
    this.parsers = const [],
    this.currentIndex = 0,
    this.currentType = TextStructureType.none,
    this.startLineIndex = -1,
    List<String>? originalText,
    List<TextStructure>? results,
  }) : originalText = originalText ?? [],
       results = results ?? [];

  /// 所有行
  final List<String> lines;

  /// 参与解析的解析器列表（用于跨解析器的认领判定）
  final List<TextParser> parsers;

  /// 当前行索引
  int currentIndex;

  /// 当前文本结构类型
  TextStructureType currentType;

  /// 当前起始行
  int startLineIndex;

  /// 当前原始文本
  List<String> originalText;

  /// 已解析的结构列表
  final List<TextStructure> results;

  /// 当前行
  String get currentLine => lines[currentIndex];

  /// 当前行（去除首尾空格）
  String get currentLineTrim => currentLine.trim();

  /// 下一行
  String? get nextLine =>
      currentIndex < lines.length - 1 ? lines[currentIndex + 1] : null;

  /// 下一行（去除首尾空格）
  String? get nextLineTrim => nextLine?.trim();

  /// 是否是最后一行
  bool get isLastLine => currentIndex == lines.length - 1;

  /// 重置状态
  void reset() {
    currentType = TextStructureType.none;
    startLineIndex = -1;
    originalText = [];
  }

  /// 添加结构
  void addStructure(TextStructure structure) {
    results.add(structure);
  }

  /// 该行是否被 [self] 以外的其他解析器认领
  ///
  /// 用于段落等兜底解析器判定边界：当下一行能被其他任意解析器识别为块起始时，
  /// 当前兜底块即结束。
  ///
  /// - [line] 需要判定的行
  /// - [self] 发起询问的解析器（排除自身，避免自我匹配）
  bool isLineClaimedByOther(String line, TextParser self) =>
      parsers.any((p) => !identical(p, self) && p.matchesLineStart(line));

  /// 该行是否被任意解析器认领（含发起者自身）
  ///
  /// 用于列表项等 “连续同类行也应分块” 的解析器判定边界：
  /// 下一行只要能被任意解析器（包括另一个同类列表项）识别为块起始，当前块即结束。
  ///
  /// - [line] 需要判定的行
  bool isLineClaimedByAny(String line) =>
      parsers.any((p) => p.matchesLineStart(line));
}

/// 单行解析器类
///
/// 适用于 “一行即一个结构” 的语法（标题、图片、空行、HTML 标签、Liquid 等），
/// 或者虽允许多行但不依赖于块界定符 [DelimitedBlockParser] 的语法
/// （例如，多行块自定义语法，只单独解析起始和结束界定符，为了中间内容可以被其他解析器识别）
///
/// 子类只需声明匹配规则与结构类型；可重写 [resolveType] 支持中文变体
/// 或基于内容的多类型判定（如 aside 语法）。
abstract class SingleLineParser extends TextParser {
  /// 默认结构类型
  TextStructureType get type;

  /// 该行（已 trim）是否匹配本解析器
  bool matches(String lineTrim);

  /// 由当前行确定最终结构类型，默认返回 [type]。
  ///
  /// 重写以支持中文变体或基于捕获组的多类型判定。
  TextStructureType resolveType(ParseContext context) => type;

  @override
  bool matchesLineStart(String line) => matches(line);

  @override
  ParseResult parse(ParseContext context) {
    if (!matches(context.currentLineTrim)) return ParseResult.notHandled;
    context.addStructure(
      TextStructure(
        type: resolveType(context),
        start: context.currentIndex,
        end: context.currentIndex,
        originalText: [context.currentLine],
      ),
    );
    return ParseResult.handled;
  }
}

/// 界定块解析器类
///
/// 适用于 “由起始界定符开启、由结束界定符闭合、之间为内容” 的块（可单行或多行）。
///
/// 由两组钩子适配不同语法，这两者相互独立：
///
/// - [isBegin] / [isEnd]：起始与结束界定符，[isEnd] 默认等于 [isBegin]，
///   适配 “起止都是相同界定符” 的语法（如代码块 ```` ``` ````、顶部元数据 `---`）；
///   起止不同的语法（如 HTML 注释 `<!--` / `-->`）重写 [isEnd] 即可。
///
/// - [allowSingleLine]：起始行能否在自身之内即闭合。
///   它与界定符是否对称无关，只是当起止界定符相同时必须为 `false`。
///
/// 子类通常只需声明 [isBegin]；
/// 起止界定符不同且允许单行的块再声明 [isEnd] 与  [allowSingleLine]。
abstract class DelimitedBlockParser extends TextParser {
  /// 块打开期间在 [ParseContext.currentType] 中占用的临时类型
  TextStructureType get blockType;

  /// 该行（已 trim）是否为起始界定符行
  bool isBegin(String lineTrim);

  /// 该行（已 trim）是否为结束界定符行，默认与起始相同（对称界定）。
  bool isEnd(String lineTrim) => isBegin(lineTrim);

  /// 起始行能否在自身之内即闭合（单行块）
  ///
  /// - 当起止界定符相同（[isEnd] 未重写）时 **必须** 为 `false`：
  ///   否则起始行必然同时满足 [isEnd] 而立刻闭合，块将永远退化为单行。
  ///
  /// - 当起止界定符不同时可设为 `true`：
  ///   一行内同时含起止界定符即单行块（如 `<!-- ... -->`），仅含起始界定符则会开启多行块。
  bool get allowSingleLine => false;

  /// 在当前位置是否允许开启块，默认任意位置可开启。
  ///
  /// （例如：顶部元数据重写为仅首行可开启。）
  bool canOpenAt(ParseContext context) => true;

  /// 收尾时确定最终类型，默认 [blockType]。重写以支持其他变体，例如：中文变体。
  TextStructureType resolveType(ParseContext context) => blockType;

  @override
  bool matchesLineStart(String line) => isBegin(line);

  @override
  ParseResult parse(ParseContext context) {
    final lineTrim = context.currentLineTrim;
    final isOpen = context.currentType == blockType;

    /// 未打开
    if (!isOpen) {
      /// 起始界定符行 -> 开启块
      if (!isBegin(lineTrim) || !canOpenAt(context)) {
        return ParseResult.notHandled;
      }
      context.currentType = blockType;
      context.startLineIndex = context.currentIndex;
      context.originalText.add(context.currentLine);

      /// 起始行内即闭合（由 [allowSingleLine] 控制）
      if (allowSingleLine && isEnd(lineTrim)) _finalize(context);
      return ParseResult.handled;
    }

    /// 已打开：纳入当前行，遇结束界定符则闭合
    context.originalText.add(context.currentLine);
    if (isEnd(lineTrim)) _finalize(context);
    return ParseResult.handled;
  }

  void _finalize(ParseContext context) {
    context.addStructure(
      TextStructure(
        type: resolveType(context),
        start: context.startLineIndex,
        end: context.currentIndex,
        originalText: context.originalText,
      ),
    );
    context.reset();
  }
}

/// 连续行块解析器类
///
/// 适用于 “若干连续行聚合为一个结构” 的多行块（表格、列表项、段落等）。
/// 子类声明：哪行开启块、纳入当前行后是否到达块尾、收尾类型。
abstract class RunBlockParser extends TextParser {
  /// 块打开期间在 [ParseContext.currentType] 中占用的临时类型
  TextStructureType get blockType;

  /// 该行（已 trim）是否开启本块。
  bool startsBlock(String lineTrim);

  /// 在 “已把当前行纳入块” 之后，是否应结束块。
  ///
  /// - [nextLineTrim] 下一行（已 trim，文末为 `null`）
  bool endsAfter(String? nextLineTrim, ParseContext context);

  /// 收尾时确定最终类型，默认 [blockType]。（例如重写以支持中文变体）
  TextStructureType resolveType(ParseContext context) => blockType;

  @override
  bool matchesLineStart(String line) => startsBlock(line);

  @override
  ParseResult parse(ParseContext context) {
    final isOpen = context.currentType == blockType;
    if (!isOpen && !startsBlock(context.currentLineTrim)) {
      return ParseResult.notHandled;
    }

    /// 开启块
    if (!isOpen) {
      context.currentType = blockType;
      context.startLineIndex = context.currentIndex;
    }

    /// 纳入当前行
    context.originalText.add(context.currentLine);

    /// 判定并收尾
    if (endsAfter(context.nextLineTrim, context)) {
      context.addStructure(
        TextStructure(
          type: resolveType(context),
          start: context.startLineIndex,
          end: context.currentIndex,
          originalText: context.originalText,
        ),
      );
      context.reset();
    }
    return ParseResult.handled;
  }
}
