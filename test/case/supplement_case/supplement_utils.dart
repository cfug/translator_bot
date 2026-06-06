import 'package:cfug_translator_bot/src/services/translation_service/reformat_text/reformat_text.dart';
import 'package:cfug_translator_bot/src/services/translation_service/text_structure_parser/text_structure_parser.dart';
import 'package:cfug_translator_bot/src/services/translation_service/translation_placeholder/translation_placeholder.dart';

import '../../mock_uuid.dart';
import 'case.dart';

/// 跑完整占位流水线（预处理 -> 解析结构 -> 译文 ID 占位），返回占位后的文本。
String getSupplementResult(Case testCase) {
  final content = ReformatText().run(testCase.testText());
  final structures = TextStructureParser().parse(content);
  final translationPlaceholder = TranslationPlaceholder(MockUuid())
    ..execute(structures);
  return translationPlaceholder.placeholderOriginalLines.join('\n');
}
