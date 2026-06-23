import 'package:cfug_translator_bot/src/services/translation_service/models/translation_chunk_model.dart';
import 'package:cfug_translator_bot/src/services/translation_service/placeholder_translator/translation_applier.dart';
import 'package:test/test.dart';

void main() {
  group('PlaceholderTranslator :: TranslationApplier ::', () {
    const applier = TranslationApplier();

    test('译文为空返回 null', () {
      expect(applier.apply(['line'], const []), isNull);
    });

    test('按 ID 回填译文', () {
      final result = applier.apply(
        ['# ID-1', '', 'ID-2'],
        const [
          TranslationChunk(id: 'ID-1', indentCount: 0, text: '标题'),
          TranslationChunk(id: 'ID-2', indentCount: 0, text: '正文'),
        ],
      );
      expect(result, '# 标题\n\n正文');
    });

    test('多行译文按缩进计数补齐每行并 trim', () {
      final result = applier.apply(
        ['ID-1'],
        const [
          TranslationChunk(id: 'ID-1', indentCount: 2, text: '  第一行\n第二行  '),
        ],
      );
      expect(result, '  第一行\n  第二行');
    });

    test('\\n（模型未把换行标记还原）回填为真换行并按缩进补齐', () {
      final result = applier.apply(
        ['ID-1'],
        const [
          // 输入阶段把换行折叠成 \n，模型原样返回（未还原）。
          TranslationChunk(id: 'ID-1', indentCount: 2, text: '第一行\\n第二行'),
        ],
      );
      expect(result, '  第一行\n  第二行');
    });

    test('同一 ID 多处出现时全部替换', () {
      final result = applier.apply(
        ['#{TranslationChunkId-a}#', '其他', '#{TranslationChunkId-a}#'],
        const [
          TranslationChunk(
            id: '#{TranslationChunkId-a}#',
            indentCount: 0,
            text: '译文',
          ),
        ],
      );
      expect(result, '译文\n其他\n译文');
    });

    test('译文数据中缺失的 ID（AI 漏译）原样保留', () {
      final result = applier.apply(
        ['#{TranslationChunkId-a}#', '#{TranslationChunkId-b}#'],
        const [
          // 只回了 a，缺 b
          TranslationChunk(
            id: '#{TranslationChunkId-a}#',
            indentCount: 0,
            text: '译文A',
          ),
        ],
      );
      expect(result, '译文A\n#{TranslationChunkId-b}#');
    });
  });

  group('PlaceholderTranslator :: TranslationApplier :: 省略相同译文 ::', () {
    const applier = TranslationApplier();

    test('dropLine 译文==原文：删占位行并删其上方空行', () {
      final result = applier.apply(
        ['iOS', '', 'ID-1'],
        const [TranslationChunk(id: 'ID-1', indentCount: 0, text: 'iOS')],
        originalPlaceholderData: const [
          TranslationChunk(
            id: 'ID-1',
            indentCount: 0,
            text: 'iOS',
            omitMode: OmitMode.dropLine,
          ),
        ],
      );
      expect(result, 'iOS');
    });

    test('dropLine 译文!=原文：照常回填', () {
      final result = applier.apply(
        ['iOS', '', 'ID-1'],
        const [TranslationChunk(id: 'ID-1', indentCount: 0, text: '译文')],
        originalPlaceholderData: const [
          TranslationChunk(
            id: 'ID-1',
            indentCount: 0,
            text: 'iOS',
            omitMode: OmitMode.dropLine,
          ),
        ],
      );
      expect(result, 'iOS\n\n译文');
    });

    test('dropLine 标题 `## ID` 整行删除', () {
      final result = applier.apply(
        ['## iOS', '', '## ID-1'],
        const [TranslationChunk(id: 'ID-1', indentCount: 0, text: 'iOS')],
        originalPlaceholderData: const [
          TranslationChunk(
            id: 'ID-1',
            indentCount: 0,
            text: 'iOS',
            omitMode: OmitMode.dropLine,
          ),
        ],
      );
      expect(result, '## iOS');
    });

    test('dropLine 漏译的占位不删除，原样保留', () {
      final result = applier.apply(
        ['iOS', '', 'ID-1'],
        // 译文里没有 ID-1（漏译），仅有无关项确保非空
        const [TranslationChunk(id: 'ID-X', indentCount: 0, text: 'x')],
        originalPlaceholderData: const [
          TranslationChunk(
            id: 'ID-1',
            indentCount: 0,
            text: 'iOS',
            omitMode: OmitMode.dropLine,
          ),
        ],
      );
      expect(result, 'iOS\n\nID-1');
    });

    test('collapseTableCell 译文==原文：收敛为 <t>原文</t>', () {
      final result = applier.apply(
        ['|<t>Title</t><t>ID-1</t>|<t>Title2</t><t>ID-2</t>|'],
        const [
          TranslationChunk(id: 'ID-1', indentCount: 0, text: 'Title'),
          TranslationChunk(id: 'ID-2', indentCount: 0, text: 'Title2'),
        ],
        originalPlaceholderData: const [
          TranslationChunk(
            id: 'ID-1',
            indentCount: 0,
            text: 'Title',
            omitMode: OmitMode.collapseTableCell,
          ),
          TranslationChunk(
            id: 'ID-2',
            indentCount: 0,
            text: 'Title2',
            omitMode: OmitMode.collapseTableCell,
          ),
        ],
      );
      expect(result, '|<t>Title</t>|<t>Title2</t>|');
    });

    test('collapseTableCell 译文!=原文：保留 <t>原文</t><t>译文</t>', () {
      final result = applier.apply(
        ['|<t>Title</t><t>ID-1</t>|<t>Title2</t><t>ID-2</t>|'],
        const [
          TranslationChunk(id: 'ID-1', indentCount: 0, text: '标题'),
          TranslationChunk(id: 'ID-2', indentCount: 0, text: '标题2'),
        ],
        originalPlaceholderData: const [
          TranslationChunk(
            id: 'ID-1',
            indentCount: 0,
            text: 'Title',
            omitMode: OmitMode.collapseTableCell,
          ),
          TranslationChunk(
            id: 'ID-2',
            indentCount: 0,
            text: 'Title2',
            omitMode: OmitMode.collapseTableCell,
          ),
        ],
      );
      expect(result, '|<t>Title</t><t>标题</t>|<t>Title2</t><t>标题2</t>|');
    });

    test('表体译文行整行都==原文：删除整行（不误删上方原文行）', () {
      final result = applier.apply(
        ['| Text | Text |', '|ID-1|ID-2|'],
        const [
          TranslationChunk(id: 'ID-1', indentCount: 0, text: 'Text'),
          TranslationChunk(id: 'ID-2', indentCount: 0, text: 'Text'),
        ],
        originalPlaceholderData: const [
          TranslationChunk(
            id: 'ID-1',
            indentCount: 0,
            text: 'Text',
            omitMode: OmitMode.dropLine,
          ),
          TranslationChunk(
            id: 'ID-2',
            indentCount: 0,
            text: 'Text',
            omitMode: OmitMode.dropLine,
          ),
        ],
      );
      expect(result, '| Text | Text |');
    });

    test('表体译文行部分==原文：保留整行并全部回填', () {
      final result = applier.apply(
        ['| Text | Other |', '|ID-1|ID-2|'],
        const [
          TranslationChunk(id: 'ID-1', indentCount: 0, text: 'Text'),
          TranslationChunk(id: 'ID-2', indentCount: 0, text: '其他'),
        ],
        originalPlaceholderData: const [
          TranslationChunk(
            id: 'ID-1',
            indentCount: 0,
            text: 'Text',
            omitMode: OmitMode.dropLine,
          ),
          TranslationChunk(
            id: 'ID-2',
            indentCount: 0,
            text: 'Other',
            omitMode: OmitMode.dropLine,
          ),
        ],
      );
      expect(result, '| Text | Other |\n|Text|其他|');
    });

    test('never 策略：译文==原文 仍照常回填（不删，避免删掉字段）', () {
      final result = applier.apply(
        ['# title: iOS', 'title: ID-1'],
        const [TranslationChunk(id: 'ID-1', indentCount: 0, text: 'iOS')],
        originalPlaceholderData: const [
          // 默认 never
          TranslationChunk(id: 'ID-1', indentCount: 0, text: 'iOS'),
        ],
      );
      expect(result, '# title: iOS\ntitle: iOS');
    });
  });
}
