import '../../../mock_uuid.dart';
import '../../case.dart';

class CaseHtmlTagTab1 implements Case {
  /// HTML 标签 `<Tab name="标题">` 语法基础 1
  const CaseHtmlTagTab1();

  @override
  String testText() {
    return '''
<Tab name="Title">
<Tab name='Title'>
<Tab name="标题">
<!-- <Tab name="Title"> -->
<Tab name="Title">
<Tab name="Title"> xxx
''';
  }

  @override
  String expectText() {
    return '''
<!-- <Tab name="Title"> -->
<Tab name="${MockUuid.translationChunkId}">
<!-- <Tab name='Title'> -->
<Tab name="${MockUuid.translationChunkId}">
<Tab name="标题">
<!-- <Tab name="Title"> -->
<!-- <Tab name="Title"> -->
<Tab name="${MockUuid.translationChunkId}">
<!-- <Tab name="Title"> xxx -->
<Tab name="${MockUuid.translationChunkId}"> xxx
''';
  }
}
