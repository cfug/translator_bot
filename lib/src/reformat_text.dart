class ReformatText {
  /// 按特定需求格式化内容，方便分块处理识别。
  ReformatText(this.text);

  String text;

  String all() =>
      markdownListItem()
          .markdownThreeColons()
          .liquidComment()
          .removeTopMetadataLineBreaks()
          .text;

  /// Markdown 列表项
  ///
  /// 在每个列表项上方加一行换行
  ReformatText markdownListItem() {
    // 列表项正则
    final listPattern = RegExp(r'^\s*([*+\-]|\d+\.)\s+');
    final List<String> lines = text.split('\n');
    final List<String> modifiedLines = [];
    bool inCodeBlock = false; // 标记是否在代码块中

    for (final String currentLine in lines) {
      // 检测代码块边界
      if (currentLine.trimLeft().startsWith('```')) {
        inCodeBlock = !inCodeBlock;
        modifiedLines.add(currentLine);
        continue;
      }

      if (inCodeBlock) {
        // 代码块内的内容直接添加，不处理
        modifiedLines.add(currentLine);
      } else {
        // 非代码块内容处理列表项
        final bool isListLine = listPattern.hasMatch(currentLine);

        if (isListLine) {
          // 在列表项前添加空行（确保前一行非空）
          if (modifiedLines.isNotEmpty &&
              modifiedLines.last.trim().isNotEmpty) {
            modifiedLines.add('');
          }
        }
        modifiedLines.add(currentLine);
      }
    }

    text = modifiedLines.join('\n');

    return this;
  }

  /// Markdown 自定义 `:::` 块语法
  ///
  /// 在 `:::` 上方和下方加一行换行
  ReformatText markdownThreeColons() {
    final List<String> lines = text.split('\n');
    final List<String> modifiedLines = [];

    for (int i = 0; i < lines.length; i++) {
      final currentLine = lines[i];
      final isColonLine = currentLine.trimLeft().startsWith(':::');

      if (isColonLine) {
        // 处理前空行：如果前一行非空，则添加空行
        if (modifiedLines.isNotEmpty && modifiedLines.last.trim().isNotEmpty) {
          modifiedLines.add('');
        }

        modifiedLines.add(currentLine);

        // 处理后空行：如果后一行非空并且当前行不是末行，则添加空行
        if (i < lines.length - 1 &&
            lines[i + 1].trim().isNotEmpty &&
            i != lines.length - 1) {
          modifiedLines.add('');
        }
      } else {
        modifiedLines.add(currentLine);
      }
    }

    text = modifiedLines.join('\n');

    return this;
  }

  /// Liquid 自定义 `{% comment %}` `{% endcomment %}` 块语法
  ///
  /// 在上方和下方加一行换行
  ReformatText liquidComment() {
    final List<String> lines = text.split('\n');
    final List<String> modifiedLines = [];

    for (int i = 0; i < lines.length; i++) {
      final currentLine = lines[i];
      final currentLineTrimLeft = currentLine.trimLeft();
      final preLine = i == 0 ? null : lines[i - 1];
      final nextLine = i == lines.length - 1 ? null : lines[i + 1];

      final isCommentLine1 = currentLineTrimLeft.startsWith('{% comment');
      final isCommentLine2 = currentLineTrimLeft.startsWith('{%- comment');
      final isCommentLine3 = currentLineTrimLeft.startsWith('{% endcomment');
      final isCommentLine4 = currentLineTrimLeft.startsWith('{%- endcomment');

      if (isCommentLine1 ||
          isCommentLine2 ||
          isCommentLine3 ||
          isCommentLine4) {
        // 处理前空行：如果前一行非空，则添加空行
        if (preLine != null && preLine.trim().isNotEmpty) {
          modifiedLines.add('');
        }

        modifiedLines.add(currentLine);

        // 处理后空行：如果后一行非空并且当前行不是末行，则添加空行
        if (nextLine != null && nextLine.trim().isNotEmpty) {
          modifiedLines.add('');
        }
      } else {
        modifiedLines.add(currentLine);
      }
    }

    text = modifiedLines.join('\n');

    return this;
  }

  /// 移除顶部元数据多余的换行符
  ReformatText removeTopMetadataLineBreaks() {
    // 匹配顶部的 --- 块，
    // 确保结束的 --- 后紧跟换行或结尾
    final frontMatterPattern = RegExp(
      r'^---\r?\n(.*?)\r?\n---(?=\r?\n|$)',
      dotAll: true,
    );

    text = text.replaceFirstMapped(frontMatterPattern, (Match match) {
      final content = match.group(1);
      if (content != null) {
        final cleanedContent = content
            .split('\n')
            .where((line) => line.trim().isNotEmpty) // 过滤所有空行
            .join('\n');

        return '---\n$cleanedContent\n---';
      }
      return '';
    });

    return this;
  }
}
