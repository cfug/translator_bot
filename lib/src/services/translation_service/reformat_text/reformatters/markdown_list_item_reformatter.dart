import '../reformatter.dart';

/// Markdown 列表项预处理器
///
/// 在每个列表项（`* xxx`、`- xxx`、`+ xxx`、`1. xxx`）上方补一行空行；
/// 列表项之间不补下方空行，使整段列表保持为一个连续块。
///
/// 例外：
/// - `<FileTree> ... </FileTree>` 文件树组件内部的列表项不补空行，保持原有缩进结构。
class MarkdownListItemReformatter extends LineMarkerReformatter {
  static final RegExp _pattern = RegExp(r'^\s*([*+\-]|\d+\.)\s+');

  /// 文件树组件起止界定符（块内逐字保留，不补空行）。
  static final RegExp _fileTreeBegin = RegExp(r'^<FileTree(?:\s|>|$)');
  static final RegExp _fileTreeEnd = RegExp(r'^</FileTree\s*>');

  @override
  bool matches(String lineTrimLeft) => _pattern.hasMatch(lineTrimLeft);

  @override
  bool get padAfter => false;

  @override
  String reform(String text) {
    final lines = text.split('\n');
    final result = <String>[];
    final outside = <String>[];

    void flushOutside() {
      if (outside.isEmpty) return;
      result.addAll(super.reform(outside.join('\n')).split('\n'));
      outside.clear();
    }

    for (var i = 0; i < lines.length; i++) {
      if (!_fileTreeBegin.hasMatch(lines[i].trimLeft())) {
        outside.add(lines[i]);
        continue;
      }

      // 进入文件树块：先结算块外内容，再整块逐字保留至 `</FileTree>`。
      flushOutside();
      for (; i < lines.length; i++) {
        result.add(lines[i]);
        if (_fileTreeEnd.hasMatch(lines[i].trimLeft())) break;
      }
    }
    flushOutside();

    return result.join('\n');
  }
}
