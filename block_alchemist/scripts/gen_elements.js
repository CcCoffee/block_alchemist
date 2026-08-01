#!/usr/bin/env node
/**
 * 方块炼金师 - 元素数据生成脚本
 *
 * 从网页版的 data.js（位于仓库根目录）读取 185 种元素，
 * 生成 Flutter 工程使用的 Dart 数据文件：
 *   lib/features/alchemist/data/elements.dart
 *
 * 用法（在项目根目录 block_alchemist/ 下执行）:
 *   node scripts/gen_elements.js
 *
 * 数据源与 Flutter 版保持一致，改动元素表后重新生成即可。
 */
'use strict';

const fs = require('fs');
const path = require('path');
const vm = require('vm');

const scriptDir = __dirname;
const projectRoot = path.join(scriptDir, '..');
const dataJsPath = path.join(projectRoot, '..', 'data.js');
const outPath = path.join(
  projectRoot,
  'lib',
  'features',
  'alchemist',
  'data',
  'elements.dart',
);

if (!fs.existsSync(dataJsPath)) {
  console.error(`找不到数据源: ${dataJsPath}`);
  process.exit(1);
}

// 在 VM 中执行 data.js 并导出数据
const ctx = {};
vm.createContext(ctx);
const code =
  fs.readFileSync(dataJsPath, 'utf8') +
  '\nglobalThis.__EXPORT = { ELEMENTS, RARITY_INFO, TYPE_LIST, STARTER_IDS };';
vm.runInContext(code, ctx);
const { ELEMENTS, RARITY_INFO, STARTER_IDS } = ctx.__EXPORT;

const q = (s) =>
  `'${String(s).replace(/\\/g, '\\\\').replace(/'/g, "\\'")}'`;

const lines = [];
lines.push('// 由 scripts/gen_elements.js 自动生成 — 方块炼金师元素数据（请勿手改）');
lines.push("import 'dart:ui' show Color;");
lines.push('');
lines.push('/// 元素定义：名称 / 类型 / 稀有度 / 属性 / 配方');
lines.push('class ElementDef {');
lines.push('  final String id;');
lines.push('  final String name;');
lines.push('  final String emoji;');
lines.push('  final String type;');
lines.push('  final int rarity;');
lines.push('  final String desc;');
lines.push('  final int nature;');
lines.push('  final int tech;');
lines.push('  final int prosperity;');
lines.push('  final int value;');
lines.push('  /// 全部配方（无序对 [a, b]）；空列表表示初始元素');
lines.push('  final List<List<String>> recipes;');
lines.push('  /// 主配方（第一个），用于简单展示');
lines.push('  List<String>? get recipe => recipes.isEmpty ? null : recipes.first;');
lines.push('  const ElementDef({');
lines.push('    required this.id,');
lines.push('    required this.name,');
lines.push('    required this.emoji,');
lines.push('    required this.type,');
lines.push('    required this.rarity,');
lines.push('    required this.desc,');
lines.push('    required this.nature,');
lines.push('    required this.tech,');
lines.push('    required this.prosperity,');
lines.push('    required this.value,');
lines.push('    required this.recipes,');
lines.push('  });');
lines.push('}');
lines.push('');
lines.push('const List<ElementDef> kElements = <ElementDef>[');
for (const e of ELEMENTS) {
  const recipes = e.recipes.length
    ? `[${e.recipes.map((r) => `[${r.map(q).join(', ')}]`).join(', ')}]`
    : '[]';
  lines.push(
    `  ElementDef(id: ${q(e.id)}, name: ${q(e.name)}, emoji: ${q(e.emoji)}, ` +
      `type: ${q(e.type)}, rarity: ${e.rarity}, desc: ${q(e.desc)}, ` +
      `nature: ${e.attrs.nature}, tech: ${e.attrs.tech}, ` +
      `prosperity: ${e.attrs.prosperity}, value: ${e.attrs.value}, recipes: ${recipes}),`,
  );
}
lines.push('];');
lines.push('');
lines.push(
  `const List<String> kRarityNames = <String>[${RARITY_INFO.map((r) => q(r.key)).join(', ')}];`,
);
lines.push('const List<Color> kRarityColors = <Color>[');
for (const r of RARITY_INFO) {
  lines.push(`  Color(0xFF${r.color.replace('#', '')}),`);
}
lines.push('];');
lines.push('');
lines.push(`const List<String> kStarterIds = <String>[${STARTER_IDS.map(q).join(', ')}];`);
lines.push('');
lines.push('/// id -> 元素');
lines.push('final Map<String, ElementDef> elementById = <String, ElementDef>{');
lines.push('  for (final e in kElements) e.id: e,');
lines.push('};');
lines.push('');
lines.push('String _pairKey(String a, String b) => a.compareTo(b) <= 0 ? "$a|$b" : "$b|$a";');
lines.push('');
lines.push('final Map<String, String> _recipeIndex = <String, String>{');
lines.push('  for (final e in kElements)');
lines.push('    for (final r in e.recipes) _pairKey(r[0], r[1]): e.id,');
lines.push('};');
lines.push('');
lines.push('/// 查询两个元素的合成结果；没有配方返回 null');
lines.push('String? findRecipe(String? aId, String? bId) {');
lines.push('  if (aId == null || bId == null) return null;');
lines.push('  return _recipeIndex[_pairKey(aId, bId)];');
lines.push('}');
lines.push('');
lines.push('/// 某元素能参与合成的所有“孩子”');
lines.push('List<ElementDef> childrenOf(String id) => kElements');
lines.push('    .where((e) => e.recipes.any((r) => r[0] == id || r[1] == id))');
lines.push('    .toList();');
lines.push('');
lines.push('/// 某元素的主配方“父母”');
lines.push('List<ElementDef> parentsOf(String id) {');
lines.push('  final e = elementById[id];');
lines.push('  if (e == null || e.recipe == null) return const [];');
lines.push('  return e.recipe!.map((p) => elementById[p]!).toList();');
lines.push('}');
lines.push('');
lines.push('/// 某元素的全部配方（每对返回 [父A, 父B]）');
lines.push('List<List<ElementDef>> recipePairsOf(String id) {');
lines.push('  final e = elementById[id];');
lines.push('  if (e == null) return const [];');
lines.push('  return e.recipes');
lines.push('      .map((r) => [elementById[r[0]]!, elementById[r[1]]!])');
lines.push('      .toList();');
lines.push('}');
lines.push('');
lines.push(
  "final List<String> kDisasterIds = kElements.where((e) => e.type == '灾害').map((e) => e.id).toList();",
);
const types = [...new Set(ELEMENTS.map((e) => e.type))];
lines.push(`final List<String> kTypeList = <String>[${types.map(q).join(', ')}];`);

fs.writeFileSync(outPath, lines.join('\n') + '\n');
console.log(`✔ 已生成 ${path.relative(projectRoot, outPath)}（${ELEMENTS.length} 种元素）`);
