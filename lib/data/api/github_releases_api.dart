import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tasko/core/constants.dart';
import 'package:tasko/domain/github_release.dart';

class GithubReleasesException implements Exception {
  GithubReleasesException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'GithubReleasesException($statusCode): $body';
}

abstract class GithubReleasesClient {
  Future<GithubRelease> fetchLatest();
}

class GithubReleasesApi implements GithubReleasesClient {
  GithubReleasesApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<GithubRelease> fetchLatest() async {
    final response = await _client.get(
      Uri.parse(AppConstants.githubLatestReleaseApiUrl),
      headers: {
        'Accept': 'application/vnd.github+json',
        'User-Agent': 'Tasko/${AppConstants.version}',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    );
    if (response.statusCode >= 400) {
      throw GithubReleasesException(response.statusCode, response.body);
    }
    final json = jsonDecode(response.body);
    if (json is! Map) {
      throw const FormatException('GitHub latest release was not an object');
    }
    final release = GithubRelease.fromJson(Map<String, dynamic>.from(json));
    if (release.version.isEmpty || release.htmlUrl.isEmpty) {
      throw const FormatException('GitHub latest release is missing fields');
    }
    return release;
  }
}
