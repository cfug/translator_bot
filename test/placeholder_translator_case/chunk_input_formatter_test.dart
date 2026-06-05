import 'package:cfug_translator_bot/src/services/translation_service/models/translation_chunk_model.dart';
import 'package:cfug_translator_bot/src/services/translation_service/placeholder_translator/chunk_input_formatter.dart';
import 'package:test/test.dart';

void main() {
  group('PlaceholderTranslator :: ChunkInputFormatter ::', () {
    const formatter = ChunkInputFormatter();

    test('单行内容格式化为 <INPUT> 块', () {
      const chunk = TranslationChunk(id: 'ID-1', indentCount: 0, text: 'Hello');
      expect(
        formatter.format(chunk),
        '<INPUT>\n'
        'id: ID-1\n'
        'indentCount: 0\n'
        'text: Hello\n'
        '</INPUT>\n'
        '\n',
      );
    });

    test('多行内容的换行折叠为字面 \\n', () {
      const chunk = TranslationChunk(
        id: 'ID-2',
        indentCount: 4,
        text: 'line1\nline2',
      );
      expect(
        formatter.format(chunk),
        '<INPUT>\n'
        'id: ID-2\n'
        'indentCount: 4\n'
        'text: line1\\nline2\n'
        '</INPUT>\n'
        '\n',
      );
    });
  });
}
