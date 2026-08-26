import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

typedef UrlLaunch = Future<bool> Function(Uri uri);

final urlLaunchProvider = Provider<UrlLaunch>((ref) {
  return (uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  };
});
