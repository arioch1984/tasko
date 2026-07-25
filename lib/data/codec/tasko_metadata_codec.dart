import 'dart:convert';

/// Encodes/decodes Tasko priority + labels into Google Tasks `notes`.
///
/// Format:
/// ```
/// [tasko]{"p":2,"l":["work"]}[/tasko]
/// User-visible notes here.
/// ```
class TaskoMetadataCodec {
  static final RegExp _block = RegExp(
    r'^\[tasko\](.*?)\[/tasko\]\n?',
    dotAll: true,
  );

  static ({int priority, List<String> labelIds, String notes}) decode(
    String? rawNotes,
  ) {
    if (rawNotes == null || rawNotes.isEmpty) {
      return (priority: 4, labelIds: const [], notes: '');
    }

    final match = _block.firstMatch(rawNotes);
    if (match == null) {
      return (priority: 4, labelIds: const [], notes: rawNotes);
    }

    var priority = 4;
    var labelIds = <String>[];
    try {
      final json = jsonDecode(match.group(1)!) as Map<String, dynamic>;
      priority = (json['p'] as num?)?.toInt() ?? 4;
      final labels = json['l'];
      if (labels is List) {
        labelIds = labels.map((e) => e.toString()).toList();
      }
    } catch (_) {
      // Malformed block — treat whole notes as user text.
      return (priority: 4, labelIds: const [], notes: rawNotes);
    }

    final notes = rawNotes.substring(match.end).trimLeft();
    return (
      priority: priority.clamp(1, 4),
      labelIds: labelIds,
      notes: notes,
    );
  }

  static String encode({
    required int priority,
    required List<String> labelIds,
    required String notes,
  }) {
    final p = priority.clamp(1, 4);
    final hasMeta = p != 4 || labelIds.isNotEmpty;
    final userNotes = notes.trim();

    if (!hasMeta) {
      return userNotes;
    }

    final payload = jsonEncode({
      'p': p,
      'l': labelIds,
    });
    final block = '[tasko]$payload[/tasko]';
    if (userNotes.isEmpty) return block;
    return '$block\n$userNotes';
  }
}
