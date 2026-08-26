import 'package:shared_preferences/shared_preferences.dart';

class UpdateCheckStore {
  UpdateCheckStore(this._prefs);

  static const lastCheckMsKey = 'update_last_check_ms';
  static const skippedVersionKey = 'update_skipped_version';
  static const autoInterval = Duration(hours: 24);

  final SharedPreferences _prefs;

  bool shouldAutoCheck(DateTime now) {
    final lastMs = _prefs.getInt(lastCheckMsKey);
    if (lastMs == null) return true;
    final last = DateTime.fromMillisecondsSinceEpoch(lastMs);
    return now.difference(last) >= autoInterval;
  }

  Future<void> markChecked(DateTime now) {
    return _prefs.setInt(lastCheckMsKey, now.millisecondsSinceEpoch);
  }

  bool isSkipped(String version) {
    return _prefs.getString(skippedVersionKey) == version;
  }

  Future<void> skipVersion(String version) {
    return _prefs.setString(skippedVersionKey, version);
  }
}
