import '../../case.dart';

/// 段落后紧接列表项：列表项上方补空行
class CaseListAfterParagraph implements ReformatCase {
  const CaseListAfterParagraph();

  @override
  String testText() => 'para\n- item';

  @override
  String expectText() => 'para\n\n- item';
}

/// 连续列表项：每个列表项上方都补空行（现有语义）
class CaseConsecutiveListItems implements ReformatCase {
  const CaseConsecutiveListItems();

  @override
  String testText() => '- a\n- b';

  @override
  String expectText() => '- a\n\n- b';
}

/// 代码块内的列表标记：不处理，原样保留
class CaseListInsideCodeBlock implements ReformatCase {
  const CaseListInsideCodeBlock();

  @override
  String testText() => '```dart\n- a\n```';

  @override
  String expectText() => '```dart\n- a\n```';
}
