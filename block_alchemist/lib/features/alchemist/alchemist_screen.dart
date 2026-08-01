import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/elements.dart';
import 'game_controller.dart';
import 'board_painter.dart';
import 'widgets/codex_sheet.dart';
import 'widgets/goal_bar.dart';
import 'widgets/help_sheet.dart';
import 'widgets/selection_panel.dart';
import 'widgets/tray_bar.dart';

/// 游戏主界面
class AlchemistScreen extends ConsumerStatefulWidget {
  const AlchemistScreen({super.key});

  @override
  ConsumerState<AlchemistScreen> createState() => _AlchemistScreenState();
}

class _AlchemistScreenState extends ConsumerState<AlchemistScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  final GlobalKey _boardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (dt > 0) {
      ref.read(gameControllerProvider.notifier).tick(dt);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Offset _toBoardLocal(Offset global) {
    final box = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return Offset.zero;
    return box.globalToLocal(global);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 640;
    final compact = !isWide;
    // 手机端：选中方块时弹出底部详情面板
    ref.listen<int>(gameControllerProvider.select((c) => c.selectionRev), (
      prev,
      next,
    ) {
      if (next > (prev ?? 0) &&
          !isWide &&
          ref.read(gameControllerProvider).selected != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) showSelectionSheet(context);
        });
      }
    });

    final score = ref.watch(gameControllerProvider.select((c) => c.score));
    final discovered = ref.watch(
      gameControllerProvider.select((c) => c.discoveredCount),
    );
    final worldLabel = ref.watch(
      gameControllerProvider.select((c) => c.worldLabel),
    );
    final bars = ref.watch(gameControllerProvider.select((c) => c.calcBars()));
    final toast = ref.watch(gameControllerProvider.select((c) => c.toast));

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        _buildHeader(
                          context,
                          score,
                          discovered,
                          worldLabel,
                          bars,
                        ),
                        const SizedBox(height: 8),
                        const GoalBar(),
                        const SizedBox(height: 8),
                        // 手机端省略提示行，把高度让给棋盘
                        if (!compact)
                          const Text(
                            '🖐 长按材料栏元素拖到地图，把两个方块拖到一起尝试合成！',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF8A93B5),
                            ),
                          ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: isWide
                              ? Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: BoardView(key: _boardKey),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 250,
                                      child: SingleChildScrollView(
                                        child: SelectionPanel(),
                                      ),
                                    ),
                                  ],
                                )
                              // 手机端：棋盘独占剩余空间，不参与任何滚动，
                              // 避免与拖拽手势冲突
                              : Center(
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: BoardView(key: _boardKey),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 10),
                        TrayBar(toBoardLocal: _toBoardLocal),
                        const SizedBox(height: 10),
                        _buildFooter(context),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildToast(toast),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    int score,
    int discovered,
    String worldLabel,
    WorldBars bars,
  ) {
    final compact = MediaQuery.sizeOf(context).width < 640;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '🧪 方块炼金师',
                style: TextStyle(
                  fontSize: compact ? 21 : 24,
                  fontWeight: FontWeight.w800,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [
                        Color(0xFF8FB6FF),
                        Color(0xFFC39AFF),
                        Color(0xFFFFD34D),
                      ],
                    ).createShader(const Rect.fromLTWH(0, 0, 240, 30)),
                ),
              ),
            ),
            IconButton(
              tooltip: '帮助',
              icon: const Icon(Icons.help_outline),
              onPressed: () => showHelpSheet(context),
            ),
            IconButton(
              tooltip: '声音',
              icon: Icon(
                ref.watch(gameControllerProvider.select((c) => c.muted))
                    ? Icons.volume_off
                    : Icons.volume_up,
              ),
              onPressed: () =>
                  ref.read(gameControllerProvider.notifier).toggleMute(),
            ),
          ],
        ),
        SizedBox(height: compact ? 6 : 8),
        Row(
          children: [
            _StatCard(label: '炼金点', value: score.toString(), compact: compact),
            const SizedBox(width: 6),
            _StatCard(
              label: '探索进度',
              value: '$discovered/${kElements.length}',
              compact: compact,
            ),
            const SizedBox(width: 6),
            _StatCard(label: '世界等级', value: worldLabel, compact: compact),
          ],
        ),
        SizedBox(height: compact ? 6 : 8),
        if (compact)
          Row(
            children: [
              _MiniBar(
                label: '🌿',
                value: bars.nature,
                color: const Color(0xFF58D68D),
              ),
              const SizedBox(width: 6),
              _MiniBar(
                label: '⚙️',
                value: bars.tech,
                color: const Color(0xFF4DA3FF),
              ),
              const SizedBox(width: 6),
              _MiniBar(
                label: '🏛️',
                value: bars.prosperity,
                color: const Color(0xFFFFB62E),
              ),
            ],
          )
        else ...[
          _WorldBar(
            label: '🌿 自然',
            value: bars.nature,
            color: const Color(0xFF58D68D),
          ),
          const SizedBox(height: 4),
          _WorldBar(
            label: '⚙️ 科技',
            value: bars.tech,
            color: const Color(0xFF4DA3FF),
          ),
          const SizedBox(height: 4),
          _WorldBar(
            label: '🏛️ 繁荣',
            value: bars.prosperity,
            color: const Color(0xFFFFB62E),
          ),
        ],
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _HintButton(
            ready: ref.watch(gameControllerProvider.select((c) => c.hintReady)),
            onTap: () => ref.read(gameControllerProvider.notifier).useHint(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _FooterButton(
            icon: '📖',
            label: '图鉴',
            onTap: () => showCodexSheet(context),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _FooterButton(
            icon: '📜',
            label: '记录',
            onTap: () => showCodexSheet(context, initialTab: 1),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _FooterButton(
            icon: '🗑',
            label: '重置',
            onTap: () => _confirmReset(context),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('重置存档'),
        content: const Text('确定要清空所有存档吗？图鉴、记录和地图都会重置。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('确定重置'),
          ),
        ],
      ),
    );
    if (ok == true) {
      ref.read(gameControllerProvider.notifier).resetGame();
    }
  }

  Widget _buildToast(String? msg) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: AnimatedOpacity(
          opacity: msg == null ? 0 : 1,
          duration: const Duration(milliseconds: 250),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xE62B1B4D),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0x24FFFFFF)),
              boxShadow: const [
                BoxShadow(color: Color(0x80000000), blurRadius: 18),
              ],
            ),
            child: Text(
              msg ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.compact = false,
  });
  final String label;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: compact ? 5 : 8, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0x1F6EA8FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x2E6EA8FF)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: compact ? 9 : 10,
                color: Color(0xFF8A93B5),
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: compact ? 0 : 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 14 : 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 手机端紧凑版世界属性条（一行三条）
class _MiniBar extends StatelessWidget {
  const _MiniBar({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label $value',
            style: const TextStyle(fontSize: 9, color: Color(0xFF8A93B5)),
          ),
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 5,
              backgroundColor: const Color(0x14FFFFFF),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorldBar extends StatelessWidget {
  const _WorldBar({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 74,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF8A93B5)),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 7,
              backgroundColor: const Color(0x14FFFFFF),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterButton extends StatelessWidget {
  const _FooterButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0x0DFFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x17FFFFFF)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

/// 卡住提示按钮：就绪时高亮脉冲，点击给出一条合成线索
class _HintButton extends StatelessWidget {
  const _HintButton({required this.ready, required this.onTap});
  final bool ready;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: ready ? const Color(0x24FFD34D) : const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ready ? const Color(0xB3FFD34D) : const Color(0x17FFFFFF),
        ),
        boxShadow: ready
            ? const [BoxShadow(color: Color(0x59FFD34D), blurRadius: 14)]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(ready ? '💡' : '🔕', style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  ready ? '提示!' : '提示',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ready ? const Color(0xFFFFD34D) : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
