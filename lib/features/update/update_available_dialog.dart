import 'package:flutter/material.dart';
import 'package:tasko/core/l10n/app_strings.dart';
import 'package:tasko/domain/github_release.dart';

Future<void> showUpdateAvailableDialog({
  required BuildContext context,
  required GithubRelease release,
  required String currentVersion,
  required VoidCallback onDownload,
  required VoidCallback onSkip,
}) {
  final notes = truncateReleaseNotes(release.notes);
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(AppStrings.updateAvailable),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.updateAvailableBody(release.version, currentVersion),
              ),
              if (notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(notes, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onSkip();
            },
            child: const Text(AppStrings.skipThisVersion),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.later),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onDownload();
            },
            child: const Text(AppStrings.downloadUpdate),
          ),
        ],
      );
    },
  );
}
