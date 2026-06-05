import 'package:cfug_translator_bot/src/services/translation_service/text_structure_parser/parsers/parsers.dart';
import 'package:cfug_translator_bot/src/services/translation_service/text_structure_parser/text_parser.dart';
import 'package:cfug_translator_bot/src/services/translation_service/text_structure_parser/text_structure_parser.dart';
import 'package:test/test.dart';

/// 将结构列表压缩为 `type:start-end` 的紧凑表示，便于断言。
List<String> repr(String input) => TextStructureParser()
    .parse(input)
    .map((s) => '${s.type.name}:${s.start}-${s.end}')
    .toList();

/// 默认块解析器（不含兜底段落），供顺序无关性测试构造乱序解析器。
List<TextParser> blockParsers() => <TextParser>[
  TopMetadataParser(),
  MarkdownCodeBlockParser(),
  BlankLineParser(),
  MarkdownHorizontalRuleParser(),
  MarkdownListItemParser(),
  MarkdownTitleParser(),
  MarkdownDefineLinkParser(),
  MarkdownImageParser(),
  MarkdownCustomAsideTypeParser(),
  MarkdownCustom1Parser(),
  MarkdownCustom2Parser(),
  Liquid1Parser(),
  HtmlTagParser(),
  HtmlCommentParser(),
  MarkdownTableParser(),
];

/// 用给定解析器列表解析并压缩为紧凑表示。
List<String> reprWith(TextStructureParser parser, String input) => parser
    .parse(input)
    .map((s) => '${s.type.name}:${s.start}-${s.end}')
    .toList();

