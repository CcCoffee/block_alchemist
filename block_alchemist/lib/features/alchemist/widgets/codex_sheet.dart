import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/elements.dart';
import '../game_controller.dart';

/// 图鉴 / 解锁记录底部面板
void showCodexSheet(BuildContext context, {int initialTab = 0}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: const Color(0xFF161D33),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => CodexSheet(initialTab: initialTab),
  );
}

class CodexSheet extends ConsumerStatefulWidget {
  const CodexSheet({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  ConsumerState<CodexSheet> createState() => _CodexSheetState();
}

class _CodexSheetState extends ConsumerState<CodexSheet> {
  late int _tab = widget.initialTab;
  final _search = TextEditingController();
  String _type = 'all';
  String? _detailId;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(gameControllerProvider.select((c) => c.discoveryRev));
    final game = ref.read(gameControllerProvider);
    final height = MediaQuery.sizeOf(context).height * 0.88;
    final dCounts = <String, int>{};
    final tCounts = <String, int>{};
    for (final e in kElements) {
      tCounts[e.type] = (tCounts[e.type] ?? 0) + 1;
      if (game.discovered.contains(e.id)) {
        dCounts[e.type] = (dCounts[e.type] ?? 0) + 1;
      }
    }

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                _TabButton(
                  label: '📖 图鉴',
                  active: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
                const SizedBox(width: 8),
                _TabButton(
                  label: '📜 解锁记录',
                  active: _tab == 1,
                  onTap: () => setState(() => _tab = 1),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          if (_tab == 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: '搜索元素名称…',
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 宽度跟随文字自适应，避免固定宽度与内容不匹配
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0x14FFFFFF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0x1FFFFFFF)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _type,
                        isDense: true,
                        borderRadius: BorderRadius.circular(10),
                        dropdownColor: const Color(0xFF1B2340),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: Color(0xFF8A93B5),
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFE8ECF8),
                        ),
                        // 收起状态只显示短标签，完整数量在展开菜单里
                        selectedItemBuilder: (context) => [
                          const Text('全部类型'),
                          for (final t in kTypeList) Text(t),
                        ],
                        items: [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text(
                              '全部类型 · ${game.discoveredCount}/${kElements.length}',
                            ),
                          ),
                          for (final t in kTypeList)
                            DropdownMenuItem(
                              value: t,
                              child: Text(
                                '$t · ${dCounts[t] ?? 0}/${tCounts[t] ?? 0}',
                              ),
                            ),
                        ],
                        onChanged: (v) => setState(() => _type = v ?? 'all'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: _tab == 0
                ? _buildCodex(game)
                : _buildRecords(game),
          ),
        ],
      ),
    );
  }

  Widget _buildCodex(GameController game) {
    final q = _search.text.trim().toLowerCase();
    final list = kElements
        .where((e) => _type == 'all' || e.type == _type)
        .where((e) => q.isEmpty || e.name.toLowerCase().contains(q))
        .toList();
    final detail = _detailId == null ? null : elementById[_detailId];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        if (detail != null && game.discovered.contains(detail.id)) ...[
          _CodexDetailCard(element: detail, game: game),
          const SizedBox(height: 10),
        ],
        GridView.count(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.92,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final e in list)
              _CodexCard(
                element: e,
                discovered: game.discovered.contains(e.id),
                onTap: game.discovered.contains(e.id)
                    ? () => setState(() => _detailId = e.id)
                    : null,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecords(GameController game) {
    if (game.records.isEmpty) {
      return const Center(
        child: Text('还没有解锁记录，去发现新元素吧！',
            style: TextStyle(color: Color(0xFF8A93B5))),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        for (final r in game.records)
          ListTile(
            dense: true,
            leading: const Text('✨'),
            title: Text('发现 ${elementById[r.id]!.emoji} ${elementById[r.id]!.name}'),
            trailing: Text(
              _formatTime(r.t),
              style: const TextStyle(fontSize: 11, color: Color(0xFF8A93B5)),
            ),
          ),
      ],
    );
  }

  String _formatTime(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? const Color(0x266EA8FF)
              : const Color(0x0FFFFFFF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? const Color(0x596EA8FF)
                : const Color(0x0FFFFFFF),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: active
                ? const Color(0xFFEEF2FF)
                : const Color(0xFF8A93B5),
          ),
        ),
      ),
    );
  }
}

class _CodexCard extends StatelessWidget {
  const _CodexCard({
    required this.element,
    required this.discovered,
    required this.onTap,
  });
  final ElementDef element;
  final bool discovered;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = kRarityColors[element.rarity];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0x0AFFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: discovered
                ? color.withValues(alpha: 0.5)
                : const Color(0x0FFFFFFF),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              discovered ? element.emoji : '❓',
              style: const TextStyle(fontSize: 26),
            ),
            const SizedBox(height: 3),
            Text(
              discovered ? element.name : '???',
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              discovered
                  ? (childrenOf(element.id).isEmpty
                      ? '🏁 最终'
                      : kRarityNames[element.rarity])
                  : '未发现',
              style: TextStyle(
                fontSize: 9,
                color: discovered ? color : const Color(0xFF8A93B5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CodexDetailCard extends StatelessWidget {
  const _CodexDetailCard({required this.element, required this.game});
  final ElementDef element;
  final GameController game;

  @override
  Widget build(BuildContext context) {
    final allChildren = childrenOf(element.id);
    final children = allChildren
        .where((c) => game.discovered.contains(c.id))
        .toList();
    final recipePairs = recipePairsOf(element.id);
    String name(ElementDef p) => game.discovered.contains(p.id)
        ? '${p.emoji} ${p.name}'
        : '❓ ???';
    final parentText = recipePairs.isEmpty
        ? '初始元素'
        : recipePairs
            .map((pair) => pair.map(name).join(' + '))
            .join(' 或 ');
    final childrenText = children.isEmpty
        ? (allChildren.isEmpty ? '🏁 最终物品，无法再参与合成' : '暂无')
        : children.map((c) => '${c.emoji} ${c.name}').join('、');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x0F6EA8FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x266EA8FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${element.emoji} ${element.name}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Text('${kRarityNames[element.rarity]} · ${element.type}',
                  style: TextStyle(
                      fontSize: 12,
                      color: kRarityColors[element.rarity],
                      fontWeight: FontWeight.w700)),
            ],
          ),
          Text(element.desc,
              style: const TextStyle(fontSize: 12, color: Color(0xFF8A93B5))),
          const SizedBox(height: 4),
          Text('📜 合成：$parentText → ${element.emoji}',
              style: const TextStyle(fontSize: 13)),
          Text('🔬 能合成：$childrenText', style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
