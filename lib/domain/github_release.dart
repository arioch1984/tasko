import 'package:flutter/foundation.dart';

class GithubRelease {
  const GithubRelease({
    required this.version,
    required this.tagName,
    required this.htmlUrl,
    this.notes = '',
    this.apkUrl,
    this.macosZipUrl,
  });

  /// Semver without a leading `v`.
  final String version;
  final String tagName;
  final String htmlUrl;
  final String notes;
  final String? apkUrl;
  final String? macosZipUrl;

  factory GithubRelease.fromJson(Map<String, dynamic> json) {
    final tag = json['tag_name'] as String? ?? '';
    final version = _stripV(tag);
    final assets = json['assets'];
    String? apk;
    String? zip;
    if (assets is List) {
      final expectedApk = 'tasko-$version.apk';
      final expectedZip = 'tasko-$version-macos.zip';
      for (final asset in assets) {
        if (asset is! Map) continue;
        final name = asset['name'] as String? ?? '';
        final url = asset['browser_download_url'] as String?;
        if (url == null || url.isEmpty) continue;
        if (name == expectedApk) apk = url;
        if (name == expectedZip) zip = url;
      }
      if (apk == null || zip == null) {
        for (final asset in assets) {
          if (asset is! Map) continue;
          final name = asset['name'] as String? ?? '';
          final url = asset['browser_download_url'] as String?;
          if (url == null || url.isEmpty) continue;
          if (apk == null && name.endsWith('.apk')) apk = url;
          if (zip == null && name.endsWith('-macos.zip')) zip = url;
        }
      }
    }
    return GithubRelease(
      version: version,
      tagName: tag,
      htmlUrl: json['html_url'] as String? ?? '',
      notes: (json['body'] as String? ?? '').trim(),
      apkUrl: apk,
      macosZipUrl: zip,
    );
  }

  static String _stripV(String tag) {
    if (tag.startsWith('v') || tag.startsWith('V')) {
      return tag.substring(1);
    }
    return tag;
  }
}

String releaseDownloadUrl(GithubRelease release, TargetPlatform platform) {
  switch (platform) {
    case TargetPlatform.android:
      return release.apkUrl ?? release.htmlUrl;
    case TargetPlatform.macOS:
      return release.macosZipUrl ?? release.htmlUrl;
    default:
      return release.htmlUrl;
  }
}

String truncateReleaseNotes(String notes, {int maxChars = 480}) {
  if (notes.length <= maxChars) return notes;
  return '${notes.substring(0, maxChars).trimRight()}…';
}
