/// 文本预处理器接口
///
/// 每个实现是一个独立的「文本 → 文本」处理通道，互不共享状态。
/// 编排器 [ReformatText] 按列表顺序依次应用——与 `TextStructureParser` 不同，
/// 这里 **顺序即契约**（见 [ReformatText] 默认列表注释）。
abstract class TextReformatter {
  /// 对 [text] 执行一次预处理，返回处理后的文本。
  String reform(String text);
}

/// 标记行间隔家族基类（模板方法）
///
/// 适用于「在匹配某规则的行上方/下方补空行」的预处理（列表项、`:::`、liquid 注释……），
/// 目的是让后续 `TextStructureParser` 更容易识别块边界。
///
/// 子类只需声明：
///
/// - [matches]：某行（已 `trimLeft`）是否为目标标记行。
/// - [padBefore] / [padAfter]：是否在标记行上方 / 下方补空行（默认都补）。
///
/// 围栏代码块 ```` ``` ```` 内的行一律跳过，避免改写代码内容。
abstract class LineMarkerReformatter extends TextReformatter {
  /// 该行（已 `trimLeft`）是否为目标标记行。
  bool matches(String lineTrimLeft);

  /// 是否在标记行上方补空行。
  bool get padBefore => true;

  /// 是否在标记行下方补空行。
  bool get padAfter => true;

  @override
  String reform(String text) {
    final lines = text.split('\n');
    final result = <String>[];
    var inCodeBlock = false;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // 代码块边界：切换状态并原样保留。
      if (line.trimLeft().startsWith('```')) {
        inCodeBlock = !inCodeBlock;
        result.add(line);
        continue;
      }

      if (!inCodeBlock && matches(line.trimLeft())) {
        // 上方补空行：仅当上一行非空，避免连续空行。
        if (padBefore && result.isNotEmpty && result.last.trim().isNotEmpty) {
          result.add('');
        }
        result.add(line);
        // 下方补空行：仅当存在下一行且其非空。
        if (padAfter &&
            i < lines.length - 1 &&
            lines[i + 1].trim().isNotEmpty) {
          result.add('');
        }
      } else {
        result.add(line);
      }
    }

    return result.join('\n');
  }
}
