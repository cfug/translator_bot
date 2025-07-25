import 'package:uuid/data.dart';
import 'package:uuid/uuid.dart';

class MockUuid extends Uuid {
  @override
  String v7({V7Options? config}) {
    return 'MOCKUUID';
  }

  /// 译文块 ID
  static String get translationChunkId =>
      '#{TranslationChunkId-${MockUuid().v7()}}#';
}
