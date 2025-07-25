import 'dart:io' as io;

import 'package:args/args.dart';
import 'package:github/github.dart';
import 'package:http/http.dart' as http;
import 'package:cfug_translator_bot/src/common.dart';
import 'package:cfug_translator_bot/src/services/gemini_service.dart';
import 'package:cfug_translator_bot/src/services/github_service.dart';
import 'package:cfug_translator_bot/translator.dart';

void main(List<String> arguments) async {
  final argParser = ArgParser();
  argParser.addFlag('dry-run', negatable: false, help: '只会执行翻译输出，但不会创建 PR 等操作');
  argParser.addFlag('help', abbr: 'h', negatable: false, help: '输出使用帮助');
  argParser.addOption('repository', help: '需要操作的 repo 如: username/repo');
  argParser.addOption('actionId', help: '当前运行的 Github Aciton ID');
  argParser.addOption(
    'issueId',
    help: 'Issue ID 如: https://github.com/x/x/issues/123 中的 123',
  );
  argParser.addOption(
    'commentId',
    help: 'Comment ID 如: https://github.com/x/x/issues/123 中评论的 ID',
  );
  argParser.addOption('filePath', help: '需要翻译的具体文件路径 如：./xx/xx.x');

  final ArgResults results;
  try {
    results = argParser.parse(arguments);
  } on ArgParserException catch (e) {
    print(e.message);
    print('');
    print(usage);
    print('');
    print(argParser.usage);
    io.exit(64);
  }

  if (results.flag('help')) {
    print(usage);
    print('');
    print(argParser.usage);
    io.exit(results.flag('help') ? 0 : 64);
  }

  final dryRun = results.flag('dry-run');
  final repository = results.option('repository') ?? '';
  final actionId = int.parse(results.option('actionId') ?? '-1');
  final issueId = int.parse(results.option('issueId') ?? '-1');
  final commentId = int.parse(results.option('commentId') ?? '-1');
  final filePath = results.option('filePath') ?? '';

  if (repository.isEmpty) {
    print('repository 不能为空');
    io.exit(64);
  }
  if (actionId == -1) {
    print('actionId 不能为空');
    io.exit(64);
  }
  if (issueId == -1) {
    print('issueId 不能为空');
    io.exit(64);
  }
  if (commentId == -1) {
    print('commentId 不能为空');
    io.exit(64);
  }
  if (filePath.isEmpty) {
    print('filePath 不能为空');
    io.exit(64);
  }

  final client = http.Client();
  final github = GitHub(
    auth: Authentication.withToken(githubToken),
    client: client,
  );
  final githubService = GithubService(github: github);
  final geminiService = GeminiService(apiKey: geminiKey, httpClient: client);

  await Translator(
    repository,
    actionId,
    issueId,
    commentId,
    filePath,
    dryRun: dryRun,
    githubService: githubService,
    geminiService: geminiService,
    logger: Logger(),
  ).run();

  client.close();
}

const String usage = '''
usage: dart bin/translator.dart --repository username/repo --actionId xxx --issueId xxx --commentId xxx --filePath xxx
''';
