import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasko/core/mascot/tasko_mascot.dart';
import 'package:tasko/core/mascot/tasko_pose.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('mascot assets are RGBA PNGs so dark surfaces show through', () async {
    final paths = [
      for (final pose in TaskoPose.values) pose.assetPath,
      taskoHeadAsset,
    ];
    for (final path in paths) {
      final data = await rootBundle.load(path);
      expect(_pngColorType(data.buffer.asUint8List()), 6, reason: path);
    }
  });

  testWidgets('every pose and the head mark render', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              TaskoMascot(pose: TaskoPose.idle, size: 80),
              TaskoMascot(pose: TaskoPose.wave, size: 80),
              TaskoMascot(pose: TaskoPose.empty, size: 80),
              TaskoMascot(
                pose: TaskoPose.celebrate,
                size: 80,
                message: 'Nice',
              ),
              TaskoMark(size: 36),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(TaskoMascot), findsNWidgets(4));
    expect(find.text('Nice'), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(5));

    final assets =
        tester.widgetList<Image>(find.byType(Image)).map(_assetNameOf);
    expect(assets, containsAll([...TaskoPose.values.map((p) => p.assetPath)]));
    expect(assets, contains(taskoHeadAsset));
  });
}

String _assetNameOf(Image image) {
  final provider = image.image;
  return switch (provider) {
    AssetImage(:final assetName) => assetName,
    ResizeImage(imageProvider: AssetImage(:final assetName)) => assetName,
    _ => throw StateError('Unexpected provider: $provider'),
  };
}

/// PNG IHDR color type: 6 = Truecolor with alpha.
int _pngColorType(List<int> bytes) {
  // signature(8) + length(4) + 'IHDR'(4) + width(4) + height(4) + bitDepth(1)
  return bytes[25];
}
