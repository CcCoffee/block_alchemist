import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// 音效服务：优先播放 assets/sounds/ 下的 wav，
/// 同时附带触觉反馈；静音开关控制两者。
class SoundService {
  /// 由 GameController 根据存档设置
  static bool enabled = true;

  static final AudioPlayer _player = AudioPlayer();

  static Future<void> _play(String name) async {
    if (!enabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/$name.wav'), volume: 0.6);
    } catch (_) {
      // 插件不可用时静默降级（例如无音频平台的测试环境）
    }
  }

  static Future<void> _haptic(Future<void> Function() action) async {
    if (!enabled) return;
    try {
      await action();
    } catch (_) {}
  }

  /// 放置 / 移动方块
  static Future<void> place() async {
    await _haptic(HapticFeedback.selectionClick);
    await _play('click');
  }

  /// 合成成功
  static Future<void> merge() async {
    await _haptic(HapticFeedback.mediumImpact);
    await _play('merge');
  }

  /// 新发现元素
  static Future<void> discover() async {
    await _haptic(HapticFeedback.heavyImpact);
    await _play('achievement');
  }

  /// 灾害 / 世界升级
  static Future<void> event() async {
    await _haptic(HapticFeedback.heavyImpact);
    await _play('level');
  }

  /// 删除方块
  static Future<void> remove() async {
    await _haptic(HapticFeedback.lightImpact);
    await _play('item');
  }

  /// 无效合成（网页版对应低音提示，无独立文件，保留震动反馈）
  static Future<void> deny() async {
    await _haptic(HapticFeedback.vibrate);
  }

  /// 长按选中确认：始终触发（不受静音开关影响）
  static Future<void> longPressConfirm() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }
}
