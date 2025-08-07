import 'package:cfug_translator_bot/src/services/translation_service/enum.dart';

import '../../../mock_uuid.dart';
import '../../case.dart';

class SkipParagraph implements Case {
  /// 跳过段落
  const SkipParagraph();

  @override
  String testText() {
    return '''
<!-- ${TextStructureType.htmlComment} -->
<!-- xxx -->

<!-- ${TextStructureType.markdownImage} -->
![xx](xxx)

<!-- ${TextStructureType.markdownDefineLink} -->
[xx]: xxx

<!-- ${TextStructureType.markdownHorizontalRule} -->
---

***

- - -

_ _ _

<!-- ${TextStructureType.markdownCodeBlock} -->
```
xxx
```

```xxx
xxx
```

<!-- ${TextStructureType.markdownCustomAsideEnd} -->

:::

<!-- ${TextStructureType.markdownCustom1} -->
{:xxx}

<!-- ${TextStructureType.markdownCustom2} -->
<?xxx>

<!-- ${TextStructureType.liquid1} -->
{% xxx %}

<!-- ${TextStructureType.htmlTag} -->
<h1>

xxx

</h1>
''';
  }

  @override
  String expectText() {
    return '''
<!-- ${TextStructureType.htmlComment} -->
<!-- xxx -->

<!-- ${TextStructureType.markdownImage} -->
![xx](xxx)

<!-- ${TextStructureType.markdownDefineLink} -->
[xx]: xxx

<!-- ${TextStructureType.markdownHorizontalRule} -->
---

***

- - -

_ _ _

<!-- ${TextStructureType.markdownCodeBlock} -->
```
xxx
```

```xxx
xxx
```

<!-- ${TextStructureType.markdownCustomAsideEnd} -->

:::

<!-- ${TextStructureType.markdownCustom1} -->
{:xxx}

<!-- ${TextStructureType.markdownCustom2} -->
<?xxx>

<!-- ${TextStructureType.liquid1} -->
{% xxx %}

<!-- ${TextStructureType.htmlTag} -->
<h1>

xxx

${MockUuid.translationChunkId}

</h1>
''';
  }
}
