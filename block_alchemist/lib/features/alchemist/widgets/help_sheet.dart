import 'package:flutter/material.dart';

/// 玩法说明面板
void showHelpSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: const Color(0xFF161D33),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _HelpSheet(),
  );
}

class _HelpSheet extends StatelessWidget {
  const _HelpSheet();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.8,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                const Text('🧪 玩法说明',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: const [
                _Section(
                  title: '🎮 怎么玩',
                  items: [
                    '长按材料栏中的元素拖到地图上（轻点材料会自动放置到空格）',
                    '材料栏默认两行横向滚动，点 ⌄ 展开可浏览全部元素',
                    '把一个方块拖到另一个方块上：有配方就合成新元素',
                    '点击地图上的方块可查看属性、配方和它能合成什么',
                    '拖出地图外松手即可取消放置',
                  ],
                ),
                _Section(
                  title: '🧬 初始元素',
                  items: ['🔥 火 ｜ 💧 水 ｜ 🌍 土 ｜ 🌬️ 风 —— 一切从这四个元素开始'],
                ),
                _Section(
                  title: '🌍 世界成长',
                  items: [
                    '每发现一个新元素，世界就会成长，地图从 6×6 扩大到 8×8',
                    '自然 / 科技 / 繁荣三条属性由地图上的方块共同决定',
                  ],
                ),
                _Section(
                  title: '⚠️ 灾害事件',
                  items: [
                    '探索到一定程度后，干旱、洪水、地震等灾害会随机降临',
                    '灾害会拉低繁荣并占据空间，可以删除或等待自动消退',
                  ],
                ),
                _Section(
                  title: '💾 存档',
                  items: ['图鉴、记录、地图和分数自动保存在本地，无需网络'],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.items});
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6EA8FF))),
          const SizedBox(height: 6),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(item, style: const TextStyle(fontSize: 13)),
            ),
        ],
      ),
    );
  }
}
