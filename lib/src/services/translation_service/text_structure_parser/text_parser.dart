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
abstract class TextParser {
  /// 解析器优先级（数字越小优先级越高）
  int get priority;

  /// 尝试解析当前行
  ParseResult parse(ParseContext context);
}

/// 解析上下文
/// 用于在解析器之间共享状态
class ParseContext {
  ParseContext({
    required this.lines,
    this.currentIndex = 0,
    this.currentType = TextStructureType.none,
    this.startLineIndex = -1,
    List<String>? originalText,
    List<TextStructure>? results,
  }) : originalText = originalText ?? [],
       results = results ?? [];

  /// 所有行
  final List<String> lines;

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
}
