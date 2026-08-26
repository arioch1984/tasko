import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasko/domain/github_release.dart';

void main() {
  final json = {
    'tag_name': 'v0.5.0',
    'html_url': 'https://github.com/arioch1984/tasko/releases/tag/v0.5.0',
    'body': 'Notes here',
    'assets': [
      {
        'name': 'tasko-0.5.0.apk',
        'browser_download_url':
            'https://github.com/arioch1984/tasko/releases/download/v0.5.0/tasko-0.5.0.apk',
      },
      {
        'name': 'tasko-0.5.0-macos.zip',
        'browser_download_url':
            'https://github.com/arioch1984/tasko/releases/download/v0.5.0/tasko-0.5.0-macos.zip',
      },
    ],
  };

  test('parses latest release JSON', () {
    final release = GithubRelease.fromJson(json);
    expect(release.version, '0.5.0');
    expect(release.tagName, 'v0.5.0');
    expect(release.notes, 'Notes here');
    expect(release.apkUrl, contains('tasko-0.5.0.apk'));
    expect(release.macosZipUrl, contains('tasko-0.5.0-macos.zip'));
  });

  test('picks the platform asset and falls back to the release page', () {
    final release = GithubRelease.fromJson(json);
    expect(
      releaseDownloadUrl(release, TargetPlatform.android),
      release.apkUrl,
    );
    expect(
      releaseDownloadUrl(release, TargetPlatform.macOS),
      release.macosZipUrl,
    );
    expect(
      releaseDownloadUrl(release, TargetPlatform.linux),
      release.htmlUrl,
    );

    const pageOnly = GithubRelease(
      version: '0.5.0',
      tagName: 'v0.5.0',
      htmlUrl: 'https://example.com/release',
    );
    expect(
      releaseDownloadUrl(pageOnly, TargetPlatform.android),
      pageOnly.htmlUrl,
    );
  });

  test('truncates long release notes', () {
    final long = 'a' * 500;
    final truncated = truncateReleaseNotes(long, maxChars: 480);
    expect(truncated.length, 481);
    expect(truncated.endsWith('…'), isTrue);
  });
}
