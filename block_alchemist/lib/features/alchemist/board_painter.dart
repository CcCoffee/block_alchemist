import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/elements.dart';
import 'game_controller.dart';

/// 棋盘 Canvas 绘制器（跟随 GameController 的 notifyListeners 重绘）
class BoardPainter extends CustomPainter {
  BoardPainter(this.game) : super(repaint: game);

  final GameController game;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / game.boardSize;

    // 地图底色
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0D1424),
    );

    // 格子
    for (var r = 0; r < game.boardSize; r++) {
      for (var c = 0; c < game.boardSize; c++) {
        final alpha = (r + c) % 2 == 0 ? 0.018 : 0.028;
        canvas.drawRect(
          Rect.fromLTWH(c * cell + 2, r * cell + 2, cell - 4, cell - 4),
          Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: alpha),
        );
      }
    }

    // 悬停高亮
    final hover = game.hover;
    if (hover != null && game.inBounds(hover.$1, hover.$2)) {
      _strokeCell(canvas, hover.$1, hover.$2, cell,
          const Color(0x8C6EA8FF), 2);
    }

    // 拖拽目标提示（绿 = 可合成/可移动，红 = 无效）
    final drag = game.drag;
    if (drag != null &&
        drag.kind == 'map' &&
        drag.active &&
        hover != null &&
        game.inBounds(hover.$1, hover.$2)) {
      final target = game.get(hover.$1, hover.$2);
      final ok = target != null
          ? findRecipe(drag.block!.elementId, target.elementId) != null
          : !(hover.$1 == drag.fromRow && hover.$2 == drag.fromCol);
      _strokeCell(canvas, hover.$1, hover.$2, cell,
          ok ? const Color(0xD97BED9F) : const Color(0xD9FF6B6B), 3);
    }

    // 方块
    for (final b in game.allBlocks()) {
      _drawBlock(canvas, size, b);
    }

    // 合成动画
    for (final a in game.mergeAnims) {
      _drawMerge(canvas, size, a);
    }

    // 无效合成红闪
    for (final f in game.cellFlashes) {
      final alpha = (1 - f.t / f.dur).clamp(0.0, 1.0);
      canvas.drawRect(
        Rect.fromLTWH(f.col * cell + 2, f.row * cell + 2, cell - 4, cell - 4),
        Paint()..color = f.color.withValues(alpha: alpha),
      );
    }

    // 粒子（归一化坐标 -> 像素）
    for (final p in game.particles) {
      final alpha = (p.life / p.max).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        Paint()..color = p.color.withValues(alpha: alpha),
      );
    }

    // 飘字
    for (final ft in game.floatTexts) {
      final p = (ft.t / ft.dur).clamp(0.0, 1.0);
      _drawText(
        canvas,
        ft.text,
        Offset(ft.x * size.width, ft.y * size.height - 30 * p),
        15,
        ft.color.withValues(alpha: 1 - p),
        weight: FontWeight.w800,
      );
    }

    // 拖拽幽灵
    if (drag != null && drag.active && drag.def != null) {
      final s = cell - 6;
      _drawTile(
        canvas,
        drag.position - Offset(s / 2, s / 2),
        s,
        drag.def!,
        0.72,
      );
    }
  }

  void _strokeCell(
      Canvas canvas, int row, int col, double cell, Color color, double width) {
    canvas.drawRect(
      Rect.fromLTWH(col * cell + 2, row * cell + 2, cell - 4, cell - 4),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = color,
    );
  }

  void _drawBlock(Canvas canvas, Size size, Block b) {
    final cell = size.width / game.boardSize;
    final age = game.gameTime - b.createdAt;
    var scale = 1.0;
    if (age < 0.24) {
      scale = 0.4 + 0.6 * _easeOutBack(age / 0.24);
    }
    var alpha = 1.0;
    if (b.collectAt != null) {
      final p = (game.gameTime - b.collectAt!) / 0.55;
      if (p >= 1) return; // 已到收走时间，由控制器移除
      alpha = 1 - p;
    }
    final s = cell - 6;
    final x = b.col * cell + 3;
    final y = b.row * cell + 3;
    canvas.save();
    canvas.translate(x + s / 2, y + s / 2);
    canvas.scale(scale, scale);
    canvas.translate(-(x + s / 2), -(y + s / 2));
    _drawTile(canvas, Offset(x, y), s, b.def, alpha);

    // 灾害方块：脉动红圈
    if (b.def.type == '灾害') {
      // 与网页版一致：周期约 1.76s（网页版使用 performance.now() / 280）
      final pulse = 0.45 + 0.3 * math.sin(game.gameTime * (1000 / 280));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x + 1, y + 1, s - 2, s - 2), const Radius.circular(10)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = const Color(0xFFFF5050).withValues(alpha: pulse),
      );
    }
    canvas.restore();
  }

  /// 绘制一个元素方块（圆角、稀有度渐变、发光、图标、名称）
  void _drawTile(Canvas canvas, Offset topLeft, double s, ElementDef def,
      double alpha) {
    final rect = Rect.fromLTWH(topLeft.dx, topLeft.dy, s, s);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));
    final rarityColor = kRarityColors[def.rarity];

    canvas.saveLayer(
      rect,
      Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: alpha),
    );

    // 稀有发光
    if (def.rarity >= 2) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = rarityColor.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    // 渐变底
    final gradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [rarityColor, const Color(0xFF1C2440)],
      ).createShader(rect);
    canvas.drawRRect(rrect, gradient);

    // 高光 + 底部阴影
    final shade = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0x2EFFFFFF),
          const Color(0x00FFFFFF),
          const Color(0x4D000000),
        ],
      ).createShader(rect);
    canvas.drawRRect(rrect, shade);

    // 边框
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0x40FFFFFF),
    );

    // 图标
    final emojiSize = math.min(36.0, s * 0.5);
    _drawText(
      canvas,
      def.emoji,
      Offset(rect.center.dx, rect.center.dy - (s >= 52 ? 8 : 0)),
      emojiSize,
      const Color(0xFFFFFFFF),
    );

    // 名称（格子够大时）
    if (s >= 52) {
      _drawText(
        canvas,
        def.name,
        Offset(rect.center.dx, rect.bottom - s * 0.14),
        11,
        const Color(0xF2FFFFFF),
        weight: FontWeight.w700,
      );
    }
    canvas.restore();
  }

  void _drawMerge(Canvas canvas, Size size, MergeAnim a) {
    final cell = size.width / game.boardSize;
    final p = (a.t / a.dur).clamp(0.0, 1.0);
    final c1 = Offset((a.c1 + 0.5) * cell, (a.r1 + 0.5) * cell);
    final c2 = Offset((a.c2 + 0.5) * cell, (a.r2 + 0.5) * cell);
    final mid = (c1 + c2) / 2;
    final color = kRarityColors[elementById[a.rid]!.rarity];

    canvas.save();
    final alpha = 1 - p;
    // 两个旧元素向中心收缩
    for (final c in [c1, c2]) {
      final n = Offset.lerp(c, mid, p)!;
      canvas.drawCircle(
        n,
        cell * 0.36 * (1 - p * 0.6),
        Paint()..color = color.withValues(alpha: alpha),
      );
    }
    // 扩散环
    canvas.drawCircle(
      mid,
      cell * (0.3 + p * 1.15),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = color.withValues(alpha: alpha),
    );
    // 结果预览
    if (p > 0.65) {
      final q = (p - 0.65) / 0.35;
      _drawTile(
        canvas,
        Offset(a.col * cell + 3, a.row * cell + 3),
        cell - 6,
        elementById[a.rid]!,
        q * 0.9,
      );
    }
    canvas.restore();
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center,
    double fontSize,
    Color color, {
    FontWeight weight = FontWeight.w400,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: weight,
          height: 1.1,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  static double _easeOutBack(double t) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    final x = t - 1;
    return 1 + c3 * x * x * x + c1 * x * x;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 棋盘组件：Canvas + 手势（拖动方块、拖动到另一个方块上合成）
class BoardView extends ConsumerWidget {
  const BoardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.maxWidth;
        if (side <= 0) return const SizedBox.shrink();
        final game = ref.read(gameControllerProvider);
        final controller = ref.read(gameControllerProvider.notifier);
        game.setBoardPixelSize(side);
        return MouseRegion(
          onHover: (event) => controller.setHover(game.cellAt(event.localPosition)),
          onExit: (_) => controller.setHover(null),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (details) {
              final cell = game.cellAt(details.localPosition);
              if (cell != null && game.get(cell.$1, cell.$2) != null) {
                controller.startMapDrag(cell.$1, cell.$2, details.localPosition);
              }
            },
            onPanUpdate: (details) =>
                controller.updateDrag(details.localPosition),
            onPanEnd: (details) => controller.endMapDrag(details.localPosition),
            onPanCancel: () => controller.cancelDrag(),
            child: CustomPaint(
              size: Size.square(side),
              painter: BoardPainter(game),
            ),
          ),
        );
      },
    );
  }
}
