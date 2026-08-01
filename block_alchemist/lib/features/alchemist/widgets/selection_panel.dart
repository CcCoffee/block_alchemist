import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/elements.dart';
import '../game_controller.dart';

/// 手机端：以底部面板方式展示选中方块详情（不占棋盘空间）
void showSelectionSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: const Color(0xFF161D33),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _SelectionSheet(),
  );
}

class _SelectionSheet extends ConsumerStatefulWidget {
  const _SelectionSheet();

  @override
  ConsumerState<_SelectionSheet> createState() => _SelectionSheetState();
}

class _SelectionSheetState extends ConsumerState<_SelectionSheet> {
  @override
  Widget build(BuildContext context) {
    // 方块被删除或取消选中时自动关闭面板
    ref.listen<Block?>(gameControllerProvider.select((c) => c.selected), (
      prev,
      next,
    ) {
      if (next == null) Navigator.of(context).maybePop();
    });
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: SelectionPanel(),
      ),
    );
  }
}

/// 选中方块详情面板
class SelectionPanel extends ConsumerWidget {
  const SelectionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameControllerProvider);
    final block = game.selected;
    if (block == null) {
      return const _PanelBox(
        child: Text(
          '🧩 点击地图上的方块查看详情',
          style: TextStyle(color: Color(0xFF8A93B5), fontSize: 13),
        ),
      );
    }

    final def = block.def;
    final rarityColor = kRarityColors[def.rarity];
    final recipePairs = recipePairsOf(def.id);
    final children = childrenOf(def.id);
    final knownChildren = children.where((c) => game.discovered.contains(c.id));
    final unknownCount = children.length - knownChildren.length;
    final isDisaster = def.type == '灾害';
    final cureId = kDisasterCures[def.id];
    final cure = cureId == null ? null : elementById[cureId];
    final cureKnown = cure != null && game.discovered.contains(cure.id);
    final cureParents = cure == null || cure.recipes.isEmpty
        ? <ElementDef>[]
        : cure.recipes.first.map((id) => elementById[id]!).toList();

    return _PanelBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(def.emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      def.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${kRarityNames[def.rarity]} · ${def.type}',
                      style: TextStyle(
                        fontSize: 12,
                        color: rarityColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            def.desc,
            style: const TextStyle(fontSize: 12, color: Color(0xFF8A93B5)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _attr('🌿 自然', def.nature),
              const SizedBox(width: 6),
              _attr('⚙️ 科技', def.tech),
              const SizedBox(width: 6),
              _attr('🏛️ 繁荣', def.prosperity),
              const SizedBox(width: 6),
              _attr('💎 价值', def.value),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '📜 合成配方',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF6EA8FF),
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: recipePairs.isEmpty
                ? const [InfoChip(text: '✨ 初始元素', locked: false)]
                : [
                    for (var i = 0; i < recipePairs.length; i++) ...[
                      if (i > 0) const InfoChip(text: '或', locked: false),
                      InfoChip(
                        text: _recipeName(recipePairs[i][0], game),
                        locked: !game.discovered.contains(recipePairs[i][0].id),
                      ),
                      const InfoChip(text: '+', locked: false),
                      InfoChip(
                        text: _recipeName(recipePairs[i][1], game),
                        locked: !game.discovered.contains(recipePairs[i][1].id),
                      ),
                    ],
                  ],
          ),
          const SizedBox(height: 8),
          const Text(
            '🔬 可以合成',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF6EA8FF),
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final c in knownChildren)
                InfoChip(text: '${c.emoji} ${c.name}', locked: false),
              if (unknownCount > 0)
                InfoChip(text: '❓ 还有 $unknownCount 种未发现', locked: true),
              if (children.isEmpty)
                const InfoChip(text: '暂无已知配方', locked: false),
            ],
          ),
          if (isDisaster) ...[
            const SizedBox(height: 8),
            const Text(
              '🚒 救灾配方',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF7BED9F),
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (cure != null)
                  InfoChip(
                    text: cureKnown ? '${cure.emoji} ${cure.name}' : '❓ ???',
                    locked: !cureKnown,
                  ),
              ],
            ),
            if (cureParents.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '可由 ${cureParents.map((p) => p.name).join(' + ')} 合成',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8A93B5),
                  ),
                ),
              ),
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                '把救灾元素拖到灾害上即可化解，成功 +$kCureReward 炼金点',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF7BED9F),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFFB3B3),
                side: const BorderSide(color: Color(0x66FF5A5A)),
              ),
              onPressed: isDisaster
                  ? null
                  : () => ref
                        .read(gameControllerProvider.notifier)
                        .deleteSelected(),
              icon: Icon(
                isDisaster ? Icons.block : Icons.delete_outline,
                size: 18,
              ),
              label: Text(isDisaster ? '灾害需救灾化解' : '删除方块'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _attr(String label, int value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0x0FFFFFFF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF8A93B5)),
            ),
            Text(
              '$value',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

String _recipeName(ElementDef e, GameController game) =>
    game.discovered.contains(e.id) ? '${e.emoji} ${e.name}' : '❓ ???';

class _PanelBox extends StatelessWidget {
  const _PanelBox({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x17FFFFFF)),
      ),
      child: child,
    );
  }
}

class InfoChip extends StatelessWidget {
  const InfoChip({super.key, required this.text, required this.locked});
  final String text;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x0FFFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: locked ? const Color(0x14FFFFFF) : const Color(0x17FFFFFF),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: locked ? const Color(0xFF8A93B5) : const Color(0xFFEEF2FF),
        ),
      ),
    );
  }
}
