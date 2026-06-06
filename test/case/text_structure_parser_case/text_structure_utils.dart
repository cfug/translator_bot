import 'package:cfug_translator_bot/src/services/translation_service/text_structure_parser/text_structure_parser.dart';

import 'case.dart';

/// 用默认解析器解析文本，压缩为 `type:start-end` 的紧凑表示，便于断言。
List<String> repr(String input) => TextStructureParser()
    .parse(input)
    .map((s) => '${s.type.name}:${s.start}-${s.end}')
    .toList();

/// 解析 Case 的测试文本，返回默认解析器下的紧凑结构表示。
List<String> getCaseStructures(Case testCase) => repr(testCase.testText());
