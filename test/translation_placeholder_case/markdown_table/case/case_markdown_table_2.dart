import '../../case.dart';

class CaseMarkdownTable2 implements Case {
  /// Markdown 表格基础 2 - 跳过翻译
  const CaseMarkdownTable2();

  @override
  String testText() {
    return '''
| <t>Title</t><t>测试</t> | Title |
| --- | --- |
| Text | Text |
| 测试 | 测试 |
| Text | Text |
''';
  }

  @override
  String expectText() {
    return '''
| <t>Title</t><t>测试</t> | Title |
| --- | --- |
| Text | Text |
| 测试 | 测试 |
| Text | Text |
''';
  }
}
