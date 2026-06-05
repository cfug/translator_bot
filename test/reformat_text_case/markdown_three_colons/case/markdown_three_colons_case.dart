import '../../case.dart';

/// `:::` 块：上下各补空行
class CaseColonsAroundContent implements ReformatCase {
  const CaseColonsAroundContent();

  @override
  String testText() => 'para\n:::note\ntext\n:::';

  @override
  String expectText() => 'para\n\n:::note\n\ntext\n\n:::';
}

/// 代码块内的 `:::`：不处理，原样保留（修正：旧实现会误插空行）
class CaseColonsInsideCodeBlock implements ReformatCase {
  const CaseColonsInsideCodeBlock();

  @override
  String testText() => '```md\n:::note\n```';

  @override
  String expectText() => '```md\n:::note\n```';
}
