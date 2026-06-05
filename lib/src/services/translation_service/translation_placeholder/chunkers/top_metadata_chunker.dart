import '../../enum.dart';
import '../placeholder_chunker.dart';

/// 顶部元数据占位处理器
///
/// 处理完元数据后，在其后追加文档顶部的翻译说明。
class TopMetadataChunker extends PlaceholderChunker {
  @override
  TextStructureType get type => TextStructureType.topMetadata;

  @override
  bool chunk(PlaceholderContext context) {
    final lines = context.current.originalText;

    /// 当前正在识别的元数据属性名称
    String? currentMetadataLineName;

    /// 当前正在识别的元数据属性内容
    var currentMetadataLineValue = <String>[];

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
        context.addLine(line);
        break;
      }

      /// 顶部元数据内容
      final metadataLine = line.split(':');
      final metadataName = metadataLine[0];

      /// 当前行存在属性
      if (metadataLine.length >= 2) {
        final metadataValue = metadataLine[1].trim();

        /// 存在父属性
        if (metadataValue == '') {
          context.addLine(line);
          continue;
        }

        /// 处理指定属性
        if ([
          'title',
          'short-title',
          'description',
        ].any((value) => metadataName.trim() == value)) {
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
        /// 当前行不存在属性，表明为当前属性的内容
        if (currentMetadataLineName != null) {
          /// 注释行
          context.addLine('# $line');
          currentMetadataLineValue.add(line.trim());
        } else {
          context.addLine(line);
        }
      }

      /// 下一行是否存在属性/已经结束，如果存在就代表需要翻译处理当前属性内容
      final metadataLineNext = lineNext?.split(':') ?? [];
      if ((metadataLineNext.length >= 2 || lineNext?.trim() == '---') &&
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

    context.addBlankLineBeforeNext();

    /// 顶部元数据之后补充翻译说明
    context.addLine(topMetadataTranslationNote);
    return true;
  }
}
