import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:tasko/core/constants.dart';
import 'package:tasko/data/api/github_releases_api.dart';

class _ScriptedClient extends http.BaseClient {
  _ScriptedClient(this._response);

  final http.Response _response;
  http.BaseRequest? lastRequest;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    lastRequest = request;
    return http.StreamedResponse(
      Stream<List<int>>.value(_response.bodyBytes),
      _response.statusCode,
      headers: _response.headers,
    );
  }
}

void main() {
  test('GET latest release sends User-Agent and parses the body', () async {
    final payload = {
      'tag_name': 'v0.5.0',
      'html_url': 'https://github.com/arioch1984/tasko/releases/tag/v0.5.0',
      'body': 'Hi',
      'assets': <Map<String, dynamic>>[],
    };
    final client = _ScriptedClient(
      http.Response(jsonEncode(payload), 200),
    );
    final api = GithubReleasesApi(client: client);

    final release = await api.fetchLatest();

    expect(release.version, '0.5.0');
    expect(
      client.lastRequest!.url.toString(),
      AppConstants.githubLatestReleaseApiUrl,
    );
    expect(
      client.lastRequest!.headers['user-agent'] ??
          client.lastRequest!.headers['User-Agent'],
      'Tasko/${AppConstants.version}',
    );
  });

  test('non-OK status becomes GithubReleasesException', () async {
    final api = GithubReleasesApi(
      client: _ScriptedClient(http.Response('nope', 403)),
    );
    expect(api.fetchLatest(), throwsA(isA<GithubReleasesException>()));
  });
}
