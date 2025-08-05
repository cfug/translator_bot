import '../case.dart';

/// Markdown 表格基础 2 - 跳过翻译
class CaseMarkdownTable2 implements Case {
  @override
  String testDescription() => 'Markdown 表格基础 2 - 跳过翻译';

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
  String expectData() {
    return '''
| <t>Title</t><t>测试</t> | Title |
| --- | --- |
| Text | Text |
| 测试 | 测试 |
| Text | Text |
''';
  }
}
