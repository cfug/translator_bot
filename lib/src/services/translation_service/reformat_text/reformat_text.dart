import 'reformatter.dart';
import 'reformatters/reformatters.dart';
import '../text_structure_parser/text_structure_parser.dart';

/// 文本预处理编排器
///
/// 按特定需求格式化内容，方便后续 [TextStructureParser] 分块识别。
/// 持有一组 [TextReformatter]，[run] 时按列表顺序依次应用
///
/// 预处理的顺序是重要的（见 [_defaultReformatters]）。
class ReformatText {
  /// 创建编排器（使用默认预处理器链）。
  ReformatText() : _reformatters = _defaultReformatters();

  /// 创建编排器（自定义预处理器链）。
  ReformatText.custom(List<TextReformatter> reformatters)
    : _reformatters = List.of(reformatters);

  /// 预处理器链
  final List<TextReformatter> _reformatters;

  /// 默认预处理器链
  ///
  /// **顺序重要**
  static List<TextReformatter> _defaultReformatters() {
    return [
      MarkdownListItemReformatter(),
      MarkdownThreeColonsReformatter(),
      LiquidCommentReformatter(),

      /// [MarkdownListItemReformatter] 会在 `- xxx` 插入空行，
      /// 因为 TopMetadata 可能会存在列表项，
      /// 所以必须由排在其后的 [TopMetadataReformatter] 收尾清理，
      /// 调换二者顺序会破坏格式。
      TopMetadataReformatter(),
    ];
  }

  /// 对 [text] 依次应用全部预处理器，返回处理后的文本。
  String run(String text) =>
      _reformatters.fold(text, (acc, reformatter) => reformatter.reform(acc));
}
