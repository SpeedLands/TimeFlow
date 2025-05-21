import 'package:get_storage/get_storage.dart';

class AppSettings {
  static final _box = GetStorage();

  static const _fontScaleKey = 'font_scale';
  static const _highContrastKey = 'high_contrast';
  static const _readingModeKey = 'reading_mode';

  static double getFontScale() {
    final setting = _box.read<String>(_fontScaleKey) ?? 'normal';
    switch (setting) {
      case 'small':
        return 0.8;
      case 'large':
        return 1.2;
      case 'normal':
      default:
        return 1.0;
    }
  }

  static String getFontScaleSetting() {
    return _box.read<String>(_fontScaleKey) ?? 'normal';
  }

  static void setFontScale(String scale) {
    if (['small', 'normal', 'large'].contains(scale)) {
      _box.write(_fontScaleKey, scale);
    }
  }

  static bool getHighContrast() {
    return _box.read<bool>(_highContrastKey) ?? false;
  }

  static void setHighContrast(bool value) {
    _box.write(_highContrastKey, value);
  }

  static bool getReadingMode() {
    return _box.read<bool>(_readingModeKey) ?? false;
  }

  static void setReadingMode(bool value) {
    _box.write(_readingModeKey, value);
  }
}
