import '../translation_service/translation_exception.dart';
import '../translation_service/translation_service.dart';

/// 支持的模型协议类型
enum ModelType {
  /// Google Gemini 协议
  gemini,

  /// OpenAI 协议
  openai;

  /// 默认模型协议类型
  static const ModelType defaultType = ModelType.gemini;

  /// 由名称（如 CLI `--model` 的值）解析为模型类型。
  ///
  /// - [name] 模型名称（大小写不敏感，忽略首尾空白）
  ///
  /// 无法识别时抛出 [ArgumentError]。
  static ModelType fromName(String name) {
    final normalized = name.trim().toLowerCase();
    for (final type in ModelType.values) {
      if (type.name == normalized) return type;
    }
    throw ArgumentError.value(
      name,
      'name',
      '未知模型协议类型，支持: ${ModelType.values.map((type) => type.name).join(', ')}',
    );
  }
}

/// 模型服务接口
///
/// 对接不同模型协议（Gemini / OpenAI / ...）实现本接口。
///
/// 对外暴露错误 [TranslationException]，供上层统一处理。
abstract interface class ModelService {
  /// 调用 translator 分块处理
  ///
  /// 内部通常需要调用 [TranslationService] 的翻译功能（如构造请求时的系统提示）.
  ///
  /// - [text] 需要处理的内容
  ///
  /// @return
  /// - `outputText` 全部输出内容
  /// - `totalTokenCount` 当前消耗的总 Token
  Future<({String outputText, int totalTokenCount})> translatorChunk(
    String text,
  );
}
