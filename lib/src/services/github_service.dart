import 'dart:convert';

import 'package:github/github.dart';

class GithubService {
  GithubService({required GitHub github}) : _gitHub = github;

  final GitHub _gitHub;

  Future<Repository> fetchRepository(RepositorySlug repoSlug) async {
    return _gitHub.repositories.getRepository(repoSlug);
  }

  Future<Issue> fetchIssue(RepositorySlug repoSlug, int issueId) async {
    return _gitHub.issues.get(repoSlug, issueId);
  }

  Future<IssueComment> fetchIssueComment(
    RepositorySlug repoSlug,
    int commentId,
  ) async {
    return _gitHub.issues.getComment(repoSlug, commentId);
  }

  Future<RepositoryContents> fetchFileContents(
    RepositorySlug repoSlug,
    String filePath, {
    String? ref,
  }) async {
    return _gitHub.repositories.getContents(repoSlug, filePath, ref: ref);
  }

  Future<IssueComment> createIssueComment(
    RepositorySlug repoSlug,
    int issueId,
    String comment,
  ) async {
    return _gitHub.issues.createComment(repoSlug, issueId, comment);
  }

  Future<IssueComment> updateIssueComment(
    RepositorySlug repoSlug,
    int commentId,
    String comment,
  ) async {
    return _gitHub.issues.updateComment(repoSlug, commentId, comment);
  }

  Future<GitReference> createBranch(
    RepositorySlug repoSlug,
    String branchName,
  ) async {
    final sha = await _gitHub.repositories
        .listCommits(repoSlug)
        .first
        .then((value) => value.sha);
    return _gitHub.git.createReference(repoSlug, 'refs/heads/$branchName', sha);
  }

  Future<bool> deleteBranch(RepositorySlug repoSlug, String branchName) async {
    return _gitHub.git.deleteReference(repoSlug, 'heads/$branchName');
  }

  Future<ContentCreation> updateFile(
    RepositorySlug repoSlug,
    String path,
    String content,
    String message,
    String sha, {
    String? branch,
  }) async {
    final contentBase64 = base64Encode(utf8.encode(content));
    return _gitHub.repositories.updateFile(
      repoSlug,
      path,
      message,
      contentBase64,
      sha,
      branch: branch,
    );
  }

  Future<PullRequest> createPullRequests(
    RepositorySlug repoSlug,
    String title,
    String branch,
    String base, {
    bool draft = false,
    String? body,
  }) async {
    final head = '${repoSlug.owner}:$branch';
    return _gitHub.pullRequests.create(
      repoSlug,
      CreatePullRequest(title, head, base, draft: draft, body: body),
    );
  }
}
