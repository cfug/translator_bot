import '../../../../mock_uuid.dart';
import '../../case.dart';

class CaseMarkdownTitle3 implements Case {
  /// Markdown 标题基础 3 - 译文无中文（如 `## API`）的重复防护
  ///
  /// `## API` 译后仍是 `## API`（无中文），重跑时若不识别为已译配对会不断累积重复。
  /// 期望：成对的两处（原文 + 等值译文）均跳过，独立未译标题仍补译。
  const CaseMarkdownTitle3();

  @override
  String testText() {
    return '''
## API

## API

## Standalone
''';
  }

  @override
  String expect() {
    return '''
## API

## API

## Standalone

## ${MockUuid.translationChunkId}
''';
  }
}
