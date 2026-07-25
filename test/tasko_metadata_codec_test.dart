import 'package:flutter_test/flutter_test.dart';
import 'package:tasko/data/codec/tasko_metadata_codec.dart';

void main() {
  group('TaskoMetadataCodec', () {
    test('encodes priority and labels', () {
      final raw = TaskoMetadataCodec.encode(
        priority: 1,
        labelIds: const ['lavoro', 'urgente'],
        notes: 'Chiama il fornitore',
      );
      expect(raw.startsWith('[tasko]'), isTrue);
      expect(raw.contains('Chiama il fornitore'), isTrue);

      final decoded = TaskoMetadataCodec.decode(raw);
      expect(decoded.priority, 1);
      expect(decoded.labelIds, ['lavoro', 'urgente']);
      expect(decoded.notes, 'Chiama il fornitore');
    });

    test('omits block when default priority and no labels', () {
      final raw = TaskoMetadataCodec.encode(
        priority: 4,
        labelIds: const [],
        notes: 'Solo note',
      );
      expect(raw, 'Solo note');
    });

    test('handles plain notes without block', () {
      final decoded = TaskoMetadataCodec.decode('Nota libera');
      expect(decoded.priority, 4);
      expect(decoded.labelIds, isEmpty);
      expect(decoded.notes, 'Nota libera');
    });
  });
}
