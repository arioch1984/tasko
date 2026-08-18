import 'package:flutter/material.dart';

/// English Material strings with weeks starting on Monday.
///
/// [DefaultMaterialLocalizations] is US English and starts weeks on Sunday.
/// Tasko keeps English copy but European week layout for date pickers.
class MondayMaterialLocalizations extends DefaultMaterialLocalizations {
  const MondayMaterialLocalizations();

  /// Monday. [narrowWeekdays] is still Sunday-first: S M T W T F S.
  @override
  int get firstDayOfWeekIndex => 1;

  static const LocalizationsDelegate<MaterialLocalizations> delegate =
      _MondayMaterialLocalizationsDelegate();
}

class _MondayMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _MondayMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return const MondayMaterialLocalizations();
  }

  @override
  bool shouldReload(_MondayMaterialLocalizationsDelegate old) => false;
}
