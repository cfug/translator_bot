import '../../case.dart';

/// `{% comment %}` 块：上下各补空行
class CaseCommentBlock implements ReformatCase {
  const CaseCommentBlock();

  @override
  String testText() => 'para\n{% comment %}\nhidden\n{% endcomment %}';

  @override
  String expectText() => 'para\n\n{% comment %}\n\nhidden\n\n{% endcomment %}';
}

/// `{%- comment -%}` 连字符变体：同样补空行
class CaseCommentDashVariant implements ReformatCase {
  const CaseCommentDashVariant();

  @override
  String testText() => 'x\n{%- comment -%}\ny\n{%- endcomment -%}';

  @override
  String expectText() => 'x\n\n{%- comment -%}\n\ny\n\n{%- endcomment -%}';
}

/// 代码块内的 `{% comment %}`：不处理，原样保留（修正：旧实现会误插空行）
class CaseCommentInsideCodeBlock implements ReformatCase {
  const CaseCommentInsideCodeBlock();

  @override
  String testText() => '```liquid\n{% comment %}\n```';

  @override
  String expectText() => '```liquid\n{% comment %}\n```';
}
