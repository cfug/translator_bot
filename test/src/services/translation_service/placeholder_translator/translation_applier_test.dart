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
}
