import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasko/core/mascot/tasko_pose.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('mascot assets are RGBA PNGs so dark surfaces show through', () async {
    for (final pose in TaskoPose.values) {
      final data = await rootBundle.load(pose.assetPath);
      final bytes = data.buffer.asUint8List();
      expect(_pngColorType(bytes), 6, reason: pose.assetPath);
    }
  });
}

/// PNG IHDR color type: 6 = Truecolor with alpha.
int _pngColorType(List<int> bytes) {
  // signature(8) + length(4) + 'IHDR'(4) + width(4) + height(4) + bitDepth(1)
  return bytes[25];
}
