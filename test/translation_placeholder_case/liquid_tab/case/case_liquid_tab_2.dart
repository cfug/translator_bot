import '../../../mock_uuid.dart';
import '../../case.dart';

class CaseLiquidTab2 implements Case {
  /// Liquid `{% tab "标题" %}` 语法 2 - 跳过翻译
  const CaseLiquidTab2();

  @override
  String testText() {
    return '''
{% tab "标题" %}

{% tab "Title" %}
''';
  }

  @override
  String expectText() {
    return '''
{% tab "标题" %}

<!-- {% tab "Title" %} -->
{% tab "${MockUuid.translationChunkId}" %}
''';
  }
}
