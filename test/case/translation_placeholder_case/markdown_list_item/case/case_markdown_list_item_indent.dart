import 'package:cfug_translator_bot/src/services/translation_service/models/translation_chunk_model.dart';

import '../../../../mock_uuid.dart';
import '../../case.dart';

class CaseMarkdownListItemIndent implements Case {
  /// Markdown 列表项基础 - 空格缩进
  const CaseMarkdownListItemIndent();

  @override
  String testText() {
    return r'''
  1.    Demo 1
  2.    Demo 2
''';
  }

  @override
  List<TranslationChunk> expect() {
    return [
      TranslationChunk(
        id: MockUuid.translationChunkId,
        indentCount: 8,
        text: 'Demo 1\n',
      ),
      TranslationChunk(
        id: MockUuid.translationChunkId,
        indentCount: 8,
        text: 'Demo 2\n',
      ),
    ];
  }
}
