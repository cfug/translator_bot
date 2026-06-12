import 'package:cfug_translator_bot/src/services/translation_service/translation_exception.dart';
import 'package:test/test.dart';

void main() {
  group('TranslationException :: 脱敏 ::', () {
    test('命中的 key 被替换为 ***', () {
      final e = TranslationException(
        'request failed: ?key=AIzaSyA-secret-123',
        redact: ['AIzaSyA-secret-123'],
      );
      expect(e.message, 'request failed: ?key=***');
      expect(e.message, isNot(contains('AIzaSyA-secret-123')));
      expect(e.toString(), 'TranslationException: request failed: ?key=***');
    });

    test('同一 key 多处出现全部替换', () {
      final e = TranslationException(
        'key=SECRET retry key=SECRET',
        redact: ['SECRET'],
      );
      expect(e.message, 'key=*** retry key=***');
    });

    test('多个敏感串分别替换', () {
      final e = TranslationException('a=K1 b=K2', redact: ['K1', 'K2']);
      expect(e.message, 'a=*** b=***');
    });

    test('空串被跳过，不污染文本', () {
      final e = TranslationException('hello', redact: ['']);
      expect(e.message, 'hello');
    });

    test('未显式传入时自动脱敏常见敏感 key 字段', () {
      final e = TranslationException(
        'request failed: ?key=AIzaSyA-secret-123&other=1\n'
        'headers: {Authorization: Bearer sk-secret, x-api-key: openai-secret}',
      );

      expect(e.message, contains('?key=***&other=1'));
      expect(e.message, contains('Authorization: Bearer ***'));
      expect(e.message, contains('x-api-key: ***'));
      expect(e.message, isNot(contains('AIzaSyA-secret-123')));
      expect(e.message, isNot(contains('sk-secret')));
      expect(e.message, isNot(contains('openai-secret')));
    });
  });
}
