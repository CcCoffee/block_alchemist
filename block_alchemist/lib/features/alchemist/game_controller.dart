import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/game_storage.dart';
import 'data/elements.dart';
import 'sound_service.dart';

/* ============================ 世界等级 ============================ */

class WorldLevel {
  final int min;
  final String name;
  final int size;
  const WorldLevel({required this.min, required this.name, required this.size});
}

const List<WorldLevel> kWorldLevels = <WorldLevel>[
  WorldLevel(min: 0, name: '原始荒原', size: 6),
  WorldLevel(min: 10, name: '生机萌芽', size: 6),
  WorldLevel(min: 25, name: '部落聚落', size: 7),
  WorldLevel(min: 45, name: '繁荣村镇', size: 7),
  WorldLevel(min: 70, name: '工业城市', size: 8),
  WorldLevel(min: 95, name: '科技王国', size: 8),
  WorldLevel(min: 120, name: '星际文明', size: 8),
  WorldLevel(min: 150, name: '炼金之神', size: 8),
];

/* ============================ 游戏模型 ============================ */

class Block {
  Block(this.elementId, this.row, this.col, double time)
    : createdAt = time,
      id = _seq++;
  static int _seq = 1;

  final int id;
  final String elementId;
  int row;
  int col;
  final double createdAt;
  bool removed = false;
  double? expiresAt; // 灾害方块存活到的现实时间（毫秒时间戳）

  ElementDef get def => elementById[elementId]!;
}

/// 合成动画（格子坐标 + 进度）
class MergeAnim {
  MergeAnim({
    required this.r1,
    required this.c1,
    required this.r2,
    required this.c2,
    required this.rid,
    required this.row,
    required this.col,
  });

  final int r1, c1, r2, c2;
  final String rid;
  final int row, col;
  final double dur = 0.42;
  double t = 0;
}

/// 粒子（归一化坐标 0~1，随画布缩放）
class Particle {
  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
  }) : life = 0.5 + Random().nextDouble() * 0.4,
       max = 0.9,
       size = 3 + Random().nextDouble() * 4;

  double x, y, vx, vy, life;
  final double max;
  final double size;
  final Color color;
}

class FloatText {
  FloatText({
    required this.x,
    required this.y,
    required this.text,
    required this.color,
  });

  final double x, y;
  final String text;
  final Color color;
  final double dur = 0.9;
  double t = 0;
}

class CellFlash {
  CellFlash({required this.row, required this.col, required this.color});
  final int row, col;
  final Color color;
  final double dur = 0.35;
  double t = 0;
}

/// 拖拽会话（地图方块 / 材料栏）
class DragState {
  DragState.map({
    required Block block,
    required this.fromRow,
    required this.fromCol,
  }) : kind = 'map',
       block = block,
       elementId = block.elementId;

  DragState.tray({required this.elementId})
    : kind = 'tray',
      block = null,
      fromRow = -1,
      fromCol = -1;

  final String kind;
  final Block? block;
  final String? elementId;
  final int fromRow, fromCol;
  Offset start = Offset.zero;
  Offset position = Offset.zero;
  bool active = false;

  ElementDef? get def => kind == 'tray' ? elementById[elementId!] : block?.def;
}

class RecordEntry {
  RecordEntry(this.id, this.t);
  final String id;
  final int t;

  Map<String, dynamic> toJson() => {'id': id, 't': t};

  static RecordEntry fromJson(Map<String, dynamic> m) =>
      RecordEntry(m['id'] as String, (m['t'] as num?)?.toInt() ?? 0);
}

class WorldBars {
  final double nature, tech, prosperity;
  const WorldBars({
    required this.nature,
    required this.tech,
    required this.prosperity,
  });
}

/* ============================ 世界目标 ============================ */

/// 目标：type（发现某类型元素）/ element（发现指定元素）/
/// merge（合成次数）/ score（累计积分）
class Goal {
  const Goal({
    required this.kind,
    required this.target,
    required this.reward,
    this.typeName,
    this.elementId,
  });

  final String kind;
  final String? typeName;
  final String? elementId;
  final int target;
  final int reward;

  String get key => '$kind|${typeName ?? elementId ?? ''}|$target';

