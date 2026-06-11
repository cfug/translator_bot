import 'package:uuid/uuid.dart';

import '../enum.dart';
import '../models/translation_chunk_model.dart';
import '../text_structure_parser/models/text_structure_model.dart';
import 'chunkers/chunkers.dart';
import 'placeholder_chunker.dart';

/// 译文占位符处理
///
/// 遍历整篇文本结构，按结构类型分发到对应的 [PlaceholderChunker]，
/// 在原始内容对应位置插入译文 ID 占位，便于之后翻译替换。
///
/// 处理器按结构类型注册（[_chunkersByType]）：同一类型可注册多个处理器，
/// 依次尝试，首个认领者胜出；任何处理器都不认领的类型，兜底复制原始行。
class TranslationPlaceholder {
  /// 译文占位符处理（使用默认处理器）
  TranslationPlaceholder(this.uuid)
    : _chunkersByType = _groupByType(_defaultChunkers());

  /// 译文占位符处理（自定义处理器列表）
  TranslationPlaceholder.custom(this.uuid, List<PlaceholderChunker> chunkers)
    : _chunkersByType = _groupByType(chunkers);

  final Uuid uuid;

  /// 译文 ID 占位修改后的原始行内容
  final List<String> placeholderOriginalLines = [];

  /// 译文 ID 占位块的数据
  final List<TranslationChunk> translationPlaceholderData = [];

  /// 按结构类型分组的处理器
  final Map<TextStructureType, List<PlaceholderChunker>> _chunkersByType;

  /// 默认处理器列表
  static List<PlaceholderChunker> _defaultChunkers() {
    return [
      TopMetadataChunker(),
      // 已含中文的顶部元数据共用同一套逻辑（补译逻辑）
      TopMetadataChunker(TextStructureType.chineseTopMetadata),
      MarkdownParagraphChunker(),
      MarkdownTitleChunker(),
      MarkdownListItemChunker(),
      MarkdownTableChunker(),
      MarkdownCustomAsideTypeTitleChunker(),
      LiquidTabChunker(),
      HtmlTagTabChunker(),
    ];
  }

  /// 将处理器按其负责的结构类型分组（保持列表内的相对顺序作为优先级）
  static Map<TextStructureType, List<PlaceholderChunker>> _groupByType(
    List<PlaceholderChunker> chunkers,
  ) {
    final map = <TextStructureType, List<PlaceholderChunker>>{};
    for (final chunker in chunkers) {
      map.putIfAbsent(chunker.type, () => []).add(chunker);
    }
    return map;
  }

  /// 译文 ID 占位处理
  ///
  /// 在 [textStructureList] 整篇文本结构中对应位置插入译文 ID 的占位，
  /// 便于之后翻译替换处理。
  ///
  /// - [textStructureList] 整篇文本结构
  void execute(List<TextStructure> textStructureList) {
    final context = PlaceholderContext(
      uuid: uuid,
      structures: textStructureList,
      placeholderOriginalLines: placeholderOriginalLines,
      translationPlaceholderData: translationPlaceholderData,
    );

    for (var i = 0; i < textStructureList.length; i++) {
      context.index = i;

      /// 按结构类型查出处理器，依次尝试
      final chunkers = _chunkersByType[context.current.type];
      var handled = false;
      if (chunkers != null) {
        for (final chunker in chunkers) {
          if (chunker.chunk(context)) {
            handled = true;
            break;
          }
        }
      }

      /// 兜底：无处理器认领该类型，原样复制原始行
      if (!handled) {
        context.addLines(context.current.originalText);
      }
    }
  }
}
