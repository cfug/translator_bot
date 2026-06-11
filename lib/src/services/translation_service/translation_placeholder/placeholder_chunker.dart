import 'package:uuid/uuid.dart';

import '../enum.dart';
import '../models/translation_chunk_model.dart';
import '../text_structure_parser/models/text_structure_model.dart';

/// 占位处理器接口
///
/// 每个处理器负责一种 [TextStructureType] 的译文 ID 占位处理（参见 [type]）。
///
/// 一种结构可以对应多种特征的识别处理：编排器按结构类型查出该类型注册的处理器列表，
/// 依次调用 [chunk]，首个返回 `true` 的处理器认领该结构；
/// 若全部返回 `false`，编排器兜底复制原始行。
abstract class PlaceholderChunker {
  /// 本处理器负责的结构类型（用于在编排器中注册分组）
  TextStructureType get type;

  /// 处理当前结构（[PlaceholderContext.current]）的译文 ID 占位
  ///
  /// @return `true` 表示已认领并处理本结构；`false` 表示交给同类型的下一个处理器。
  bool chunk(PlaceholderContext context);
}

/// 占位处理上下文
///
/// 收敛各处理器共享的可变状态（占位后的原始行、占位块数据）与工具方法，
/// 由编排器持有并在遍历结构时更新 [index]。
class PlaceholderContext {
  PlaceholderContext({
    required this.uuid,
    required this.structures,
    required this.placeholderOriginalLines,
    required this.translationPlaceholderData,
    this.index = 0,
  });

  /// UUID 生成器（用于生成译文块 ID）
  final Uuid uuid;

  /// 整篇文本结构
  final List<TextStructure> structures;

  /// 译文 ID 占位修改后的原始行内容
  final List<String> placeholderOriginalLines;

  /// 译文 ID 占位块的数据
  final List<TranslationChunk> translationPlaceholderData;

  /// 当前结构索引
  int index;

  /// 当前结构
  TextStructure get current => structures[index];

  /// 相对当前结构偏移 [offset] 的结构（越界为 `null`）
  ///
  /// - [offset] 相对偏移：`1` 为下一个、`2` 为下两个；负数则向前回看。
  TextStructure? next([int offset = 1]) {
    final targetIndex = index + offset;
    return targetIndex >= 0 && targetIndex < structures.length
        ? structures[targetIndex]
        : null;
  }

  /// 生成译文块 ID
  String chunkId() => '#{TranslationChunkId-${uuid.v7()}}#';

  /// 添加一个译文块占位数据
  ///
  /// 生成译文块 ID、登记 [TranslationChunk]，并返回该 ID 供占位行使用。
  ///
  /// - [text] 需要翻译的内容
  /// - [indentCount] 缩进计数
  ///
  /// @return 生成的译文块 ID
  String addChunk(String text, {int indentCount = 0}) {
    final id = chunkId();
    translationPlaceholderData.add(
      TranslationChunk(id: id, indentCount: indentCount, text: text),
    );
    return id;
  }

  /// 添加一行占位后的原始内容
  void addLine(String line) => placeholderOriginalLines.add(line);

  /// 添加多行占位后的原始内容
  void addLines(Iterable<String> lines) =>
      placeholderOriginalLines.addAll(lines);

  /// 当下一个结构存在且不是空行时，补一个空行
  ///
  /// 用于在块占位后与后续内容之间保留空行间隔。
  void addBlankLineBeforeNext() {
    final textStructureNext = next();
    if (textStructureNext != null &&
        textStructureNext.type != TextStructureType.blankLine) {
      placeholderOriginalLines.add('');
    }
  }

  /// 缩进计数
  /// - [content] 获取文本缩进内容
  int indentCount(String content) {
    final regex = RegExp(r'^ *');
    final match = regex.firstMatch(content);
    return match?.end ?? 0;
  }

  /// 逐行去除行尾空白后比较两段文本是否等值
  static bool textEquals(String a, String b) {
    String normalize(String s) =>
        s.split('\n').map((line) => line.trimRight()).join('\n');
    return normalize(a) == normalize(b);
  }
}
