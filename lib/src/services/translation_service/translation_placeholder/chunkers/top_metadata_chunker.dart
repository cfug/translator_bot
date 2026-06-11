import '../../enum.dart';
import '../placeholder_chunker.dart';

/// 文档顶部元数据中的 AI 翻译标记
const String topMetadataAiTranslatedFlag = 'ai-translated:';

/// 顶部元数据占位处理器
///
/// 逐行处理元数据，对 [_targetFields] 字段注释原文并插入译文占位，
/// 处理完成后在顶部元数据底部追加 AI 翻译标记。
///
/// 如果需要补充翻译，可以指定 [type] 注册类型，
/// 当顶部元数据已含中文时（[TextStructureType.chineseTopMetadata]），
/// 仍使用同一套逻辑（补译逻辑）。
class TopMetadataChunker extends PlaceholderChunker {
  TopMetadataChunker([this.type = TextStructureType.topMetadata]);

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

    /// 已出现的 `# <字段>:` 注释行所属字段名，
    /// 其后的同名字段是已译槽，应原样保留
    final commentedFields = <String>{};

    /// 按行处理
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineNext = i == lines.length - 1 ? null : lines[i + 1];

      /// 顶部元数据 - 开始
      if (i == 0 && line.trim() == '---') {
        context.addLine(line);
        continue;
      }

      /// 顶部元数据 - 结束
      if (i != 0 && line.trim() == '---') {
        if (!_aiTranslatedFlagExists(context)) {
          context.addLine('$topMetadataAiTranslatedFlag true');
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

          /// 标注当前行
          currentMetadataLineName = metadataName;
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
        /// 当前行不存在属性，表明为当前（未译）目标属性的续行（比如 `description` 的多行值）
        if (currentMetadataLineName != null) {
          /// 注释行
          context.addLine('# $line');
          currentMetadataLineValue.add(line.trim());
        } else {
          context.addLine(line);
        }
      }

      /// 下一行是否为新属性/已结束，如果是就代表需要翻译处理当前属性内容
      final lineNextHasField = (lineNext?.indexOf(':') ?? -1) >= 0;
      if ((lineNextHasField || lineNext?.trim() == '---') &&
          currentMetadataLineName != null) {
        /// 当前已存在属性，进行翻译块 ID 占位
        final translationChunkId = context.addChunk(
          currentMetadataLineValue.join(''),
        );
        context.addLine('$currentMetadataLineName: $translationChunkId');

        /// 清理标注
        currentMetadataLineName = null;
        currentMetadataLineValue = [];
      }
    }

    return true;
  }

  /// 全文是否已存在 AI 翻译标记，避免重跑重复追加
  bool _aiTranslatedFlagExists(PlaceholderContext context) {
    return context.structures.any(
      (structure) => structure.originalText.any(
        (line) => line.trim().startsWith(topMetadataAiTranslatedFlag),
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
