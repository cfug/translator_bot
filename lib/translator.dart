import 'dart:io';

import 'package:github/github.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'src/common.dart';
import 'src/gemini.dart';
import 'src/github.dart';

/// Bot 任务状态
enum BotState { none, running, success, error }

class Translator {
  /// Translator
  /// - [repository]  需要操作的 repo，如 `username/repo`
  /// - [actionId]    当前运行的 Github Aciton ID
  /// - [issueId]     评论位于的 Issue ID
  /// - [commentId]   评论的 ID
  /// - [filePath]    需要翻译的文件具体路径 './src/xxx/xx.xx'
  Translator(
    this.repository,
    this.actionId,
    this.issueId,
    this.commentId,
    this.filePath, {
    this.dryRun = false,
    required this.githubService,
    required this.geminiService,
    required this.logger,
  });

  final GithubService githubService;
  final GeminiService geminiService;
  final Logger logger;

  /// 需要操作的 repo，如 `username/repo`
  final String repository;

  /// 当前运行的 Github Aciton ID
  final int actionId;

  /// 评论位于的 Issue ID
  final int issueId;

  /// 评论的 ID
  final int commentId;

  /// 需要翻译的文件具体路径 './src/xxx/xx.xx'
  final String filePath;

  /// 试运行（只获取最终生成的内容，不进行其他操作，如 Github 反馈评论等）
  final bool dryRun;

  /// 触发的评论信息
  IssueComment? issueComment;

  /// Bot 的评论信息
  IssueComment? botIssueComment;

  RepositorySlug get repoSlug => RepositorySlug.full(repository);
  String get botTitle => '[translator bot]';
  String get actionHtmlUrl =>
      '[链接](https://github.com/${repoSlug.fullName}/actions/runs/$actionId)';

  /// 评论内容 - 由谁触发操作
  /// - [isAt] 是否触发 @，以提醒触发者
  String? footerTriggeredComment({bool isAt = false}) {
    if (issueComment == null) return null;
    return '🚀 本次操作由 ${isAt ? "@${issueComment!.user?.login} - " : ""}${issueComment!.htmlUrl} 触发。';
  }

  /// 获取触发的评论信息
  Future<void> initIssueCommentInfo() async {
    if (dryRun || issueComment != null) return;
    issueComment = await githubService.fetchIssueComment(repoSlug, commentId);
    if (issueComment?.id == null) {
      stderr.writeln('❌ 获取评论失败');
      exit(1);
    }
  }

  /// Bot 创建初始评论 - 正在运行
  Future<void> initBotStateIssueComment() async {
    if (dryRun || botIssueComment != null) return;
    await initIssueCommentInfo();
    botIssueComment = await githubService.createIssueComment(
      repoSlug,
      issueId,
      '⚙️ **$botTitle** - 任务进行中... \n'
      '💬 **Github Action:** $actionHtmlUrl \n'
      '\n'
      '${footerTriggeredComment()}',
    );
    if (botIssueComment?.id == null) {
      stderr.writeln('❌ 初始评论创建失败');
      exit(1);
    }
  }

  /// Bot 修改评论 - 任务状态
  /// - [botState] Bot 当前任务状态
  /// - [body] 主体信息
  /// - [footer] 底部信息
  Future<void> updateBotStateIssueComment(
    BotState botState,
    String body, {
    String footer = '',
  }) async {
    if (dryRun || issueComment == null || botIssueComment == null) return;
    final stateIcon = switch (botState) {
      BotState.none => '🪄',
      BotState.running => '⚙️',
      BotState.success => '✅',
      BotState.error => '🚫',
    };
    final stateText = switch (botState) {
      BotState.none => '',
      BotState.running => '- 任务进行中...',
      BotState.success => '- 任务完成',
      BotState.error => '- 任务失败',
    };
    await githubService.updateIssueComment(
      repoSlug,
      botIssueComment!.id!,
      '$stateIcon **$botTitle** $stateText \n'
      '$body'
      '\n'
      '${footerTriggeredComment(isAt: [BotState.success, BotState.error].contains(botState))}'
      '\n$footer',
    );
  }

