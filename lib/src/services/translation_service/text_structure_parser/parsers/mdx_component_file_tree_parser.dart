import '../../enum.dart';
import '../text_parser.dart';

/// `<FileTree> ... </FileTree>` MDX/JSX 自定义组件（文件树）解析器
class MdxComponentFileTreeParser extends DelimitedBlockParser {
  /// 起始：`<FileTree>` 或带属性的 `<FileTree ...>`，但不匹配 `<FileTreeXxx>`。
  static final RegExp _begin = RegExp(r'^<FileTree(?:\s|>|$)');

  /// 结束：`</FileTree>`（允许结束尖括号前有空白）。
  static final RegExp _end = RegExp(r'^</FileTree\s*>');

  @override
  TextStructureType get blockType => TextStructureType.mdxComponentFileTree;

  @override
  bool isBegin(String lineTrim) => _begin.hasMatch(lineTrim);

  @override
  bool isEnd(String lineTrim) => _end.hasMatch(lineTrim);
}
