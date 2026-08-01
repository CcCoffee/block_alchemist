import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/elements.dart';
import '../game_controller.dart';
import '../sound_service.dart';

/// 材料栏：已发现的元素，可拖出到地图 / 轻点自动放置
class TrayBar extends ConsumerStatefulWidget {
  const TrayBar({super.key, required this.toBoardLocal});

  /// 全局坐标 -> 棋盘本地坐标
  final Offset Function(Offset global) toBoardLocal;

  @override
  ConsumerState<TrayBar> createState() => _TrayBarState();
}

class _TrayBarState extends ConsumerState<TrayBar> {
  final _search = TextEditingController();
  String _type = 'all';
  bool _expanded = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 只在解锁数量变化时重建列表
    ref.watch(gameControllerProvider.select((c) => c.discoveryRev));
    final game = ref.read(gameControllerProvider);
    final compact = MediaQuery.sizeOf(context).width < 640;
    final q = _search.text.trim().toLowerCase();
    final list = kElements
        .where((e) => game.discovered.contains(e.id))
        .where((e) => _type == 'all' || e.type == _type)
        .where((e) => q.isEmpty || e.name.toLowerCase().contains(q))
        .toList();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x17FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: '搜索已发现的元素…',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 110,
                child: DropdownButtonFormField<String>(
                  initialValue: _type,
                  isDense: true,
                  decoration: const InputDecoration(isDense: true),
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('全部类型')),
                    for (final t in kTypeList)
                      DropdownMenuItem(value: t, child: Text(t)),
                  ],
                  onChanged: (v) => setState(() => _type = v ?? 'all'),
                ),
              ),
              IconButton(
                tooltip: _expanded ? '收起材料栏' : '展开材料栏',
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () => setState(() => _expanded = !_expanded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                '没有符合条件的元素',
                style: TextStyle(color: Color(0xFF8A93B5)),
              ),
            )
          else if (!_expanded)
            // 收起状态：固定两行高度 + 横向滚动，
            // 既方便浏览所有元素，又不随发现数量挤占棋盘高度
            SizedBox(
              height: compact ? 88 : 104,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 第一行：偶数位元素
                          Row(
                            children: [
                              for (var i = 0; i < list.length; i += 2)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _TrayChip(
                                    element: list[i],
                                    toLocal: widget.toBoardLocal,
                                    compact: compact,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // 第二行：奇数位元素
                          Row(
                            children: [
                              for (var i = 1; i < list.length; i += 2)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _TrayChip(
                                    element: list[i],
                                    toLocal: widget.toBoardLocal,
                                    compact: compact,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 左右渐隐：提示横向还有更多元素
                  _EdgeFade(left: true),
                  _EdgeFade(left: false),
                ],
              ),
            )
          else
            // 展开状态：固定高度区域内滚动，棋盘尺寸不受影响
            SizedBox(
              height: compact ? 118 : 170,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final e in list)
                            _TrayChip(
                              element: e,
                              toLocal: widget.toBoardLocal,
                              compact: compact,
                            ),
                        ],
                      ),
                    ),
                  ),
                  // 上下渐隐：提示纵向还有更多元素
                  _VerticalFade(top: true),
                  _VerticalFade(top: false),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// 横向滚动边缘渐隐
class _EdgeFade extends StatelessWidget {
  const _EdgeFade({required this.left});
  final bool left;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left ? 0 : null,
      right: left ? null : 0,
      top: 0,
      bottom: 0,
      width: 24,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: left ? Alignment.centerLeft : Alignment.centerRight,
              end: left ? Alignment.centerRight : Alignment.centerLeft,
              colors: const [Color(0xE6161D33), Color(0x00161D33)],
            ),
          ),
        ),
      ),
    );
  }
}

/// 纵向滚动边缘渐隐
class _VerticalFade extends StatelessWidget {
  const _VerticalFade({required this.top});
  final bool top;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: top ? 0 : null,
      bottom: top ? null : 0,
      height: 16,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: top ? Alignment.topCenter : Alignment.bottomCenter,
              end: top ? Alignment.bottomCenter : Alignment.topCenter,
              colors: const [Color(0xE6161D33), Color(0x00161D33)],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrayChip extends ConsumerWidget {
  const _TrayChip({
    required this.element,
    required this.toLocal,
    required this.compact,
  });
  final ElementDef element;
  final Offset Function(Offset global) toLocal;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(gameControllerProvider.notifier);
    final unknown = controller.unknownChildren(element.id);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // 轻点：自动放置到第一个空格；长按：进入拖拽（避免与横向滚动冲突）
      onTap: () => controller.tapTrayChip(element.id),
      onLongPressStart: (d) {
        SoundService.longPressConfirm();
        controller.startTrayDrag(element.id, toLocal(d.globalPosition));
      },
      onLongPressMoveUpdate: (d) =>
          controller.updateDrag(toLocal(d.globalPosition)),
      onLongPressEnd: (d) => controller.endTrayDrag(toLocal(d.globalPosition)),
      onLongPressCancel: () => controller.cancelDrag(),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 9 : 12,
          vertical: compact ? 5 : 8,
        ),
        decoration: BoxDecoration(
          color: const Color(0x0FFFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: kRarityColors[element.rarity].withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(element.emoji, style: TextStyle(fontSize: compact ? 16 : 19)),
            SizedBox(width: compact ? 4 : 6),
            Text(
              element.name,
              style: TextStyle(
                fontSize: compact ? 12 : 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (unknown > 0)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0x24FFD34D),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: const Color(0x4DFFD34D)),
                ),
                child: Text(
                  '🔗$unknown',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFFD34D),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
