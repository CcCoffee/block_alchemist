import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game_controller.dart';

/// 世界目标条：横向展示 3 个进行中的目标（进度条 + 奖励）
class GoalBar extends ConsumerWidget {
  const GoalBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 目标刷新 / 分数 / 图鉴 / 合成次数变化时重绘（避免跟随动画逐帧重建）
    ref.watch(gameControllerProvider.select((c) => c.goalRev));
    ref.watch(gameControllerProvider.select((c) => c.score));
    ref.watch(gameControllerProvider.select((c) => c.discoveredCount));
    ref.watch(gameControllerProvider.select((c) => c.mergeCount));
    final game = ref.read(gameControllerProvider);
    if (game.goals.isEmpty) return const SizedBox.shrink();
    final compact = MediaQuery.sizeOf(context).width < 640;

    return SizedBox(
      height: compact ? 46 : 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: game.goals.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final g = game.goals[i];
          final p = game.goalProgress(g).clamp(0, g.target);
          final pct = g.target == 0 ? 0.0 : p / g.target;
          return Container(
            width: compact ? 172 : 192,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0x17FFD34D), Color(0x08FFFFFF)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x38FFD34D)),
            ),
            child: Row(
              children: [
                Text(game.goalIcon(g), style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              game.goalLabel(g),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0x249AD0FF),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              kGoalStageNames[g.tier] ?? '自然',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF9AD0FF),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 4,
                          backgroundColor: const Color(0x1AFFFFFF),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFFFD34D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${p.clamp(0, g.target)}/${g.target}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFFD34D),
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x249AD0FF),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        '+${g.reward}',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF9AD0FF),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
