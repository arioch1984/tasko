import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasko/core/constants.dart';
import 'package:tasko/core/l10n/app_strings.dart';
import 'package:tasko/data/url_launch.dart';
import 'package:tasko/domain/github_release.dart';
import 'package:tasko/features/update/app_update_controller.dart';
import 'package:tasko/features/update/update_available_dialog.dart';

Future<void> presentUpdateCheckOutcome(
  BuildContext context,
  WidgetRef ref,
  UpdateCheckOutcome outcome, {
  required bool manual,
}) async {
  if (!context.mounted) return;
  switch (outcome) {
    case UpdateCheckAvailable(:final release):
      await showUpdateAvailableDialog(
        context: context,
        release: release,
        currentVersion: AppConstants.version,
        onDownload: () => _openDownload(context, ref, release),
        onSkip: () {
          ref.read(appUpdateControllerProvider).skip(release.version);
        },
      );
    case UpdateCheckUpToDate():
      if (manual) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.upToDate)),
        );
      }
    case UpdateCheckFailed():
      if (manual) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.updateCheckFailed)),
        );
      }
    case UpdateCheckIdle() || UpdateCheckSkipped():
      break;
  }
}

Future<void> _openDownload(
  BuildContext context,
  WidgetRef ref,
  GithubRelease release,
) async {
  final url = releaseDownloadUrl(release, defaultTargetPlatform);
  final uri = Uri.tryParse(url);
  var opened = false;
  if (uri != null && uri.hasScheme) {
    try {
      opened = await ref.read(urlLaunchProvider)(uri);
    } catch (_) {
      opened = false;
    }
  }
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.openLinkFailed)),
    );
  }
}
