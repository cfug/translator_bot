import '../../../mock_uuid.dart';
import '../../case.dart';

class CaseLiquidTab1 implements Case {
  /// Liquid `{% tab "标题" %}` 语法基础 1
  const CaseLiquidTab1();

  @override
  String testText() {
    return '''
{% tab "Title" %}
''';
  }

  @override
  String expectText() {
    return '''
<!-- {% tab "Title" %} -->
{% tab "${MockUuid.translationChunkId}" %}
''';
  }
}
