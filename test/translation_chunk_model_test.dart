import 'package:cfug_translator_bot/src/services/translation_service/models/translation_chunk_model.dart';
import 'package:test/test.dart';

void main() {
  group('TranslationChunk.fromJson ::', () {
    test('合法 JSON 解析为强类型字段', () {
      final chunk = TranslationChunk.fromJson({
        'id': 'ID-1',
        'indentCount': 2,
        'text': '你好',
      });
      expect(chunk.id, 'ID-1');
      expect(chunk.indentCount, 2);
      expect(chunk.text, '你好');
    });

    test('字段类型错误时抛出(fail-fast)', () {
      expect(
        () => TranslationChunk.fromJson({
          'id': 'ID-1',
          'indentCount': '2', // 应为 int
          'text': '你好',
        }),
        throwsA(isA<TypeError>()),
      );
    });

    test('字段缺失时抛出(fail-fast)', () {
      expect(
        () => TranslationChunk.fromJson({'id': 'ID-1', 'text': '你好'}),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
