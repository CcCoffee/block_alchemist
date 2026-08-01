import 'package:shared_preferences/shared_preferences.dart';

/// 游戏存档存储（基于 SharedPreferences，沿用脚手架的存储层模式）
class GameStorage {
  GameStorage._();
  static final GameStorage instance = GameStorage._();

  static const kSaveKey = 'alchemist_save_v1';
  static const kMuteKey = 'alchemist_muted';

  SharedPreferences? _prefs;
  bool _initialized = false;

  /// 初始化 SharedPreferences
  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  /// 测试用：允许重新初始化（配合 SharedPreferences.setMockInitialValues）
  void resetForTest() {
    _initialized = false;
  }

  String? get save => _prefs?.getString(kSaveKey);
  Future<void> setSave(String value) => _prefs?.setString(kSaveKey, value) ?? Future.value();
  Future<void> clearSave() => _prefs?.remove(kSaveKey) ?? Future.value();

  bool get muted => _prefs?.getBool(kMuteKey) ?? false;
  Future<void> setMuted(bool value) => _prefs?.setBool(kMuteKey, value) ?? Future.value();
}
