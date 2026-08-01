import 'package:block_alchemist/core/storage/game_storage.dart';
import 'package:block_alchemist/features/alchemist/board_painter.dart';
import 'package:block_alchemist/features/alchemist/data/elements.dart';
import 'package:block_alchemist/features/alchemist/game_controller.dart';
import 'package:block_alchemist/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('应用可启动并显示游戏主界面', (tester) async {
    SharedPreferences.setMockInitialValues({});
    GameStorage.instance.resetForTest();
    await GameStorage.instance.init();

    await tester.pumpWidget(
      const ProviderScope(child: AlchemistApp()),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('方块炼金师'), findsWidgets);
    expect(find.textContaining('火'), findsWidgets);
    expect(find.textContaining('水'), findsWidgets);

    // 让 ticker 跑几帧，确保动画循环不崩溃
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));

    // 打开图鉴
    await tester.tap(find.text('图鉴'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('📖 图鉴'), findsOneWidget);
  });

  testWidgets('手机尺寸：棋盘不滚动，点击方块弹出详情面板', (tester) async {
    SharedPreferences.setMockInitialValues({});
    GameStorage.instance.resetForTest();
    await GameStorage.instance.init();

    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ProviderScope(child: AlchemistApp()),
    );
    await tester.pump(const Duration(milliseconds: 300));

    // 手机端棋盘不应被任何滚动容器包裹（避免拖拽与滚动冲突）
    expect(
      find.ancestor(
        of: find.byType(BoardView),
        matching: find.byType(SingleChildScrollView),
      ),
      findsNothing,
    );

    // 材料栏默认收起为一行，可展开查看全部元素
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pump();
    expect(find.byIcon(Icons.expand_less), findsOneWidget);
    await tester.tap(find.byIcon(Icons.expand_less));
    await tester.pump();
    expect(find.byIcon(Icons.expand_more), findsOneWidget);

    // 选中地图上的一个方块 -> 弹出底部详情面板
    final container = ProviderScope.containerOf(
      tester.element(find.byType(AlchemistApp)),
    );
    final game = container.read(gameControllerProvider);
    container.read(gameControllerProvider.notifier).selectBlock(game.allBlocks().first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('🧩 点击地图上的方块查看详情'), findsNothing);
    expect(find.textContaining('删除方块'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('手机尺寸：棋盘高度不随发现数量缩小，8×8 时格子仍足够大', (tester) async {
    SharedPreferences.setMockInitialValues({});
    GameStorage.instance.resetForTest();
    await GameStorage.instance.init();

    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ProviderScope(child: AlchemistApp()),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(AlchemistApp)),
    );
    final sizeBefore = tester.getSize(find.byType(BoardView));

    // 推进到世界最高等级（8×8）
    final c = container.read(gameControllerProvider);
    for (final id in kElements.map((e) => e.id)) {
      if (!c.discovered.contains(id)) c.discover(id);
    }
    final a = c.randomEmptyCell()!;
    final b = c.randomEmptyCell()!;
    c.placeElement('earth', a.$1, a.$2);
    c.placeElement('earth', b.$1, b.$2);
    c.performMerge(c.get(a.$1, a.$2)!, c.get(b.$1, b.$2)!);
    c.tick(0.5);
    await tester.pump(const Duration(milliseconds: 300));

    final sizeAfter = tester.getSize(find.byType(BoardView));
    expect(sizeAfter.height, closeTo(sizeBefore.height, 0.1),
        reason: '棋盘高度不应随发现数量缩小');
    final cell = sizeAfter.width / c.boardSize;
    expect(cell, greaterThanOrEqualTo(38),
        reason: '8×8 时每个格子仍应足够大（实际 ${cell.toStringAsFixed(1)}px）');
  });

  testWidgets('长按材料栏元素进入拖拽，不与横向滚动冲突', (tester) async {
    SharedPreferences.setMockInitialValues({});
    GameStorage.instance.resetForTest();
    await GameStorage.instance.init();

    await tester.pumpWidget(
      const ProviderScope(child: AlchemistApp()),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(AlchemistApp)),
    );

    // 捕获平台通道调用，验证长按触发震动确认
    final hapticCalls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        hapticCalls.add(call);
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    final gesture = await tester.startGesture(tester.getCenter(find.text('火')));
    await tester.pump(const Duration(milliseconds: 600));
    expect(container.read(gameControllerProvider).drag?.kind, 'tray',
        reason: '长按后应进入拖拽状态');
    expect(hapticCalls, isNotEmpty, reason: '长按选中应有震动确认');

    await gesture.moveBy(const Offset(0, -200));
    await tester.pump();
    expect(container.read(gameControllerProvider).drag?.active, isTrue,
        reason: '拖动后拖拽会话应激活');

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 200));
  });
}