  Map<String, dynamic> toJson() => <String, dynamic>{
    'kind': kind,
    'typeName': typeName,
    'elementId': elementId,
    'target': target,
    'reward': reward,
  };

  static Goal fromJson(Map<String, dynamic> m) => Goal(
    kind: m['kind'] as String? ?? 'merge',
    typeName: m['typeName'] as String?,
    elementId: m['elementId'] as String?,
    target: (m['target'] as num?)?.toInt() ?? 5,
    reward: (m['reward'] as num?)?.toInt() ?? 50,
  );
}

const List<Goal> kGoalTemplates = <Goal>[
  Goal(kind: 'type', typeName: '动物', target: 3, reward: 80),
  Goal(kind: 'type', typeName: '植物', target: 4, reward: 80),
  Goal(kind: 'type', typeName: '工具', target: 2, reward: 80),
  Goal(kind: 'type', typeName: '建筑', target: 3, reward: 100),
  Goal(kind: 'type', typeName: '科技', target: 2, reward: 120),
  Goal(kind: 'type', typeName: '文明', target: 2, reward: 120),
  Goal(kind: 'type', typeName: '食物', target: 4, reward: 80),
  Goal(kind: 'type', typeName: '神话', target: 2, reward: 150),
  Goal(kind: 'element', elementId: 'rainbow', target: 1, reward: 120),
  Goal(kind: 'element', elementId: 'city', target: 1, reward: 150),
  Goal(kind: 'element', elementId: 'electricity', target: 1, reward: 100),
  Goal(kind: 'element', elementId: 'robot', target: 1, reward: 150),
  Goal(kind: 'element', elementId: 'airplane', target: 1, reward: 120),
  Goal(kind: 'element', elementId: 'library', target: 1, reward: 120),
  Goal(kind: 'element', elementId: 'rocket', target: 1, reward: 180),
  Goal(kind: 'element', elementId: 'dragon', target: 1, reward: 200),
  Goal(kind: 'element', elementId: 'phoenix', target: 1, reward: 200),
  Goal(kind: 'element', elementId: 'mermaid', target: 1, reward: 150),
  Goal(kind: 'merge', target: 10, reward: 100),
  Goal(kind: 'merge', target: 30, reward: 150),
  Goal(kind: 'merge', target: 60, reward: 250),
  Goal(kind: 'score', target: 500, reward: 100),
  Goal(kind: 'score', target: 2000, reward: 200),
  Goal(kind: 'score', target: 5000, reward: 400),
];

const Map<String, String> kGoalTypeIcons = <String, String>{
  '动物': '🐾',
  '植物': '🌱',
  '工具': '🛠️',
  '建筑': '🏗️',
  '科技': '⚙️',
  '文明': '🏛️',
  '食物': '🍲',
  '神话': '✨',
};
const Map<String, String> kGoalKindIcons = <String, String>{
  'merge': '🔗',
  'score': '💰',
};

List<T> _shuffle<T>(List<T> list, Random rnd) {
  final out = list.toList();
  for (var i = out.length - 1; i > 0; i--) {
    final j = rnd.nextInt(i + 1);
    final tmp = out[i];
    out[i] = out[j];
    out[j] = tmp;
  }
  return out;
}

/* ============================ 状态控制器 ============================ */

final gameControllerProvider = ChangeNotifierProvider<GameController>((ref) {
  // ChangeNotifierProvider 会在 provider 销毁时自动 dispose notifier
  return GameController(GameStorage.instance);
});

class GameController extends ChangeNotifier {
  GameController(this._storage, {DateTime Function()? now})
    : _now = now ?? DateTime.now {
    lastDiscoveryAtMs = _wallMs;
    nextEventAtMs = _wallMs + 45000; // 开局 45 秒后才可能降临灾害
    _load();
  }

  final GameStorage _storage;
  final DateTime Function() _now; // 可注入的现实时钟（测试用）
  final Random _rnd = Random();
  double _time = 0;

  /// 现实时间（毫秒时间戳）。所有倒计时都用它，保证与真实时间一致：
  /// 应用退到后台、帧被暂停时，倒计时仍然按真实时间走。
  double get _wallMs => _now().millisecondsSinceEpoch.toDouble();

