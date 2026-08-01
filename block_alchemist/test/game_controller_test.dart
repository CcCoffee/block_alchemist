import 'package:block_alchemist/core/storage/game_storage.dart';
import 'package:block_alchemist/features/alchemist/data/elements.dart';
import 'package:block_alchemist/features/alchemist/game_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    GameStorage.instance.resetForTest();
    await GameStorage.instance.init();
  });

  test('新开局：地图有火与水，四个初始元素已解锁', () {
    final c = GameController(GameStorage.instance);
    expect(c.allBlocks(), hasLength(2));
    expect(c.discoveredCount, 4);
    expect(c.boardSize, 6);
  });

  test('放置 / 合成 / 连锁：火+水=蒸汽，土+火=熔岩', () {
    final c = GameController(GameStorage.instance);
    final cell = c.randomEmptyCell()!;
    expect(c.placeElement('earth', cell.$1, cell.$2), isTrue);
    expect(
      c.placeElement('gem', cell.$1, cell.$2),
      isFalse,
      reason: '未发现的元素不能放置',
    );

    final fire = c.allBlocks().firstWhere((b) => b.elementId == 'fire');
    final water = c.allBlocks().firstWhere((b) => b.elementId == 'water');
    c.performMerge(fire, water);
    c.tick(0.5);
    expect(c.allBlocks().any((b) => b.elementId == 'steam'), isTrue);
    expect(c.discovered.contains('steam'), isTrue);
    expect(c.score, greaterThanOrEqualTo(10));

    // 火已被合成消耗，再造一个火
    final newCell = c.randomEmptyCell()!;
    c.placeElement('fire', newCell.$1, newCell.$2);
    final earth = c.allBlocks().firstWhere((b) => b.elementId == 'earth');
    final fire2 = c.allBlocks().firstWhere((b) => b.elementId == 'fire');
    c.performMerge(earth, fire2);
    c.tick(0.5);
    expect(c.allBlocks().any((b) => b.elementId == 'lava'), isTrue);
  });

  test('放置方块后，弹出动画期间持续通知重绘（不会停留在小尺寸）', () {
    final c = GameController(GameStorage.instance);
    var notifies = 0;
    c.addListener(() => notifies++);

    final cell = c.randomEmptyCell()!;
    c.placeElement('earth', cell.$1, cell.$2);
    notifies = 0;

    // 弹出动画窗口（0.3s）内模拟 5 帧
    for (var i = 0; i < 5; i++) {
      c.tick(0.05);
    }
    expect(notifies, greaterThan(0), reason: '弹出动画期间应持续通知重绘');

    notifies = 0;
    c.tick(1.0); // 动画结束后不再需要重绘
    expect(notifies, 0);
  });

  test('材料栏：轻点自动放置，长按未拖动不放置', () {
    final c = GameController(GameStorage.instance);
    final before = c.allBlocks().length;
    c.tapTrayChip('earth');
    expect(c.allBlocks().length, before + 1);
    expect(c.allBlocks().any((b) => b.elementId == 'earth'), isTrue);

    final before2 = c.allBlocks().length;
    c.startTrayDrag('earth', Offset.zero);
    c.endTrayDrag(Offset.zero); // 长按后未移动就松手 -> 取消
    expect(c.allBlocks().length, before2, reason: '长按未拖动不应放置方块');
    expect(c.drag, isNull);
  });

  test('灾害方块存在期间持续通知重绘（脉动动画不停）', () {
    final c = GameController(GameStorage.instance);
    for (final id in kElements.map((e) => e.id).take(16)) {
      c.discover(id);
    }
    c.spawnDisaster();

    var notifies = 0;
    c.addListener(() => notifies++);

    // 越过弹出动画窗口后，灾害方块仍应持续重绘
    c.tick(0.5);
    notifies = 0;
    c.tick(0.05);
    expect(notifies, greaterThan(0), reason: '灾害方块应持续脉动重绘');
    c.tick(0.05);
    expect(notifies, greaterThan(0), reason: '后续每帧都应继续重绘');
  });

  test('世界成长：探索数提升后地图扩大', () {
    final c = GameController(GameStorage.instance);
    final others = kElements
        .map((e) => e.id)
        .where((id) => !c.discovered.contains(id))
        .toList();
    for (final id in others.take(21)) {
      c.discover(id);
    }
    // 触发一次合成，内部会更新世界等级
    final a = c.randomEmptyCell()!;
    final b = c.randomEmptyCell()!;
    c.placeElement('earth', a.$1, a.$2);
    c.placeElement('earth', b.$1, b.$2);
    final ea = c.get(a.$1, a.$2)!;
    final eb = c.get(b.$1, b.$2)!;
    c.performMerge(ea, eb);
    c.tick(0.5);
    expect(c.discoveredCount, greaterThanOrEqualTo(25));
    expect(c.boardSize, 7, reason: '世界等级提升后地图应扩大');
  });

  test('灾害事件：降临并自动消退', () {
    var nowMs = DateTime(2026, 1, 1).millisecondsSinceEpoch.toDouble();
    final c = GameController(
      GameStorage.instance,
      now: () => DateTime.fromMillisecondsSinceEpoch(nowMs.toInt()),
    );
    for (final id in kElements.map((e) => e.id).take(16)) {
      c.discover(id);
    }
    c.spawnDisaster();
    final disaster = c.allBlocks().where((b) => b.expiresAt != null).toList();
    expect(disaster, isNotEmpty);
    expect(c.discovered.contains(disaster.first.elementId), isTrue);
    disaster.first.expiresAt = nowMs - 1; // 现实时间已过期
    c.tick(0.1);
    expect(c.allBlocks().any((b) => b.expiresAt != null), isFalse);
  });

  test('灾害挑战：拖救灾元素化解灾害，得奖励并计入成就', () {
    var nowMs = DateTime(2026, 1, 1).millisecondsSinceEpoch.toDouble();
    final c = GameController(
      GameStorage.instance,
      now: () => DateTime.fromMillisecondsSinceEpoch(nowMs.toInt()),
    );
    // 解锁全部元素，方便放置任意救灾元素
    for (final id in kElements.map((e) => e.id)) {
      c.discover(id);
    }
    // 清空目标，避免救灾奖励触发目标完成影响分数断言
    c.goals = <Goal>[];
    c.spawnDisaster();
    final disaster = c.allBlocks().firstWhere((b) => b.expiresAt != null);
    final cureId = kDisasterCures[disaster.elementId]!;
    final cell = c.randomEmptyCell()!;
    c.placeElement(cureId, cell.$1, cell.$2);
    final cureBlock = c.get(cell.$1, cell.$2)!;
    final scoreBefore = c.score;

    c.performMerge(cureBlock, disaster);

    expect(
      c.allBlocks().any((b) => b.elementId == disaster.elementId),
      isFalse,
      reason: '灾害应被化解',
    );
    expect(
      c.allBlocks().any((b) => b.elementId == cureId),
      isFalse,
      reason: '救灾元素应被消耗',
    );
    expect(c.score, scoreBefore + kCureReward);
    expect(c.savedDisasters, 1);
  });

  test('灾害挑战：未化解爆发时扣分，且分数不会扣成负数', () {
    var nowMs = DateTime(2026, 1, 1).millisecondsSinceEpoch.toDouble();
    final c = GameController(
      GameStorage.instance,
      now: () => DateTime.fromMillisecondsSinceEpoch(nowMs.toInt()),
    );
    for (final id in kElements.map((e) => e.id).take(16)) {
      c.discover(id);
    }
    c.spawnDisaster();
    c.score = 100;
    final disaster = c.allBlocks().firstWhere((b) => b.expiresAt != null);
    disaster.expiresAt = nowMs - 1;
    c.tick(0.1);
    expect(c.score, 100 - kDisasterPenalty);

    // 分数为 0 时爆发不会扣成负数
    c.score = 0;
    c.spawnDisaster();
    final d2 = c.allBlocks().firstWhere((b) => b.expiresAt != null);
    d2.expiresAt = nowMs - 1;
    c.tick(0.1);
    expect(c.score, 0);
  });

  test('世界目标按等级解锁：新目标不超过当前世界等级', () {
    final c = GameController(GameStorage.instance);
    expect(c.unlockedGoalTier, 1);
    for (final g in c.goals) {
      expect(g.tier, lessThanOrEqualTo(c.unlockedGoalTier));
    }

    // 推进到最高世界等级
    for (final id in kElements.map((e) => e.id)) {
      c.discover(id);
    }
    // 世界等级在合成后更新（与游戏内行为一致）
    final a = c.randomEmptyCell()!;
    final b = c.randomEmptyCell()!;
    c.placeElement('earth', a.$1, a.$2);
    c.placeElement('earth', b.$1, b.$2);
    c.performMerge(c.get(a.$1, a.$2)!, c.get(b.$1, b.$2)!);
    c.tick(0.5);
    expect(c.unlockedGoalTier, 4);

    // 完成一个目标后，新目标等级仍不能超过解锁等级
    c.goals = <Goal>[const Goal(kind: 'merge', target: 1, reward: 50, tier: 4)];
    final c1 = c.randomEmptyCell()!;
    final c2 = c.randomEmptyCell()!;
    c.placeElement('earth', c1.$1, c1.$2);
    c.placeElement('earth', c2.$1, c2.$2);
    c.performMerge(c.get(c1.$1, c1.$2)!, c.get(c2.$1, c2.$2)!);
    c.tick(0.5);
    expect(c.goals.single.tier, lessThanOrEqualTo(c.unlockedGoalTier));
  });

  test('存档与读档：图鉴、分数、地图都能恢复', () {
    final c = GameController(GameStorage.instance);
    final fire = c.allBlocks().firstWhere((b) => b.elementId == 'fire');
    final water = c.allBlocks().firstWhere((b) => b.elementId == 'water');
    c.performMerge(fire, water);
    c.tick(0.5);
    c.save();

    final c2 = GameController(GameStorage.instance);
    expect(c2.discovered.contains('steam'), isTrue);
    expect(c2.score, c.score);
    expect(c2.allBlocks(), isNotEmpty);
  });

  test('重置存档：只保留初始元素', () {
    final c = GameController(GameStorage.instance);
    c.resetGame();
    expect(c.discoveredCount, 4);
    expect(c.score, 0);
  });

  test('世界目标：新开局 3 个目标，完成合成目标后奖励并刷新', () {
    final c = GameController(GameStorage.instance);
    expect(c.goals, hasLength(3));

    // 强制替换成一个马上能完成的合成目标
    c.goals = <Goal>[const Goal(kind: 'merge', target: 1, reward: 50)];
    final fire = c.allBlocks().firstWhere((b) => b.elementId == 'fire');
    final water = c.allBlocks().firstWhere((b) => b.elementId == 'water');
    final scoreBefore = c.score;
    c.performMerge(fire, water);
    c.tick(0.5);

    expect(c.mergeCount, 1);
    expect(
      c.score,
      greaterThanOrEqualTo(scoreBefore + 50 + 10),
      reason: '合成价值 + 目标奖励都应入账',
    );
    expect(c.goals.single.key, isNot('merge||1'), reason: '完成的目标应立即被新目标替换');
  });

  test('世界目标：存档后目标列表能恢复', () {
    final c = GameController(GameStorage.instance);
    expect(c.goals, hasLength(3));
    c.save();

    final c2 = GameController(GameStorage.instance);
    expect(c2.goals, hasLength(3));
    expect(c2.goals.map((g) => g.key), c.goals.map((g) => g.key));
  });

  test('卡住提示：连续失败 3 次后可用，线索材料均已发现且产物未发现', () {
    final c = GameController(GameStorage.instance);
    expect(c.hintReady, isFalse);

    final bs = c.allBlocks();
    c.rejectMerge(bs[0], bs[1]);
    c.rejectMerge(bs[0], bs[1]);
    c.rejectMerge(bs[0], bs[1]);
    expect(c.hintReady, isTrue, reason: '连续失败 3 次应解锁提示');

    final pair = c.useHint();
    expect(pair, isNotNull);
    expect(c.discovered.contains(pair!.$1), isTrue);
    expect(c.discovered.contains(pair.$2), isTrue);
    final rid = findRecipe(pair.$1, pair.$2);
    expect(rid, isNotNull);
    expect(c.discovered.contains(rid), isFalse, reason: '提示不应指向已发现的产物');

    expect(c.failStreak, 0, reason: '使用提示后失败计数清零');
    expect(c.hintReady, isFalse, reason: '提示后有冷却');
  });

  test('倒计时与现实时间匹配：帧暂停/退后台后仍按真实时间走', () {
    var nowMs = DateTime(2026, 1, 1).millisecondsSinceEpoch.toDouble();
    final c = GameController(
      GameStorage.instance,
      now: () => DateTime.fromMillisecondsSinceEpoch(nowMs.toInt()),
    );
    expect(c.hintReady, isFalse);

    // 游戏帧只推进 1 秒，但现实时间已过去 91 秒
    c.tick(1.0);
    nowMs += 91000;
    expect(c.hintReady, isTrue, reason: '90 秒无发现应按现实时间解锁，而不是游戏帧时间');

    // 使用提示后进入 45 秒冷却，冷却也按现实时间结束
    final pair = c.useHint();
    expect(pair, isNotNull);
    expect(c.hintReady, isFalse);
    nowMs += 46000;
    expect(c.hintReady, isTrue, reason: '45 秒冷却按现实时间结束');

    // 弹窗按现实时间自动消失
    c.showToast('测试弹窗');
    expect(c.toast, isNotNull);
    nowMs += 3000;
    c.tick(0.1);
    expect(c.toast, isNull);
  });
}
