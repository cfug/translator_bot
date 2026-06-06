import 'package:cfug_translator_bot/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('Utils.hasChinese ::', () {
    test('含任意中文字符即为真', () {
      expect(Utils.hasChinese('hello 你'), isTrue);
      expect(Utils.hasChinese('纯中文'), isTrue);
    });

    test('无中文字符为假', () {
      expect(Utils.hasChinese('hello world'), isFalse);
      expect(Utils.hasChinese('{% tab "X" %}'), isFalse);
    });
  });

  group('Utils.isTranslated ::', () {
    test('纯中文判为已翻译', () {
      expect(Utils.isTranslated('这是一个中文段落'), isTrue);
      expect(Utils.isTranslated('# 中文标题'), isTrue);
    });

    test('纯英文判为未翻译', () {
      expect(Utils.isTranslated('More thoughts about performance'), isFalse);
      expect(Utils.isTranslated('# Heading'), isFalse);
    });

    test('长英文中夹少量中文术语判为未翻译', () {
      // 一段以英文为主、仅夹一个中文词的内容，应被视为待翻译原文
      expect(
        Utils.isTranslated(
          'This sentence uses the 范围 operator and is mostly English text.',
        ),
        isFalse,
      );
    });

    test('中文为主夹少量英文标识符判为已翻译（不误伤已译混排标题）', () {
      expect(Utils.isTranslated('## 使用 Provider'), isTrue);
      expect(Utils.isTranslated('## 参见 go_router'), isTrue);
      expect(Utils.isTranslated('[文本]\n<br> 文本'), isTrue);
    });

    test('无有意义字符（空/纯标点/纯数字）判为未翻译', () {
      expect(Utils.isTranslated(''), isFalse);
      expect(Utils.isTranslated('   '), isFalse);
      expect(Utils.isTranslated('--- 123 ...'), isFalse);
    });

    test('阈值边界：低于 10% 占比为未翻译，达到 10% 为已翻译', () {
      // 1 个中文 + 19 个拉丁字母 => 1/20 = 0.05 < 0.1 => 未翻译
      expect(Utils.isTranslated('一abcdefghijklmnopqrs'), isFalse);
      // 2 个中文 + 18 个拉丁字母 => 2/20 = 0.10 >= 0.1 => 已翻译
      expect(Utils.isTranslated('一二abcdefghijklmnopqr'), isTrue);
    });
  });
}
