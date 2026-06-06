import 'package:cfug_translator_bot/src/services/model_service/model_service.dart';
import 'package:test/test.dart';

void main() {
  group('ModelType ::', () {
    test('默认模型为 gemini', () {
      expect(ModelType.defaultType, ModelType.gemini);
    });

    test('按名称解析', () {
      expect(ModelType.fromName('gemini'), ModelType.gemini);
      expect(ModelType.fromName('openai'), ModelType.openai);
    });

    test('大小写不敏感、忽略首尾空白', () {
      expect(ModelType.fromName('GEMINI'), ModelType.gemini);
      expect(ModelType.fromName('  Gemini '), ModelType.gemini);
    });

    test('未知模型抛 ArgumentError', () {
      expect(() => ModelType.fromName('xxxxxx'), throwsArgumentError);
      expect(() => ModelType.fromName(''), throwsArgumentError);
    });
  });
}
