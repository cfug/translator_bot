import 'package:cfug_translator_bot/src/services/translation_service/models/translation_chunk_model.dart';
import 'package:cfug_translator_bot/src/services/translation_service/placeholder_translator/batch_splitter.dart';
import 'package:test/test.dart';

void main() {
  group('PlaceholderTranslator :: BatchSplitter ::', () {
    test('空列表返回空批次', () {
      const splitter = BatchSplitter();
      expect(splitter.split(const []), isEmpty);
    });

    test('内容未超上限时合并为单批', () {
      const splitter = BatchSplitter();
      final chunks = [
        const TranslationChunk(id: 'a', indentCount: 0, text: 'x'),
        const TranslationChunk(id: 'b', indentCount: 0, text: 'y'),
      ];
      final batches = splitter.split(chunks);
      expect(batches, hasLength(1));
      // 单批应包含两个块的格式化输入
      expect(batches.first, contains('id: a'));
      expect(batches.first, contains('id: b'));
    });

    test('内容超过上限时切分为多批（达到上限即收口当前批）', () {
      // 调小上限,强制每个块单独成批。
      const splitter = BatchSplitter(maxInputCount: 1);
      final chunks = [
        const TranslationChunk(id: 'a', indentCount: 0, text: 'x'),
        const TranslationChunk(id: 'b', indentCount: 0, text: 'y'),
        const TranslationChunk(id: 'c', indentCount: 0, text: 'z'),
      ];
      final batches = splitter.split(chunks);
      expect(batches, hasLength(3));
      expect(batches[0], contains('id: a'));
      expect(batches[1], contains('id: b'));
      expect(batches[2], contains('id: c'));
    });
  });
}
