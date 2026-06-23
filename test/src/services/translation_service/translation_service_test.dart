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

    test('专有名词译文与原文相同时跳过回填，不产生重复', () async {
      /// iOS 这类专有名词大模型返回与原文相同，应跳过回填，
      /// 普通标题仍正常双语回填。
      final session = _ProperNounModelSession({'iOS'});
      final result = await TranslationService(
        session,
        '## iOS\n\n## Hello',
      ).run();

      /// 普通标题仍双语回填（原文 + 下方译文）
      expect(result, contains('## Hello'));
      expect(result, contains('## 译:Hello'));

      /// 专有名词不产生重复：`## iOS` 仅出现一次
      expect('## iOS'.allMatches(result).length, 1);

      /// 不残留占位标记与模型输入格式
      expect(result, isNot(contains('<INPUT>')));
      expect(result, isNot(contains('TranslationChunkId')));
    });

    test('段落专有名词译文与原文相同时跳过回填，不产生重复', () async {
      final session = _ProperNounModelSession({'Flutter'});
      final result = await TranslationService(session, 'Flutter').run();

      /// 段落原文保留，且不回填相同译文（无重复、无 译: 前缀）
      expect('Flutter'.allMatches(result).length, 1);
      expect(result, isNot(contains('译:')));
    });

    test('表格：表头专有名词单元格收敛，表体整行同原文则删译文行', () async {
      final session = _ProperNounModelSession({'iOS'});
      final result = await TranslationService(
        session,
        '| Title | iOS |\n| --- | --- |\n| iOS | iOS |',
      ).run();

      /// 表头普通单元格保留双语 `<t>原文</t><t>译文</t>`
      expect(result, contains('<t>Title</t><t>译:Title</t>'));

      /// 表头专有名词单元格收敛为单 `<t>原文</t>`（其后不接译文 `<t>`）
      expect(result, contains('<t>iOS</t>'));
      expect(result, isNot(contains('<t>iOS</t><t>')));

      /// 表体原文行保留；整行同原文的译文行（无内部空格）被删除
      expect(result, contains('| iOS | iOS |'));
      expect(result, isNot(contains('|iOS|iOS|')));
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

/// 专有名词模型会话
///
/// 与 [_EchoModelSession] 同样解析 `<INPUT>` 批输入；但对 [properNouns] 中的原文
/// **原样返回**（模拟「大模型翻译结果与原文相同」），其余加 `译:` 前缀，
/// 用于验证「译文==原文」时跳过回填。
class _ProperNounModelSession implements ModelSession {
  _ProperNounModelSession(this.properNouns);

  final Set<String> properNouns;

  static final _block = RegExp(r'<INPUT>\n(.*?)\n</INPUT>', dotAll: true);
  static final _id = RegExp(r'^id: (.*)$', multiLine: true);
  static final _indent = RegExp(r'^indentCount: (\d+)$', multiLine: true);
  static final _text = RegExp(r'^text: (.*)$', multiLine: true);

  @override
  Future<List<TranslationChunk>> translateBatch(String input) async {
    return _block.allMatches(input).map((match) {
      final body = match.group(1)!;
      final text = _text.firstMatch(body)!.group(1)!;
      return TranslationChunk(
        id: _id.firstMatch(body)!.group(1)!,
        indentCount: int.parse(_indent.firstMatch(body)!.group(1)!),
        text: properNouns.contains(text) ? text : '译:$text',
      );
    }).toList();
  }
}
