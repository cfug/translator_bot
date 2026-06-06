import 'package:cfug_translator_bot/src/services/translation_service/model_session.dart';
import 'package:cfug_translator_bot/src/services/translation_service/models/translation_chunk_model.dart';
import 'package:cfug_translator_bot/src/services/translation_service/translation_service.dart';
import 'package:test/test.dart';

void main() {
  group('TranslationService :: 统一入口 ::', () {
    test('仅依赖注入的 ModelSession 即可编排整条流水线', () async {
      final session = _EchoModelSession();
      final result = await TranslationService(
        session,
        '# Hello\n\nWorld',
      ).run();

      /// 占位被译文回填，且结构（标题前缀）保持。
      expect(result, contains('# 译:Hello'));
      expect(result, contains('译:World'));

      /// 不残留模型输入格式或占位标记。
      expect(result, isNot(contains('<INPUT>')));

      /// 入口确实把批输入转交给了注入的会话。
      expect(session.calls, greaterThan(0));
    });

    test('空内容直接回退原文，且不调用模型', () async {
      final session = _EchoModelSession();
      final result = await TranslationService(session, '').run();
      expect(result, '');
      expect(session.calls, 0);
    });
  });
}

/// echo 模型会话
///
/// 解析编排器传入的 `<INPUT>...</INPUT>` 批输入，按其中的 `id`/`indentCount` 原样回填，
/// 文本加 `译:` 前缀，绕开占位 ID 的 UUID 非确定性。
class _EchoModelSession implements ModelSession {
  int calls = 0;

  static final _block = RegExp(r'<INPUT>\n(.*?)\n</INPUT>', dotAll: true);
  static final _id = RegExp(r'^id: (.*)$', multiLine: true);
  static final _indent = RegExp(r'^indentCount: (\d+)$', multiLine: true);
  static final _text = RegExp(r'^text: (.*)$', multiLine: true);

  @override
  Future<List<TranslationChunk>> translateBatch(String input) async {
    calls++;
    return _block.allMatches(input).map((match) {
      final body = match.group(1)!;
      return TranslationChunk(
        id: _id.firstMatch(body)!.group(1)!,
        indentCount: int.parse(_indent.firstMatch(body)!.group(1)!),
        text: '译:${_text.firstMatch(body)!.group(1)!}',
      );
    }).toList();
  }
}
