import 'package:cfug_translator_bot/src/services/translation_service/models/translation_chunk_model.dart';
import 'package:cfug_translator_bot/src/services/translation_service/placeholder_translator/batch_splitter.dart';
import 'package:cfug_translator_bot/src/services/translation_service/placeholder_translator/placeholder_translator.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:test/test.dart';

void main() {
  group('PlaceholderTranslator :: 编排 ::', () {
    test('无数据时返回 null，且不调用翻译', () async {
      var calls = 0;
      final translator = PlaceholderTranslator(
        translateBatch: (input) async {
          calls++;
          return const [];
        },
      );
      final result = await translator.translate(['line'], const []);
      expect(result, isNull);
      expect(calls, 0);
    });

    test('按批翻译并把译文回填', () async {
      /// 上限调小,强制两个块各自成批，验证：逐批调用 + 汇总。
      final translator = PlaceholderTranslator(
        splitter: const BatchSplitter(maxInputCount: 1),
        translateBatch: (input) async {
          if (input.contains('id: ID-1')) {
            return const [
              TranslationChunk(id: 'ID-1', indentCount: 0, text: '译:标题'),
            ];
          }
          return const [
            TranslationChunk(id: 'ID-2', indentCount: 0, text: '译:正文'),
          ];
        },
        onProgress: (_) {},
      );

      final result = await translator.translate(
        ['# ID-1', '', 'ID-2'],
        const [
          TranslationChunk(id: 'ID-1', indentCount: 0, text: 'Title'),
          TranslationChunk(id: 'ID-2', indentCount: 0, text: 'Body'),
        ],
      );
      expect(result, '# 译:标题\n\n译:正文');
    });

    test('单批翻译抛错时包装为 GenerativeAIException', () async {
      final translator = PlaceholderTranslator(
        translateBatch: (input) async => throw StateError('boom'),
        onProgress: (_) {},
      );
      expect(
        () => translator.translate(
          ['ID-1'],
          const [TranslationChunk(id: 'ID-1', indentCount: 0, text: 'x')],
        ),
        throwsA(isA<GenerativeAIException>()),
      );
    });
  });
}