  List<List<Block?>> grid = [];
  int boardSize = 6;
  Set<String> discovered = <String>{...kStarterIds};
  List<RecordEntry> records = <RecordEntry>[];
  int score = 0;
  Block? selected;
  DragState? drag;
  (int, int)? hover;
  List<MergeAnim> mergeAnims = <MergeAnim>[];
  List<Particle> particles = <Particle>[];
  List<FloatText> floatTexts = <FloatText>[];
  List<CellFlash> cellFlashes = <CellFlash>[];
  int worldIndex = -1;
  bool muted = false;
  String? toast;
  double _toastUntilMs = 0;
  double nextEventAtMs = 0; // 下次灾害检查的现实时间点
  int _discoveryRev = 0;
  int _selectRev = 0;
  int _goalRev = 0;
  int mergeCount = 0; // 累计成功合成次数（目标进度）
  int failStreak = 0; // 连续失败次数（卡住判定）
  double lastDiscoveryAtMs = 0; // 上次新发现时间（现实毫秒）
  double lastHintAtMs = double.negativeInfinity; // 上次使用提示的时间（现实毫秒）
  double _hintCheck = 0;
  bool _lastHintReady = false;
  Map<String, int>? _depthCache; // 配方深度缓存
  List<Goal> goals = <Goal>[]; // 世界目标（3 个）
  double boardPixelSize = 0;

  int get discoveryRev => _discoveryRev;
  int get selectionRev => _selectRev;
  int get goalRev => _goalRev;
  double get gameTime => _time;
  int get discoveredCount => discovered.length;

  WorldLevel get worldLevel => kWorldLevels[worldIndex < 0 ? 0 : worldIndex];
  String get worldLabel => 'Lv${worldIndex + 1} ${worldLevel.name}';

  /* ================= 存档 ================= */

