import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasko/core/l10n/app_strings.dart';
import 'package:tasko/core/theme.dart';
import 'package:tasko/data/providers.dart';
import 'package:tasko/domain/models.dart';

class LabelsScreen extends ConsumerWidget {
  const LabelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labelsAsync = ref.watch(labelsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.labels)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditor(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
      body: labelsAsync.when(
        data: (labels) {
          if (labels.isEmpty) {
            return const Center(
              child: Text(AppStrings.noLabelsTapPlus),
            );
          }
          return ListView.separated(
            itemCount: labels.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final label = labels[index];
              return ListTile(
                leading: CircleAvatar(backgroundColor: label.color),
                title: Text(label.name),
                subtitle: Text(label.id),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () async {
                    await ref
                        .read(tasksRepositoryProvider)
                        .deleteLabel(label.id);
                    ref.invalidate(labelsProvider);
                  },
                ),
                onTap: () => _showEditor(context, ref, existing: label),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(AppStrings.error(e))),
      ),
    );
  }

  Future<void> _showEditor(
    BuildContext context,
    WidgetRef ref, {
    TaskLabel? existing,
  }) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    var colorValue =
        existing?.colorValue ?? TaskoColors.labelPalette.first.toARGB32();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: Text(
                existing == null ? AppStrings.newLabel : AppStrings.editLabel,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration:
                        const InputDecoration(labelText: AppStrings.name),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: TaskoColors.labelPalette.map((c) {
                      final selected = c.toARGB32() == colorValue;
                      return GestureDetector(
                        onTap: () =>
                            setLocal(() => colorValue = c.toARGB32()),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: selected
                                ? Border.all(
                                    color: TaskoColors.charcoal,
                                    width: 2,
                                  )
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(AppStrings.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(AppStrings.save),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved != true) return;
    final name = nameCtrl.text.trim();
    if (name.isEmpty) return;

    final repo = ref.read(tasksRepositoryProvider);
    final label = existing == null
        ? repo.createDefaultLabel(name).copyWithColor(colorValue)
        : TaskLabel(id: existing.id, name: name, colorValue: colorValue);
    await repo.upsertLabel(label);
    ref.invalidate(labelsProvider);
  }
}

extension on TaskLabel {
  TaskLabel copyWithColor(int colorValue) => TaskLabel(
        id: id,
        name: name,
        colorValue: colorValue,
      );
}
