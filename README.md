> [!WARNING] 
> 目前处于 Beta 阶段。

<h1 align="center">CFUG Translator Bot</h1>

<p align="center">
  <img alt="Translator Bot v0.0.16" src="https://img.shields.io/badge/Translator Bot%20v0.0.16-159067?style=flat&logo=devbox&logoColor=FFFFFF"/>
  <a href="https://dart.dev/"><img alt="Dart v3.11" src="https://img.shields.io/badge/Dart%20v3.11-1A70B3?style=flat&logo=dart&logoColor=FFFFFF"/></a> 
</p>

使用 AI 翻译处理指定文档。

适用仓库：
- [cfug/flutter.cn](https://github.com/cfug/flutter.cn/blob/main/.github/workflows/translator_bot.yml)
- [cfug/dart.cn](https://github.com/cfug/dart.cn/blob/main/.github/workflows/translator_bot.yml)

## 配置

在需要使用的仓库中配置 [Github Action（参考）](./.github/workflows/translator_bot_template.yml)。

| 参数                                                         | 默认值                      | 可选项          | 说明                                                                                                                                                             |
| ------------------------------------------------------------ | --------------------------- | --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| model                                                        | `gemini`                    | gemini / openai | 模型协议，默认 `gemini`                                                                                                                                          |
| github_token                                                 | -                           | -               | 具有 repo 权限的 GitHub Token，用于访问评论内容和提交翻译结果。 <br/> Token 至少拥有以下权限：<br/> contents: write <br> issues: write <br> pull-requests: write |
| gemini_api_key <br/> <sup>**(model = gemini 时必填)**</sup>  | -                           | -               | Gemini API Key: https://aistudio.google.com/api-keys                                                                                                             |
| openai_api_key <br/> <sup>**(model = openai 时必填)</sup>**  | -                           | -               | OpenAI API Key，兼容 OpenAI API 协议都可使用。                                                                                                                   |
| openai_base_url <br/> <sup>**(model = openai 时可选)**</sup> | `https://api.openai.com/v1` | -               | OpenAI API 协议 Base URL，支持第三方部署的 OpenAI API 协议兼容端点。                                                                                             |

## 使用

在适用仓库的 issue 中评论来调用指令：

```md
# 评论：/translator-bot 仓库中文件的位置
/translator-bot ./src/xx.md
```

## 维护

### Prompt 调试

目前内部使用模型以及参数：
- Gemini: [gemini_service.dart](lib/src/services/model_service/gemini/gemini_service.dart)
- OpenAI: [openai_service.dart](lib/src/services/model_service/openai/openai_service.dart)

对应使用模型参数进行调试，各 Prompt 位于 [lib/src/prompts](lib/src/prompts)。

### 本地调试

在根目录新建 `.env` 文件（注意不要上传到公共环境），并添加以下内容：
```
GH_TOKEN = xxxxxxx
GEMINI_API_KEY = xxxxxxx
OPENAI_API_KEY = xxxxxxx
OPENAI_BASE_URL = xxxxxxx
```

调用以下指令：
```bash
# 例如：dart bin/translator.dart --dry-run --model gemini --repository cfug/flutter.cn --actionId 0 --issueId 0 --commentId 0 --filePath ./src/content/perf/appendix.md
$ dart bin/translator.dart --dry-run --model gemini --repository username/repo --actionId 0 --issueId 0 --commentId 0 --filePath xxxxxx
```
