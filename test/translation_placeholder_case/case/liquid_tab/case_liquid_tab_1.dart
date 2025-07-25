import '../../../mock_uuid.dart';
import '../case.dart';

/// Liquid `{% tab "标题" %}` 语法 1
class CaseLiquidTab1 implements Case {
  @override
  String testDescription() => 'Liquid `{% tab "标题" %}` 语法基础 1';

  @override
  String testText() {
    return '''
{% tab "标题" %}

{% tab "Title" %}
''';
  }

  @override
  String expectData() {
    return '''
{% tab "标题" %}

<!-- {% tab "Title" %} -->
{% tab "${MockUuid.translationChunkId}" %}
''';
  }
}