  void _load() {
    muted = _storage.muted;
    SoundService.enabled = !muted;
    final raw = _storage.save;
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        score = (map['score'] as num?)?.toInt() ?? 0;
        mergeCount = (map['mergeCount'] as num?)?.toInt() ?? 0;
        discovered = <String>{
          ...kStarterIds,
          ...?((map['discovered'] as List?)?.whereType<String>().where(
            elementById.containsKey,
          )),
        };
        records = ((map['records'] as List?) ?? const <dynamic>[])
            .map((e) => RecordEntry.fromJson(e as Map<String, dynamic>))
            .where((r) => elementById.containsKey(r.id))
            .take(300)
            .toList();
        final goalList = map['goals'] as List?;
        goals = (goalList ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(Goal.fromJson)
            .where((g) => g.target > 0)
            .take(3)
            .toList();
        if (goals.length != 3) {
          goals = _makeGoals(discovered, const <String>[], 3);
        }
        boardSize = ((map['size'] as num?)?.toInt() ?? 6).clamp(6, 8);
        _newGrid(boardSize);
        final gridData = map['grid'] as List?;
        if (gridData != null) {
          for (var i = 0; i < gridData.length; i++) {
            final id = gridData[i];
            if (id is String && elementById.containsKey(id)) {
              final r = i ~/ boardSize;
              final c = i % boardSize;
              if (r < boardSize && c < boardSize && grid[r][c] == null) {
                grid[r][c] = Block(id, r, c, _time);
              }
            }
          }
        }
      } catch (_) {
        _seed();
      }
    } else {
      _seed();
      goals = _makeGoals(discovered, const <String>[], 3);
    }
    _updateWorld(notify: false);
    notifyListeners();
  }

  void _newGrid(int size) {
    grid = List<List<Block?>>.generate(
      size,
      (_) => List<Block?>.filled(size, null),
    );
  }

  /// 新开局：地图上先放火与水
  void _seed() {
    boardSize = 6;
    _newGrid(6);
    final a = randomEmptyCell();
    if (a != null) grid[a.$1][a.$2] = Block('fire', a.$1, a.$2, _time);
    final b = randomEmptyCell();
    if (b != null) grid[b.$1][b.$2] = Block('water', b.$1, b.$2, _time);
  }

  void save() {
    final flat = <String?>[];
    for (var r = 0; r < boardSize; r++) {
      for (var c = 0; c < boardSize; c++) {
        flat.add(grid[r][c]?.elementId);
      }
    }
    _storage.setSave(
      jsonEncode(<String, dynamic>{
        'v': 1,
        'score': score,
        'mergeCount': mergeCount,
        'discovered': discovered.toList(),
        'records': records.map((e) => e.toJson()).toList(),
        'goals': goals.map((g) => g.toJson()).toList(),
        'grid': flat,
        'size': boardSize,
      }),
    );
  }

  void resetGame() {
    discovered = <String>{...kStarterIds};
    records = <RecordEntry>[];
    score = 0;
    mergeCount = 0;
    failStreak = 0;
    lastDiscoveryAtMs = _wallMs;
    lastHintAtMs = double.negativeInfinity;
    nextEventAtMs = _wallMs + 45000;
    selected = null;
    drag = null;
    mergeAnims.clear();
    particles.clear();
    floatTexts.clear();
    cellFlashes.clear();
    _discoveryRev++;
    goals = _makeGoals(discovered, const <String>[], 3);
    _goalRev++;
    _seed();
    _updateWorld(notify: false);
    _storage.clearSave();
    showToast('🗑 已重置存档，重新开始探索吧');
  }

  /* ================= 棋盘基础 ================= */

  bool inBounds(int r, int c) =>
      r >= 0 && r < boardSize && c >= 0 && c < boardSize;

  Block? get(int r, int c) => inBounds(r, c) ? grid[r][c] : null;

  bool isEmpty(int r, int c) => inBounds(r, c) && grid[r][c] == null;

  (int, int)? randomEmptyCell() {
    final cells = <(int, int)>[];
    for (var r = 0; r < boardSize; r++) {
      for (var c = 0; c < boardSize; c++) {
        if (grid[r][c] == null) cells.add((r, c));
      }
    }
    return cells.isEmpty ? null : cells[_rnd.nextInt(cells.length)];
  }

  int countEmpty() {
    var n = 0;
    for (var r = 0; r < boardSize; r++) {
      for (var c = 0; c < boardSize; c++) {
        if (grid[r][c] == null) n++;
      }
    }
    return n;
  }

  List<Block> allBlocks() {
    final out = <Block>[];
    for (var r = 0; r < boardSize; r++) {
      for (var c = 0; c < boardSize; c++) {
        final b = grid[r][c];
        if (b != null) out.add(b);
      }
    }
    return out;
  }

  void setBoardPixelSize(double px) {
    if (px > 0) boardPixelSize = px;
  }

  /// 桌面端鼠标悬停高亮（与网页版行为一致）
  void setHover((int, int)? cell) {
    hover = cell;
    notifyListeners();
  }

  (int, int)? cellAt(Offset local) {
    if (boardPixelSize <= 0) return null;
    final cell = boardPixelSize / boardSize;
    final r = (local.dy / cell).floor();
    final c = (local.dx / cell).floor();
    return inBounds(r, c) ? (r, c) : null;
  }

  Offset centerNorm(int row, int col) =>
      Offset((col + 0.5) / boardSize, (row + 0.5) / boardSize);

  /* ================= 世界成长 ================= */

  int _calcWorldIndex() {
    var idx = 0;
    for (var i = 0; i < kWorldLevels.length; i++) {
      if (discovered.length >= kWorldLevels[i].min) idx = i;
    }
    return idx;
  }

  void _updateWorld({bool notify = true}) {
    final idx = _calcWorldIndex();
    final lv = kWorldLevels[idx];
    if (idx > worldIndex && notify && worldIndex >= 0) {
      SoundService.event();
      showToast('🌍 世界成长：${lv.name}！地图扩大为 ${lv.size}×${lv.size}');
    }
    worldIndex = idx;
    if (boardSize < lv.size) {
      final old = grid;
      boardSize = lv.size;
      _newGrid(lv.size);
      for (var r = 0; r < old.length; r++) {
        for (var c = 0; c < old[r].length; c++) {
          if (r < lv.size && c < lv.size) grid[r][c] = old[r][c];
        }
      }
    }
    if (notify) notifyListeners();
  }

  WorldBars calcBars() {
    double nature = 0, tech = 0, prosperity = 0;
    for (final b in allBlocks()) {
      nature += b.def.nature;
      tech += b.def.tech;
      prosperity += b.def.prosperity;
    }
    return WorldBars(
      nature: nature.clamp(0, 100).toDouble(),
      tech: tech.clamp(0, 100).toDouble(),
      prosperity: prosperity.clamp(0, 100).toDouble(),
    );
  }

  /* ================= 图鉴 ================= */

  bool discover(String id) {
    if (!elementById.containsKey(id) || discovered.contains(id)) return false;
    discovered.add(id);
    records.insert(0, RecordEntry(id, DateTime.now().millisecondsSinceEpoch));
    if (records.length > 300) records.removeLast();
    _discoveryRev++;
    lastDiscoveryAtMs = _wallMs;
    _checkGoals();
    return true;
  }

  /* ================= 世界目标 ================= */

  int goalProgress(Goal g) {
    if (g.kind == 'type') {
      var n = 0;
      for (final id in discovered) {
        final e = elementById[id];
        if (e != null && e.type == g.typeName) n++;
      }
      return n;
    }
    if (g.kind == 'element') return discovered.contains(g.elementId) ? 1 : 0;
    if (g.kind == 'merge') return mergeCount;
    if (g.kind == 'score') return score;
    return 0;
  }

  String goalLabel(Goal g) {
    switch (g.kind) {
      case 'type':
        return '发现 ${g.target} 种${g.typeName}';
      case 'element':
        final e = elementById[g.elementId!];
        return e != null ? '发现 ${e.emoji} ${e.name}' : '发现 ${g.elementId}';
      case 'merge':
        return '完成 ${g.target} 次合成';
      case 'score':
        return '累计获得 ${g.target} 炼金点';
      default:
        return '';
    }
  }

  String goalIcon(Goal g) {
    if (g.kind == 'type') return kGoalTypeIcons[g.typeName] ?? '🧩';
    if (g.kind == 'element') return elementById[g.elementId]?.emoji ?? '🎯';
    return kGoalKindIcons[g.kind] ?? '🎯';
  }

  /// 检查目标进度；完成后发奖励并立即换一个新目标（一次只完成一个）
  void _checkGoals() {
    if (goals.isEmpty) return;
    for (var i = 0; i < goals.length; i++) {
      final g = goals[i];
      if (goalProgress(g) < g.target) continue;
      score += g.reward;
      SoundService.discover();
      showToast('🎯 目标完成：${goalLabel(g)} +${g.reward} 炼金点');
      final exclude = goals.map((x) => x.key).toList();
      goals[i] = _makeGoals(discovered, exclude, 1).first;
      _goalRev++;
      save();
      break;
    }
  }

  List<Goal> _makeGoals(Set<String> known, List<String> exclude, int count) {
    final pool = _shuffle(kGoalTemplates, _rnd)
        .where((t) => _goalFeasible(t, known) && !exclude.contains(t.key))
        .toList();
    final out = <Goal>[];
    for (final t in pool) {
      out.add(t);
      if (out.length >= count) break;
    }
    // 兜底：模板不足时生成合成目标，保证永远有 3 个目标
    var i = 0;
    while (out.length < count) {
      out.add(Goal(kind: 'merge', target: 5 + i * 3, reward: 50 + i * 20));
      i++;
    }
    return out;
  }

  bool _goalFeasible(Goal t, Set<String> known) {
    if (t.kind == 'element') return !known.contains(t.elementId);
    if (t.kind == 'type') {
      var n = 0;
      for (final e in kElements) {
        if (e.type == t.typeName && !known.contains(e.id)) n++;
      }
      return n >= t.target;
    }
    return true; // merge / score 永远可行
  }

  /* ================= 潜力 / 卡住提示 ================= */

  /// 该元素还能参与合成多少种未发现元素（材料栏 🔗N 徽标）
  int unknownChildren(String id) => kElements
      .where(
        (e) =>
            !discovered.contains(e.id) &&
            e.recipes.any((r) => r[0] == id || r[1] == id),
      )
      .length;

  /// 连续失败 >=3 次，或 90 秒没有新发现；且 45 秒冷却已过
  bool get hintReady {
    final stuck = failStreak >= 3 || (_wallMs - lastDiscoveryAtMs) > 90000;
    final cooldown = (_wallMs - lastHintAtMs) > 45000;
    return stuck && cooldown;
  }

  /// 点击提示：返回一条“材料都已发现”的线索 [a, b]；未就绪返回 null
  (String, String)? useHint() {
    if (!hintReady) return null;
    _depthCache ??= _computeDepth();
    final pair = _pickHintPair(discovered, _depthCache!);
    if (pair == null) {
      showToast('暂时没有可提示的配方，继续探索吧');
      return null;
    }
    final a = elementById[pair.$1]!;
    final b = elementById[pair.$2]!;
    showToast('💡 线索：${a.emoji} ${a.name} 与 ${b.emoji} ${b.name} 之间似乎藏着秘密…');
    failStreak = 0;
    lastHintAtMs = _wallMs;
    SoundService.place();
    return pair;
  }

  /// 每个元素从初始元素出发的最小配方深度（有环也收敛）
  Map<String, int> _computeDepth() {
    final depth = <String, int>{for (final id in kStarterIds) id: 0};
    var changed = true;
    while (changed) {
      changed = false;
      for (final e in kElements) {
        if (depth.containsKey(e.id)) continue;
        var best = 1 << 30;
        for (final r in e.recipes) {
          final da = depth[r[0]];
          final db = depth[r[1]];
          if (da != null && db != null) best = min(best, max(da, db) + 1);
        }
        if (best < (depth[e.id] ?? 1 << 30)) {
          depth[e.id] = best;
          changed = true;
        }
      }
    }
    return depth;
  }

  (String, String)? _pickHintPair(Set<String> known, Map<String, int> depth) {
    final candidates = <(String, String)>[];
    final shallow = <(String, String)>[];
    for (final e in kElements) {
      if (known.contains(e.id) || e.type == '灾害') continue;
      for (final r in e.recipes) {
        if (known.contains(r[0]) && known.contains(r[1])) {
          candidates.add((r[0], r[1]));
          if ((depth[e.id] ?? 99) <= 4) shallow.add((r[0], r[1]));
          break; // 每个元素只给一条候选
        }
      }
    }
    final pool = shallow.isNotEmpty ? shallow : candidates;
    if (pool.isEmpty) return null;
    return pool[_rnd.nextInt(pool.length)];
  }

  /* ================= 操作 ================= */

  bool placeElement(String id, int row, int col) {
    if (!discovered.contains(id)) return false;
    if (!isEmpty(row, col)) return false;
    grid[row][col] = Block(id, row, col, _time);
    SoundService.place();
    save();
    notifyListeners();
    return true;
  }

  void moveBlock(Block block, int row, int col) {
    if (!inBounds(row, col) || grid[row][col] != null) return;
    grid[block.row][block.col] = null;
    grid[row][col] = block;
    block.row = row;
    block.col = col;
    SoundService.place();
    save();
    notifyListeners();
  }

  void performMerge(Block a, Block b) {
    final rid = findRecipe(a.elementId, b.elementId);
    if (rid == null) {
      rejectMerge(a, b);
      return;
    }
    final c1 = centerNorm(a.row, a.col);
    final c2 = centerNorm(b.row, b.col);
    grid[a.row][a.col] = null;
    grid[b.row][b.col] = null;
    a.removed = true;
    b.removed = true;
    mergeAnims.add(
      MergeAnim(
        r1: a.row,
        c1: a.col,
        r2: b.row,
        c2: b.col,
        rid: rid,
        row: b.row,
        col: b.col,
      ),
    );
    final def = elementById[rid]!;
    final mid = Offset((c1.dx + c2.dx) / 2, (c1.dy + c2.dy) / 2);
    burst(mid.dx, mid.dy, kRarityColors[def.rarity], 22, 0.1786);
    floatText(
      mid.dx,
      mid.dy - 0.06,
      '+${def.value}',
      kRarityColors[def.rarity],
    );
    SoundService.merge();
    if (selected == a || selected == b) clearSelection();
    notifyListeners();
  }

  void finishMerge(MergeAnim anim) {
    final result = Block(anim.rid, anim.row, anim.col, _time);
    grid[anim.row][anim.col] = result;
    final def = elementById[anim.rid]!;
    final isNew = discover(anim.rid);
    score += def.value;
    mergeCount++;
    failStreak = 0;
    if (isNew) {
      SoundService.discover();
      final c = centerNorm(anim.row, anim.col);
      burst(c.dx, c.dy, kRarityColors[def.rarity], 30, 0.232);
      final unknown = unknownChildren(anim.rid);
      showToast(
        unknown > 0
            ? '✨ 新发现：${def.emoji} ${def.name}！它还能合成 $unknown 种未知元素'
            : '✨ 新发现：${def.emoji} ${def.name}！',
      );
    }
    _checkGoals();
    _updateWorld();
    save();
    notifyListeners();
  }

  void rejectMerge(Block a, Block b) {
    final ea = a.def;
    final eb = b.def;
    SoundService.deny();
    showToast('${ea.emoji} ${ea.name} + ${eb.emoji} ${eb.name} 无法合成');
    flashCell(a.row, a.col, const Color(0x8CFF5A5A));
    flashCell(b.row, b.col, const Color(0x8CFF5A5A));
    failStreak++;
    notifyListeners();
  }

  /* ================= 选中 / 删除 ================= */

  void selectBlock(Block block) {
    selected = block;
    _selectRev++;
    notifyListeners();
  }

  void clearSelection() {
    selected = null;
    notifyListeners();
  }

  void deleteSelected() {
    final b = selected;
    if (b == null) return;
    final c = centerNorm(b.row, b.col);
    grid[b.row][b.col] = null;
    burst(c.dx, c.dy, const Color(0xFFFF8A8A), 14, 0.125);
    SoundService.remove();
    final name = b.def.name;
    clearSelection();
    save();
    showToast('已删除 $name');
  }

  /* ================= 拖拽 ================= */

  void startMapDrag(int row, int col, Offset local) {
    final b = get(row, col);
    if (b == null) return;
    drag = DragState.map(block: b, fromRow: row, fromCol: col)
      ..start = local
      ..position = local;
    notifyListeners();
  }

  void startTrayDrag(String id, Offset local) {
    drag = DragState.tray(elementId: id)
      ..start = local
      ..position = local;
    notifyListeners();
  }

  /// 轻点材料栏：自动放到第一个空格
  void tapTrayChip(String id) {
    final cell = randomEmptyCell();
    if (cell != null) {
      placeElement(id, cell.$1, cell.$2);
    } else {
      showToast('地图已满，先合成或删除一些方块吧');
    }
  }

  void updateDrag(Offset local) {
    final d = drag;
    if (d == null) return;
    d.position = local;
    if (!d.active && (local - d.start).distance > 8) d.active = true;
    hover = cellAt(local);
    notifyListeners();
  }

  void endMapDrag(Offset local) {
    final d = drag;
    drag = null;
    hover = null;
    if (d == null || d.kind != 'map') return;
    final block = d.block!;
    if (!d.active) {
      selectBlock(block);
      return;
    }
    final cell = cellAt(local);
    if (cell == null) return;
    if (cell.$1 == d.fromRow && cell.$2 == d.fromCol) {
      selectBlock(block);
      return;
    }
    final target = get(cell.$1, cell.$2);
    if (target != null) {
      performMerge(block, target);
    } else {
      moveBlock(block, cell.$1, cell.$2);
    }
  }

  void endTrayDrag(Offset local) {
    final d = drag;
    drag = null;
    hover = null;
    if (d == null || d.kind != 'tray') return;
    // 长按后未拖动就松手：视为取消，不放方块
    if (!d.active) {
      notifyListeners();
      return;
    }
    final cell = cellAt(local);
    if (cell != null && isEmpty(cell.$1, cell.$2)) {
      placeElement(d.elementId!, cell.$1, cell.$2);
    }
    notifyListeners();
  }

  void cancelDrag() {
    drag = null;
    hover = null;
    notifyListeners();
  }

  /* ================= 灾害事件 ================= */

  bool updateEvents() {
    if (_wallMs < nextEventAtMs) return false;
    nextEventAtMs = _wallMs + (50 + _rnd.nextDouble() * 40) * 1000;
    if (discovered.length < 15) return false;
    if (countEmpty() < 2) return false;
    if (_rnd.nextDouble() > 0.55) return false;
    spawnDisaster();
    return true;
  }

  void spawnDisaster() {
    final cell = randomEmptyCell();
    if (cell == null) return;
    final id = kDisasterIds[_rnd.nextInt(kDisasterIds.length)];
    final block = Block(id, cell.$1, cell.$2, _time);
    block.expiresAt = _wallMs + 75000; // 灾害存活 75 秒（现实时间）
    grid[cell.$1][cell.$2] = block;
    final def = elementById[id]!;
    final isNew = discover(id);
    SoundService.event();
    showToast('⚠️ 灾害降临：${def.emoji} ${def.name}${isNew ? '（已记入图鉴）' : ''}');
    save();
    notifyListeners();
  }

  bool updateDisasters() {
    var changed = false;
    for (var r = 0; r < boardSize; r++) {
      for (var c = 0; c < boardSize; c++) {
        final b = grid[r][c];
        if (b != null && b.expiresAt != null && _wallMs > b.expiresAt!) {
          grid[r][c] = null;
          final n = centerNorm(r, c);
          burst(n.dx, n.dy, const Color(0xFF8FA3C8), 12, 0.107);
          if (selected == b) clearSelection();
          changed = true;
        }
      }
    }
    return changed;
  }

  /* ================= 主循环 ================= */

  void tick(double dt) {
    _time += dt;
    var changed = false;

    if (particles.isNotEmpty) {
      for (final p in particles) {
        p.x += p.vx * dt;
        p.y += p.vy * dt;
        p.vy += 60 * dt / 560; // 轻微重力（归一化空间）
        p.life -= dt;
      }
      particles.removeWhere((p) => p.life <= 0);
      changed = true;
    }

    if (mergeAnims.isNotEmpty) {
      for (var i = mergeAnims.length - 1; i >= 0; i--) {
        final a = mergeAnims[i];
        a.t += dt;
        if (a.t >= a.dur) {
          mergeAnims.removeAt(i);
          finishMerge(a);
        }
      }
      changed = true;
    }

    if (floatTexts.isNotEmpty) {
      for (final f in floatTexts) {
        f.t += dt;
      }
      floatTexts.removeWhere((f) => f.t >= f.dur);
      changed = true;
    }

    if (cellFlashes.isNotEmpty) {
      for (final f in cellFlashes) {
        f.t += dt;
      }
      cellFlashes.removeWhere((f) => f.t >= f.dur);
      changed = true;
    }

    // 需要持续重绘的情况：
    // 1) 新方块弹出动画期间（否则会停留在初始小尺寸）
    // 2) 棋盘上存在灾害方块（脉动红圈动画需要每帧刷新）
    for (final b in allBlocks()) {
      if (_time - b.createdAt < 0.3 || b.def.type == '灾害') {
        changed = true;
        break;
      }
    }

    if (toast != null && _wallMs >= _toastUntilMs) {
      toast = null;
      changed = true;
    }

    // 每秒检查一次提示按钮是否变为可用（长时间无发现时）
    _hintCheck += dt;
    if (_hintCheck >= 1) {
      _hintCheck = 0;
      if (_lastHintReady != hintReady) {
        _lastHintReady = hintReady;
        changed = true;
      }
    }

    if (updateEvents()) changed = true;
    if (updateDisasters()) changed = true;
    if (changed) notifyListeners();
  }

  /* ================= 特效 ================= */

  // 默认速度与网页版一致（110px/s ÷ 560px 画布 ≈ 0.196）
  void burst(
    double nx,
    double ny,
    Color color,
    int count, [
    double speed = 0.196,
  ]) {
    for (var i = 0; i < count; i++) {
      final angle = _rnd.nextDouble() * pi * 2;
      final v = speed * (0.35 + _rnd.nextDouble() * 0.75);
      particles.add(
        Particle(
          x: nx,
          y: ny,
          vx: cos(angle) * v,
          vy: sin(angle) * v,
          color: color,
        ),
      );
    }
  }

  void floatText(double nx, double ny, String text, Color color) {
    floatTexts.add(FloatText(x: nx, y: ny, text: text, color: color));
  }

  void flashCell(int row, int col, Color color) {
    cellFlashes.add(CellFlash(row: row, col: col, color: color));
  }

  void showToast(String msg) {
    toast = msg;
    _toastUntilMs = _wallMs + 2600;
    notifyListeners();
  }

  void toggleMute() {
    muted = !muted;
    SoundService.enabled = !muted;
    _storage.setMuted(muted);
    notifyListeners();
  }
}
