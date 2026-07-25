enum TaskoPose { idle, wave, empty, celebrate }

extension TaskoPoseAsset on TaskoPose {
  String get assetPath => switch (this) {
        TaskoPose.idle => 'assets/mascot/tasko_idle.png',
        TaskoPose.wave => 'assets/mascot/tasko_wave.png',
        TaskoPose.empty => 'assets/mascot/tasko_empty.png',
        TaskoPose.celebrate => 'assets/mascot/tasko_celebrate.png',
      };
}