void main() {
  group('TextStructureParser :: 段落边界（各类型相邻）::', () {
    test('段落后接空行', () {
      expect(repr('hello world\nsecond line\n\ntail'), [
        'paragraph:0-1',
        'blankLine:2-2',
        'paragraph:3-3',
      ]);
    });

    test('段落后接标题', () {
      expect(repr('a paragraph line\n# Heading'), [
        'paragraph:0-0',
        'markdownTitle:1-1',
      ]);
    });

    test('段落后接列表项', () {
      expect(repr('a paragraph line\n- item one\n- item two'), [
        'paragraph:0-0',
        'markdownListItem:1-1',
        'markdownListItem:2-2',
      ]);
    });

    test('段落后接代码块', () {
      expect(repr('a paragraph line\n```dart\nvar x = 1;\n```'), [
        'paragraph:0-0',
        'markdownCodeBlock:1-3',
      ]);
    });

    test('段落后接表格', () {
      expect(repr('a paragraph line\n| h1 | h2 |\n| --- | --- |\n| a | b |'), [
        'paragraph:0-0',
        'markdownTable:1-3',
      ]);
    });

    test('段落后接分割线', () {
      expect(repr('a paragraph line\n---'), [
        'paragraph:0-0',
        'markdownHorizontalRule:1-1',
      ]);
    });

    test('段落后接自定义 aside', () {
      expect(repr('a paragraph line\n:::note Title here\ncontent\n:::'), [
        'paragraph:0-0',
        'markdownCustomAsideTypeTitle:1-1',
        'paragraph:2-2',
        'markdownCustomAsideEnd:3-3',
      ]);
    });

    test('段落后接 Liquid', () {
      expect(repr('a paragraph line\n{% tab "X" %}'), [
        'paragraph:0-0',
        'liquid1:1-1',
      ]);
    });

    test('段落后接 HTML 标签', () {
      expect(repr('a paragraph line\n<div class="x">'), [
        'paragraph:0-0',
        'htmlTag:1-1',
      ]);
    });

    test('段落后接 HTML 注释', () {
      expect(repr('a paragraph line\n<!-- a comment -->'), [
        'paragraph:0-0',
        'htmlComment:1-1',
      ]);
    });

    test('多行 HTML 注释聚合为单个结构', () {
      expect(repr('<!-- line1\nline2\nline3 -->\ntail'), [
        'htmlComment:0-2',
        'paragraph:3-3',
      ]);
    });

    test('段落后接图片', () {
      expect(repr('a paragraph line\n![alt](http://x/y.png)'), [
        'paragraph:0-0',
        'markdownImage:1-1',
      ]);
    });

    test('段落后接定义链接', () {
      expect(repr('a paragraph line\n[ref]: http://example.com'), [
        'paragraph:0-0',
        'markdownDefineLink:1-1',
      ]);
    });

    test('段落后接自定义语法1 `{:x}`', () {
      expect(repr('a paragraph line\n{: .class }'), [
        'paragraph:0-0',
        'markdownCustom1:1-1',
      ]);
    });

    test('段落后接自定义语法2 `<?x`', () {
      expect(repr('a paragraph line\n<?php echo 1;'), [
        'paragraph:0-0',
        'markdownCustom2:1-1',
      ]);
    });
  });

  group('TextStructureParser :: 多块混合 ::', () {
    test('顶部元数据后接段落', () {
      expect(repr('---\ntitle: X\n---\n\nbody text\nmore body'), [
        'topMetadata:0-2',
        'blankLine:3-3',
        'paragraph:4-5',
      ]);
    });

    test('标题/段落/列表/表格/段落混合', () {
      const input =
          '# Title\n\nfirst para line\nsecond para line\n\n'
          '- list a\n- list b\n\n'
          '| c1 | c2 |\n| --- | --- |\n| 1 | 2 |\n\ntail para';
      expect(repr(input), [
        'markdownTitle:0-0',
        'blankLine:1-1',
        'paragraph:2-3',
        'blankLine:4-4',
        'markdownListItem:5-5',
        'markdownListItem:6-6',
        'blankLine:7-7',
        'markdownTable:8-10',
        'blankLine:11-11',
        'paragraph:12-12',
      ]);
    });
  });

  group('TextStructureParser :: 列表项边界（无空行紧接其他块）::', () {
    // 列表项边界改用 ParseContext.isLineClaimedByAny 判定：下一行若能被任意
    // 解析器认领为块起始，列表项即结束，而非把后续块吞入列表项。

    test('列表项后紧接标题', () {
      expect(repr('- item\n# Heading'), [
        'markdownListItem:0-0',
        'markdownTitle:1-1',
      ]);
    });

    test('列表项后紧接 HTML 标签', () {
      expect(repr('- item\n<div class="x">'), [
        'markdownListItem:0-0',
        'htmlTag:1-1',
      ]);
    });

    test('列表项后紧接表格', () {
      expect(repr('- item\n| a | b |\n| - | - |'), [
        'markdownListItem:0-0',
        'markdownTable:1-2',
      ]);
    });

    test('列表项续行（续行不被任何解析器认领）合并为一项', () {
      expect(repr('- item line1\n  continued line\n\ntail'), [
        'markdownListItem:0-1',
        'blankLine:2-2',
        'paragraph:3-3',
      ]);
    });
  });

  group('TextStructureParser :: 解析器顺序无关性（打开中的多行块优先调度）::', () {
    // 不含「有歧义起始行」（如 `---`、`- - -`）的输入：块解析器无论怎么排列，
    // 输出都应一致——因为多行块一旦打开即独占其内部行。
    const input =
        '# Heading\n'
        '\n'
        'intro paragraph line\n'
        'second line\n'
        '\n'
        '- item a\n'
        '- item b\n'
        '\n'
        '| h1 | h2 |\n'
        '| --- | --- |\n'
        '| a | b |\n'
        '\n'
        '```dart\n'
        'var x = 1;\n'
        '# not a heading inside code\n'
        '```\n'
        '\n'
        '<!-- a comment -->\n'
        '![img](http://u/i.png)\n'
        '{% liquid %}\n'
        'tail para';

    test('默认顺序的基准输出', () {
      expect(reprWith(TextStructureParser(), input), [
        'markdownTitle:0-0',
        'blankLine:1-1',
        'paragraph:2-3',
        'blankLine:4-4',
        'markdownListItem:5-5',
        'markdownListItem:6-6',
        'blankLine:7-7',
        'markdownTable:8-10',
        'blankLine:11-11',
        'markdownCodeBlock:12-15',
        'blankLine:16-16',
        'htmlComment:17-17',
        'markdownImage:18-18',
        'liquid1:19-19',
        'paragraph:20-20',
      ]);
    });

    test('逆序排列解析器，输出与默认一致', () {
      final reversed = TextStructureParser.custom(
        blockParsers().reversed.toList(),
      );
      expect(reprWith(reversed, input), reprWith(TextStructureParser(), input));
    });

    test('代码块内部以 # 开头的行不会被标题解析器抢走（逆序下亦然）', () {
      final reversed = TextStructureParser.custom(
        blockParsers().reversed.toList(),
      );
      // 代码块整体为单个结构 [12-15]，内部 `# not a heading` 不应单独成为标题。
      expect(reprWith(reversed, input), contains('markdownCodeBlock:12-15'));
      expect(
        reprWith(reversed, input).where((s) => s.startsWith('markdownTitle')),
        ['markdownTitle:0-0'],
      );
    });
  });
}
