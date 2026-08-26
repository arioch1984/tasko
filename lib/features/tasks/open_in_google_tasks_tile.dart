import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasko/core/l10n/app_strings.dart';
import 'package:tasko/data/url_launch.dart';

/// Opens the Google Tasks web UI for a saved task (`webViewLink`).
class OpenInGoogleTasksTile extends ConsumerWidget {
  const OpenInGoogleTasksTile({super.key, required this.webViewLink});

  final String webViewLink;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.schedule_rounded),
      title: const Text(AppStrings.setTimeInGoogleTasks),
      subtitle: const Text(AppStrings.setTimeInGoogleTasksHint),
      trailing: const Icon(Icons.open_in_new_rounded),
      onTap: () => _open(context, ref),
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final uri = Uri.tryParse(webViewLink);
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
}