  /// 运行
  Future<void> run() async {
    logger.log('📦 Repository: $repoSlug');
    logger.log(' ');

    /// 获取仓库信息
    final repositoryInfo = await githubService.fetchRepository(repoSlug);

    /// Bot 创建初始评论 - 正在运行
    await initBotStateIssueComment();

    /// 获取指定文件内容
    RepositoryContents? fileContents;
    try {
      fileContents = await githubService.fetchFileContents(
        repoSlug,
        filePath.trim(),
      );
    } finally {
      if (fileContents == null ||
          !fileContents.isFile ||
          fileContents.file == null) {
        await updateBotStateIssueComment(
          BotState.error,
          '💬 未找到指定文件 \n'
          '$emojiGap**Github Action:** $actionHtmlUrl \n',
        );
        stderr.writeln('❓ 未找到指定文件');
        exit(1);
      }
    }

    /// 文件内容
    final String fileText = fileContents.file!.text;

    /// 已翻译的文本
    String translatedText;

    /// 总消耗的 Token
    int totalTokenCount = 0;

    try {
      /// 分块进行翻译
      final translatorChunkResult = await geminiService.translatorChunk(
        fileText,
      );
      if (translatorChunkResult == null) {
        await updateBotStateIssueComment(
          BotState.error,
          '💬 AI 生成发生错误 \n'
          '$emojiGap**Github Action:** $actionHtmlUrl \n',
        );
        stderr.writeln('❌ gemini error: 准备语句不符合预期');
        exit(1);
      }
      translatedText = translatorChunkResult.outputText;
      totalTokenCount = translatorChunkResult.totalTokenCount;
    } on GenerativeAIException catch (e) {
      await updateBotStateIssueComment(
        BotState.error,
        '💬 AI 生成发生错误 \n'
        '$emojiGap**Github Action:** $actionHtmlUrl \n',
      );
      stderr.writeln('❌ gemini error: $e');
      exit(1);
    }

    logger.log('------ Translated Text ------');
    final translatedTextLines =
        translatedText.split('\n').where((l) => l.trim().isNotEmpty).toList();
    for (final line in translatedTextLines.take(15)) {
      logger.log(line);
    }
    if (translatedTextLines.length > 15) {
      logger.log('...');
    }
    logger.log('-----------------------------');
    logger.log(' ');

    if (dryRun) {
      logger.log('🫸 Exiting (dry run mode - not applying changes).');
      return;
    }

    /// 操作 Github
    logger.log('------ Github ------');
    logger.log(' ');

    final moreInfo =
        '<details>\n'
        '<summary>更多信息</summary>\n'
        '\n'
        '- **Github Action:** $actionHtmlUrl \n'
        '- **消耗 Token 总数:** $totalTokenCount \n'
        '  **参考 Token 限制:** 1000000/分钟 \n'
        '\n'
        '\n</details>';

    /// 创建 branch
    /// TODO(Amos): 不能是相同的 branch，再加点判断
    final refTimeStamp = DateTime.now().millisecondsSinceEpoch;
    final branchName = 'translator-bot-$issueId-$refTimeStamp';
    GitReference? gitBranch;
    try {
      logger.log('⚙️ 分支创建');
      gitBranch = await githubService.createBranch(repoSlug, branchName);
    } finally {
      if (gitBranch == null || gitBranch.ref == null) {
        await updateBotStateIssueComment(
          BotState.error,
          '💬 Github 运行错误 \n'
          '$emojiGap**Github Action:** $actionHtmlUrl \n',
        );
        stderr.writeln('❌ 分支创建失败');
        exit(1);
      }
      logger.log('✅ 分支创建完成');
    }

    /// 修改文件
    final fileSha = fileContents.file?.sha ?? '';
    ContentCreation? updateFileResult;
    try {
      logger.log('⚙️ 指定文件修改');
      updateFileResult = await githubService.updateFile(
        repoSlug,
        filePath,
        translatedText,
        '🪄 $botTitle Update $filePath',
        fileSha,
        branch: branchName,
      );
    } catch (_) {
      await updateBotStateIssueComment(
        BotState.error,
        '💬 Github 运行错误 \n'
        '$emojiGap**Github Action:** $actionHtmlUrl \n',
      );
      stderr.writeln('❌ 指定文件修改失败');
      exit(1);
    }

    /// 未修改文件
    if (updateFileResult.commit == null) {
      logger.log('💬 指定文件未修改');
      await githubService.deleteBranch(repoSlug, branchName);
      await updateBotStateIssueComment(
        BotState.success,
        '💬 与原文没有差异，未修改文件。 \n',
        footer: moreInfo,
      );
      return;
    } else {
      logger.log('✅ 指定文件修改完成');
    }

    /// 创建 PR
    PullRequest? pullRequest;
    try {
      logger.log('⚙️ PR 创建');
      pullRequest = await githubService.createPullRequests(
        repoSlug,
        '🪄 [translator bot] $filePath',
        branchName,
        repositoryInfo.defaultBranch,
        draft: true,
        body:
            '🪄 **$botTitle** \n'
            '💬 本内容由 AI 翻译，\n'
            '$emojiGap请检查格式以及翻译内容是否有误。\n'
            '\n'
            '${footerTriggeredComment(isAt: true)} \n $moreInfo',
      );
    } catch (_) {
      await updateBotStateIssueComment(
        BotState.error,
        '💬 Github 运行错误 \n'
        '$emojiGap**Github Action:** $actionHtmlUrl \n',
      );
      stderr.writeln('❌ PR 创建失败');
      exit(1);
    }

    /// 未创建 PR
    if (pullRequest.id == null) {
      logger.log('💬 PR 未创建');
      await githubService.deleteBranch(repoSlug, branchName);
      await updateBotStateIssueComment(
        BotState.success,
        '💬 与原文没有差异，未创建 PR。 \n',
        footer: moreInfo,
      );
      return;
    } else {
      logger.log('✅ PR 创建完成');
    }

    /// 已创建完成 PR
    await updateBotStateIssueComment(
      BotState.success,
      '💬 已翻译完成 PR ${pullRequest.htmlUrl} \n',
      footer: moreInfo,
    );

    logger.log(' ');
    logger.log('-----------------------------');
  }
}
