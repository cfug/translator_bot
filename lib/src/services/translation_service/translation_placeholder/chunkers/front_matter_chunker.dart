import '../../enum.dart';
import '../placeholder_chunker.dart';

/// 文档顶部元数据中的 AI 翻译标记
const String frontMatterAiTranslatedFlag = 'ai-translated:';

/// 顶部元数据占位处理器
///
/// 逐行处理元数据，对 [_targetFields] 字段注释原文并插入译文占位，
/// 处理完成后在顶部元数据底部追加 AI 翻译标记。
///
/// 如果需要补充翻译，可以指定 [type] 注册类型，
/// 当顶部元数据已含中文时（[TextStructureType.chineseFrontMatter]），
/// 仍使用同一套逻辑（补译逻辑）。
class FrontMatterChunker extends PlaceholderChunker {
  FrontMatterChunker([this.type = TextStructureType.frontMatter]);

  /// 需要翻译的目标字段
  static const List<String> _targetFields = [
    'title',
    'short-title',
    'description',
  ];

  @override
  final TextStructureType type;

  @override
  bool chunk(PlaceholderContext context) {
    final lines = context.current.originalText;

    /// 当前正在识别的（未译）目标属性名称与内容
    String? currentMetadataLineName;
    var currentMetadataLineValue = <String>[];

    /// 当前目标属性所在行的缩进，用于按缩进识别其多行块值的续行
    var currentMetadataIndent = 0;

    /// 已出现的 `# <字段>:` 注释行所属字段名，
    /// 其后的同名字段是已译槽，应原样保留
    final commentedFields = <String>{};

    /// 结算当前目标属性：登记翻译块、写入占位行，随后清理标注
    void flushMetadata() {
      if (currentMetadataLineName == null) return;
      final translationChunkId = context.addChunk(
        currentMetadataLineValue.join(''),
      );
      context.addLine('$currentMetadataLineName: $translationChunkId');
      currentMetadataLineName = null;
      currentMetadataLineValue = [];
    }

    /// 按行处理
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      /// 顶部元数据 - 开始
      if (i == 0 && line.trim() == '---') {
        context.addLine(line);
        continue;
      }

      /// 多行块值的续行：在识别某目标属性期间，
      /// 缩进比该属性更深的行都属于其块值（如 `>-`/`>` 折叠块）。
      if (currentMetadataLineName != null &&
          line.trim() != '---' &&
          context.indentCount(line) > currentMetadataIndent) {
        context.addLine('# $line');
        currentMetadataLineValue.add(line.trim());
        continue;
      }

      /// 当前行不再属于上一目标属性的块值，先结算它
      flushMetadata();

      /// 顶部元数据 - 结束
      if (i != 0 && line.trim() == '---') {
        if (!_aiTranslatedFlagExists(context)) {
          context.addLine('$frontMatterAiTranslatedFlag true');
        }
        context.addLine(line);
        break;
      }

      /// 已注释的原文行（字段注释与续行注释）原样保留；
      /// 记录其字段名，使紧随的同名字段被识别为已译槽
      if (line.trimLeft().startsWith('#')) {
        context.addLine(line);
        final name = _commentedFieldName(line);
        if (name != null) commentedFields.add(name);
        continue;
      }

      /// 以首个冒号切分字段名与值（保住值中含冒号的情况，如 URL、`Foo: Bar`）
      final colonIndex = line.indexOf(':');
      final hasField = colonIndex >= 0;
      final metadataName = hasField ? line.substring(0, colonIndex) : line;

      if (hasField) {
        final metadataValue = line.substring(colonIndex + 1).trim();

        /// 存在父属性（无值，如 `tag:`）
        if (metadataValue == '') {
          context.addLine(line);
          continue;
        }

        /// 已译槽：前面已有同名 `# <字段>:` 注释 -> 原样保留、不重译
        if (commentedFields.contains(metadataName.trim())) {
          context.addLine(line);
          commentedFields.remove(metadataName.trim());
          continue;
        }

        /// 处理指定（未译）目标属性
        if (_targetFields.any((value) => metadataName.trim() == value)) {
          /// 注释行
          context.addLine('# $line');

          /// 标注当前行（记录缩进，供其后续行按缩进归并）
          currentMetadataLineName = metadataName;
          currentMetadataIndent = context.indentCount(line);
          if (metadataValue.startsWith('>-')) {
            currentMetadataLineValue.add(metadataValue.substring(2));
          } else if (metadataValue.startsWith('>')) {
            currentMetadataLineValue.add(metadataValue.substring(1));
          } else {
            currentMetadataLineValue.add(metadataValue);
          }
        } else {
          context.addLine(line);
        }
      } else {
        /// 既非块值续行（已在上方按缩进归并），又无字段冒号的孤立行，原样保留
        context.addLine(line);
      }
    }

    /// 兜底：元数据未以 `---` 正常闭合时，结算遗留的目标属性
    flushMetadata();

    return true;
  }

  /// 全文是否已存在 AI 翻译标记，避免重跑重复追加
  bool _aiTranslatedFlagExists(PlaceholderContext context) {
    return context.structures.any(
      (structure) => structure.originalText.any(
        (line) => line.trim().startsWith(frontMatterAiTranslatedFlag),
      ),
    );
  }

  /// 从 `# <字段>: ...` 注释行解析字段名，非字段注释（如续行）返回 `null`
  String? _commentedFieldName(String line) {
    final removeCommentSymbol = line
        .trimLeft()
        .replaceFirst('#', '')
        .trimLeft();
    final colonIndex = removeCommentSymbol.indexOf(':');
    if (colonIndex < 0) return null;
    final name = removeCommentSymbol.substring(0, colonIndex).trim();
    return name.isEmpty ? null : name;
  }
}
