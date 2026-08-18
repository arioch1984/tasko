import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasko/core/l10n/app_strings.dart';
import 'package:tasko/core/theme_preference.dart';

Future<void> showAppearanceDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => const AppearanceDialog(),
  );
}

class AppearanceDialog extends ConsumerWidget {
  const AppearanceDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(themePreferenceProvider);

    return AlertDialog(
      title: const Text(AppStrings.appearance),
      contentPadding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final preference in ThemePreference.values)
            ListTile(
              leading: Icon(preference.icon),
              title: Text(AppStrings.themePreferenceLabel(preference)),
              subtitle: preference == ThemePreference.system
                  ? const Text(AppStrings.themeSystemHint)
                  : null,
              selected: preference == selected,
              trailing: preference == selected
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () {
                ref
                    .read(themePreferenceProvider.notifier)
                    .setPreference(preference);
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.done),
        ),
      ],
    );
  }
}

class AppearanceIconButton extends ConsumerWidget {
  const AppearanceIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference = ref.watch(themePreferenceProvider);
    return IconButton(
      tooltip: AppStrings.appearance,
      icon: Icon(preference.icon),
      onPressed: () => showAppearanceDialog(context),
    );
  }
}
