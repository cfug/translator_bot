import 'package:cfug_translator_bot/src/services/translation_service/reformat_text/reformat_text.dart';

import 'case.dart';

/// 对输入文本运行全部预处理，返回结果文本。
String reformat(String input) => ReformatText().run(input);

/// 运行 Case 的原始文本，返回预处理后的文本。
String getCaseText(ReformatCase testCase) => reformat(testCase.testText());
