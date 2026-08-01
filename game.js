/* ============================================================================
 * 方块炼金师 (Block Alchemist)
 * ----------------------------------------------------------------------------
 * 原创合成探索游戏：Little Alchemy 式元素配方 + 模拟经营成长。
 * 规则明确：没有数字合并、没有滑动棋盘，只有「拖拽元素 -> 配方合成」。
 *
 * 类结构
 *   Block           地图上的方块实例
 *   Board           地图网格（6×6 起，随世界等级扩大到 8×8）
 *   Encyclopedia    图鉴 / 解锁记录
 *   SaveManager     本地存档
 *   AudioManager    音效（wav + Web Audio 合成兜底）
 *   ParticleSystem  Canvas 粒子
 *   Game            游戏主控（Canvas 渲染 / 拖拽 / 合成 / 世界成长 / 灾害事件）
 * ========================================================================== */

'use strict';

/* ------------------------------ 工具函数 ------------------------------ */

const clampNum = (v, min, max) => Math.max(min, Math.min(max, v));
const randOf = (arr) => arr[Math.floor(Math.random() * arr.length)];

function escapeHtml(str) {
  return String(str).replace(/[&<>"']/g, (ch) => (
    { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[ch]
  ));
}

function easeOutBack(t) {
  const c1 = 1.70158;
  const c3 = c1 + 1;
  return 1 + c3 * Math.pow(t - 1, 3) + c1 * Math.pow(t - 1, 2);
}

function roundRectPath(ctx, x, y, w, h, r) {
  ctx.beginPath();
  ctx.moveTo(x + r, y);
  ctx.arcTo(x + w, y, x + w, y + h, r);
  ctx.arcTo(x + w, y + h, x, y + h, r);
  ctx.arcTo(x, y + h, x, y, r);
  ctx.arcTo(x, y, x + w, y, r);
  ctx.closePath();
}

/* ------------------------------ 常量 ------------------------------ */

const SAVE_KEY = 'alchemist_save_v1';
const MUTE_KEY = 'alchemist_muted';
const DISASTER_LIFETIME = 75000; // 灾害方块在地图上的存活时间

/** 世界等级：探索数量门槛 + 地图尺寸（世界成长） */
const WORLD_LEVELS = [
  { min: 0,   name: '原始荒原', size: 6 },
  { min: 10,  name: '生机萌芽', size: 6 },
  { min: 25,  name: '部落聚落', size: 7 },
  { min: 45,  name: '繁荣村镇', size: 7 },
  { min: 70,  name: '工业城市', size: 8 },
  { min: 95,  name: '科技王国', size: 8 },
  { min: 120, name: '星际文明', size: 8 },
  { min: 150, name: '炼金之神', size: 8 },
];

const SOUND_FILES = ['click', 'merge', 'level', 'item', 'achievement', 'gameover'];
const SOUND_PATTERNS = {
  click:       [[880, 0, 0.07, 440]],
  merge:       [[660, 0, 0.09, null], [990, 0.08, 0.13, null]],
  level:       [[523, 0, 0.10, null], [659, 0.10, 0.10, null], [784, 0.20, 0.10, null], [1047, 0.30, 0.28, null]],
  item:        [[880, 0, 0.07, null], [1175, 0.07, 0.13, null]],
  achievement: [[523, 0, 0.09, null], [659, 0.09, 0.09, null], [784, 0.18, 0.09, null], [1047, 0.27, 0.30, null]],
  gameover:    [[392, 0, 0.22, 330], [311, 0.24, 0.24, 260], [233, 0.50, 0.50, 150]],
  deny:        [[160, 0, 0.09, null]],
};

/** 本地存储安全包装 */
const storage = {
  get(key, fallback) {
    try {
      const v = window.localStorage.getItem(key);
      return v === null ? fallback : JSON.parse(v);
    } catch (e) {
      return fallback;
    }
  },
  set(key, value) {
    try {
      window.localStorage.setItem(key, JSON.stringify(value));
    } catch (e) { /* 忽略 */ }
  },
  remove(key) {
    try {
      window.localStorage.removeItem(key);
    } catch (e) { /* 忽略 */ }
  },
};

/* ============================ 音效 ============================ */

class AudioManager {
  constructor(enabled = true) {
    this.enabled = enabled;
    this.ctx = null;
    this.cache = {};
    this.preload();
  }

  preload() {
    for (const name of SOUND_FILES) {
      const a = new Audio(`assets/${name}.wav`);
      a.preload = 'auto';
      a.addEventListener('canplaythrough', () => { this.cache[name] = a; }, { once: true });
      a.addEventListener('error', () => {}, { once: true });
    }
  }

  play(name) {
    if (!this.enabled) return;
    const el = this.cache[name];
    if (el && el.readyState >= 2) {
      el.currentTime = 0;
      const p = el.play();
      if (p && p.catch) p.catch(() => this.synth(name));
    } else {
      this.synth(name);
    }
  }

  synth(name) {
    try {
      if (!this.ctx) {
        const AC = window.AudioContext || window.webkitAudioContext;
        if (!AC) return;
        this.ctx = new AC();
      }
      if (this.ctx.state === 'suspended') this.ctx.resume();
      const t0 = this.ctx.currentTime;
      const notes = SOUND_PATTERNS[name] || SOUND_PATTERNS.click;
      for (const [freq, offset, dur, fend] of notes) {
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(freq, t0 + offset);
        if (fend) osc.frequency.exponentialRampToValueAtTime(fend, t0 + offset + dur);
        gain.gain.setValueAtTime(0.0001, t0 + offset);
        gain.gain.exponentialRampToValueAtTime(0.22, t0 + offset + 0.012);
        gain.gain.exponentialRampToValueAtTime(0.0001, t0 + offset + dur);
        osc.connect(gain).connect(this.ctx.destination);
        osc.start(t0 + offset);
        osc.stop(t0 + offset + dur + 0.03);
      }
    } catch (e) { /* 音频失败不影响游戏 */ }
  }

  toggle() {
    this.enabled = !this.enabled;
    storage.set(MUTE_KEY, !this.enabled);
    return this.enabled;
  }
}

/* ============================ 存档 ============================ */

class SaveManager {
  load() {
    try {
      const raw = window.localStorage.getItem(SAVE_KEY);
      if (!raw) return null;
      const d = JSON.parse(raw);
      if (!d || d.v !== 1) return null;
      return d;
    } catch (e) {
      return null;
    }
  }

  save(data) {
    try {
      window.localStorage.setItem(SAVE_KEY, JSON.stringify({ v: 1, ...data }));
    } catch (e) { /* 忽略 */ }
  }

  clear() {
    storage.remove(SAVE_KEY);
  }
}

/* ============================ 图鉴 ============================ */

class Encyclopedia {
  constructor() {
    this.discovered = new Set(STARTER_IDS);
    this.records = [];
  }

  has(id) {
    return this.discovered.has(id);
  }

  count() {
    return this.discovered.size;
  }

  /** 尝试解锁新元素；返回是否为新发现 */
  add(id) {
    if (!ELEMENTS_BY_ID[id]) return false;
    if (this.discovered.has(id)) return false;
    this.discovered.add(id);
    this.records.unshift({ id, t: Date.now() });
    if (this.records.length > 300) this.records.pop();
    return true;
  }

  toData() {
    return { discovered: Array.from(this.discovered), records: this.records };
  }

  fromData(d) {
    this.discovered = new Set((d.discovered || []).filter((id) => ELEMENTS_BY_ID[id]));
    this.records = (d.records || []).filter((r) => ELEMENTS_BY_ID[r.id]).slice(0, 300);
  }

  clear() {
    this.discovered = new Set(STARTER_IDS);
    this.records = [];
  }
}

/* ============================ 方块与棋盘 ============================ */

let BLOCK_SEQ = 1;

class Block {
  constructor(elementId, row = -1, col = -1) {
    this.id = BLOCK_SEQ++;
    this.elementId = elementId;
    this.row = row;
    this.col = col;
    this.createdAt = performance.now();
    this.removed = false;
    this.expiresAt = 0; // 灾害方块使用
  }
}

class Board {
  constructor(size) {
    this.size = size;
    this.grid = [];
    this.reset();
  }

  reset() {
    this.grid = Array.from({ length: this.size }, () => new Array(this.size).fill(null));
  }

  /** 世界升级时扩大地图，保留旧方块 */
  resize(size) {
    if (size === this.size) return;
    const old = this.grid;
    this.size = size;
    this.reset();
    for (let r = 0; r < old.length; r++) {
      for (let c = 0; c < old[r].length; c++) {
        const b = old[r][c];
        if (b && r < size && c < size) this.grid[r][c] = b;
      }
    }
  }

  inBounds(r, c) {
    return r >= 0 && r < this.size && c >= 0 && c < this.size;
  }

  get(r, c) {
    return this.inBounds(r, c) ? this.grid[r][c] : null;
  }

  isEmpty(r, c) {
    return this.inBounds(r, c) && !this.grid[r][c];
  }

  set(r, c, block) {
    if (!this.inBounds(r, c)) return;
    if (block) {
      block.row = r;
      block.col = c;
    }
    this.grid[r][c] = block;
  }

  move(block, r, c) {
    if (!this.inBounds(r, c) || this.grid[r][c]) return false;
    this.grid[block.row][block.col] = null;
    this.set(r, c, block);
    return true;
  }

  remove(r, c) {
    const b = this.get(r, c);
    if (b) {
      b.removed = true;
      this.grid[r][c] = null;
    }
    return b;
  }

  randomEmptyCell() {
    const cells = [];
    for (let r = 0; r < this.size; r++) {
      for (let c = 0; c < this.size; c++) {
        if (!this.grid[r][c]) cells.push({ row: r, col: c });
      }
    }
    return cells.length ? randOf(cells) : null;
  }

  countEmpty() {
    let n = 0;
    for (let r = 0; r < this.size; r++) {
      for (let c = 0; c < this.size; c++) if (!this.grid[r][c]) n++;
    }
    return n;
  }

  allBlocks() {
    return this.grid.flat().filter(Boolean);
  }
}

/* ============================ 粒子 ============================ */

class ParticleSystem {
  constructor() {
    this.particles = [];
  }

  burst(x, y, color, count = 18, speed = 110) {
    for (let i = 0; i < count; i++) {
      const angle = Math.random() * Math.PI * 2;
      const v = speed * (0.35 + Math.random() * 0.75);
      this.particles.push({
        x, y,
        vx: Math.cos(angle) * v,
        vy: Math.sin(angle) * v,
        life: 0.5 + Math.random() * 0.4,
        max: 0.9,
        size: 3 + Math.random() * 4,
        color,
      });
    }
  }

  update(dt) {
    for (const p of this.particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += 60 * dt; // 轻微重力
      p.life -= dt;
    }
    this.particles = this.particles.filter((p) => p.life > 0);
  }

  draw(ctx) {
    for (const p of this.particles) {
      ctx.globalAlpha = clampNum(p.life / p.max, 0, 1);
      ctx.fillStyle = p.color;
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
      ctx.fill();
    }
    ctx.globalAlpha = 1;
  }
}

/* ============================ 游戏主控 ============================ */

class Game {
  constructor() {
    /* ----- DOM ----- */
    this.canvas = document.getElementById('map-canvas');
    this.ctx = this.canvas.getContext('2d');
    this.trayEl = document.getElementById('tray');
    this.traySearch = document.getElementById('tray-search');
    this.trayType = document.getElementById('tray-type');
    this.scoreEl = document.getElementById('stat-score');
    this.discoveredEl = document.getElementById('stat-discovered');
    this.worldEl = document.getElementById('stat-world');
    this.barNature = document.getElementById('bar-nature');
    this.barTech = document.getElementById('bar-tech');
    this.barProsperity = document.getElementById('bar-prosperity');
    this.toastEl = document.getElementById('toast');
    this.muteBtn = document.getElementById('btn-mute');

    /* ----- 核心对象 ----- */
    this.audio = new AudioManager(!storage.get(MUTE_KEY, false));
    this.saveMgr = new SaveManager();
    this.encyclopedia = new Encyclopedia();
    this.particles = new ParticleSystem();
    this.board = new Board(6);

    /* ----- 运行状态 ----- */
    this.score = 0;
    this.selected = null;
    this.dragState = null;
    this.tapStart = null;
    this.hoverCell = null;
    this.mergeAnims = [];
    this.floatTexts = [];
    this.cellFlashes = [];
    this.eventTimer = 45;
    this.worldIndex = -1;
    this.last = performance.now();
    this.toastTimer = null;

    /* ----- 存档或新开局 ----- */
    const save = this.saveMgr.load();
    if (save) this.applySave(save);
    else this.seedBoard();

    this.winMove = (e) => this.onWindowMove(e);
    this.winUp = (e) => this.onWindowUp(e);

    this.resizeCanvas();
    this.buildTrayOptions();
    this.bindEvents();
    this.renderTray();
    this.updateWorld(false);
    this.updateHud();
    this.startLoop();

    this.showToast('🧪 欢迎来到方块炼金师！把 🔥 火拖到 💧 水上试试吧');
  }

  /* ================= 存档 ================= */

  applySave(d) {
    this.score = Number(d.score) || 0;
    this.encyclopedia.fromData({ discovered: d.discovered, records: d.records });
    const size = clampNum(parseInt(d.size, 10) || 6, 6, 8);
    this.board = new Board(size);
    if (Array.isArray(d.grid)) {
      for (let i = 0; i < d.grid.length; i++) {
        const id = d.grid[i];
        if (!id || !ELEMENTS_BY_ID[id]) continue;
        const r = Math.floor(i / size);
        const c = i % size;
        if (this.board.inBounds(r, c)) this.board.set(r, c, new Block(id, r, c));
      }
    }
  }

  /** 新开局：地图上先放火与水 */
  seedBoard() {
    const a = this.board.randomEmptyCell();
    if (a) this.board.set(a.row, a.col, new Block('fire', a.row, a.col));
    const b = this.board.randomEmptyCell();
    if (b) this.board.set(b.row, b.col, new Block('water', b.row, b.col));
  }

  autoSave() {
    const size = this.board.size;
    const grid = [];
    for (let r = 0; r < size; r++) {
      for (let c = 0; c < size; c++) {
        const b = this.board.get(r, c);
        grid.push(b ? b.elementId : null);
      }
    }
    this.saveMgr.save({
      score: this.score,
      discovered: this.encyclopedia.toData().discovered,
      records: this.encyclopedia.toData().records,
      grid,
      size,
    });
  }

  resetGame() {
    if (!confirm('确定要清空所有存档吗？图鉴、记录和地图都会重置。')) return;
    this.saveMgr.clear();
    this.encyclopedia.clear();
    this.board = new Board(6);
    this.score = 0;
    this.clearSelection();
    this.seedBoard();
    this.updateWorld(false);
    this.updateHud();
    this.renderTray();
    this.showToast('🗑 已重置存档，重新开始探索吧');
  }

  /* ================= 世界成长 ================= */

  getWorldIndex() {
    const n = this.encyclopedia.count();
    let idx = 0;
    for (let i = 0; i < WORLD_LEVELS.length; i++) {
      if (n >= WORLD_LEVELS[i].min) idx = i;
    }
    return idx;
  }

  updateWorld(notify = true) {
    const idx = this.getWorldIndex();
    const lv = WORLD_LEVELS[idx];
    if (idx > this.worldIndex && notify && this.worldIndex >= 0) {
      this.audio.play('level');
      this.showToast(`🌍 世界成长：${lv.name}！地图扩大为 ${lv.size}×${lv.size}`);
    }
    this.worldIndex = idx;
    if (this.board.size < lv.size) this.board.resize(lv.size);
    this.updateHud();
  }

  calcWorldBars() {
    let nature = 0;
    let tech = 0;
    let prosperity = 0;
    for (const b of this.board.allBlocks()) {
      const a = ELEMENTS_BY_ID[b.elementId].attrs;
      nature += a.nature;
      tech += a.tech;
      prosperity += a.prosperity;
    }
    return {
      nature: clampNum(nature, 0, 100),
      tech: clampNum(tech, 0, 100),
      prosperity: clampNum(prosperity, 0, 100),
    };
  }

  updateHud() {
    const lv = WORLD_LEVELS[this.worldIndex] || WORLD_LEVELS[0];
    this.scoreEl.textContent = this.score.toLocaleString();
    this.discoveredEl.textContent = `${this.encyclopedia.count()}/${ELEMENTS.length}`;
    this.worldEl.textContent = `Lv${this.worldIndex + 1} ${lv.name}`;
    const bars = this.calcWorldBars();
    this.barNature.style.width = bars.nature + '%';
    this.barTech.style.width = bars.tech + '%';
    this.barProsperity.style.width = bars.prosperity + '%';
  }

  /* ================= 画布尺寸与坐标 ================= */

  resizeCanvas() {
    const w = this.canvas.clientWidth || 560;
    const dpr = (window.devicePixelRatio || 1);
    this.canvas.width = Math.round(w * dpr);
    this.canvas.height = Math.round(w * dpr);
    this.ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  }

  cellSize() {
    return (this.canvas.clientWidth || this.canvas.width) / this.board.size;
  }

  pointToCell(e) {
    const rect = this.canvas.getBoundingClientRect();
    const cell = this.cellSize();
    return {
      row: Math.floor((e.clientY - rect.top) / cell),
      col: Math.floor((e.clientX - rect.left) / cell),
    };
  }

  cellCenter(row, col) {
    const cell = this.cellSize();
    return { x: col * cell + cell / 2, y: row * cell + cell / 2 };
  }

  /* ================= 事件绑定 ================= */

  bindEvents() {
    this.canvas.addEventListener('pointerdown', (e) => this.onCanvasDown(e));
    this.canvas.addEventListener('pointermove', (e) => this.onCanvasMove(e));
    this.canvas.addEventListener('pointerup', (e) => this.onCanvasUp(e));
    this.canvas.addEventListener('pointercancel', () => this.onCanvasCancel());

    this.traySearch.addEventListener('input', () => this.renderTray());
    this.trayType.addEventListener('change', () => this.renderTray());

    document.getElementById('btn-codex').addEventListener('click', () => this.openCodex('codex'));
    document.getElementById('btn-records').addEventListener('click', () => this.openCodex('records'));
    document.getElementById('btn-reset').addEventListener('click', () => this.resetGame());
    document.getElementById('btn-delete').addEventListener('click', () => this.deleteSelected());
    document.getElementById('btn-mute').addEventListener('click', () => this.toggleMute());
    document.getElementById('btn-help').addEventListener('click', () => this.openModal('modal-help'));
    document.getElementById('tab-codex').addEventListener('click', () => this.switchCodexTab('codex'));
    document.getElementById('tab-records').addEventListener('click', () => this.switchCodexTab('records'));
    document.getElementById('codex-search').addEventListener('input', () => this.renderCodex());
    document.getElementById('codex-type').addEventListener('change', () => this.renderCodex());

    document.querySelectorAll('.modal-close').forEach((btn) => {
      btn.addEventListener('click', () => this.closeModal(btn.dataset.close));
    });
    window.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') this.closeAllModals();
    });
    window.addEventListener('resize', () => this.resizeCanvas());
  }

  buildTrayOptions() {
    const sel = this.trayType;
    sel.innerHTML = `<option value="all">全部类型</option>` +
      TYPE_LIST.map((t) => `<option value="${t}">${t}</option>`).join('');
    sel.value = 'all';
    const codexSel = document.getElementById('codex-type');
    codexSel.innerHTML = sel.innerHTML;
    codexSel.value = 'all';
  }

  /* ================= 地图拖拽 ================= */

  onCanvasDown(e) {
    if (this.isModalOpen() || this.dragState) return;
    const cell = this.pointToCell(e);
    if (!this.board.inBounds(cell.row, cell.col)) return;
    const b = this.board.get(cell.row, cell.col);
    if (b) {
      this.dragState = {
        kind: 'map',
        block: b,
        fromRow: b.row,
        fromCol: b.col,
        x: e.clientX,
        y: e.clientY,
        active: false,
      };
      this.canvas.setPointerCapture(e.pointerId);
      this.canvas.classList.add('dragging');
    } else {
      this.tapStart = { x: e.clientX, y: e.clientY, cell };
    }
  }

  onCanvasMove(e) {
    if (this.dragState && this.dragState.kind === 'map') {
      if (!this.dragState.active &&
          Math.hypot(e.clientX - this.dragState.x, e.clientY - this.dragState.y) > 6) {
        this.dragState.active = true;
      }
      this.dragState.x = e.clientX;
      this.dragState.y = e.clientY;
      this.hoverCell = this.pointToCell(e);
    } else if (!this.dragState) {
      this.hoverCell = this.pointToCell(e);
    }
  }

  onCanvasUp(e) {
    if (this.dragState && this.dragState.kind === 'map') {
      this.finishMapDrag(e);
    } else if (this.tapStart) {
      this.tapStart = null;
    }
  }

  onCanvasCancel() {
    if (this.dragState && this.dragState.kind === 'map') {
      this.dragState = null;
      this.canvas.classList.remove('dragging');
    }
    this.tapStart = null;
    this.hoverCell = null;
  }

  finishMapDrag(e) {
    const ds = this.dragState;
    this.dragState = null;
    this.canvas.classList.remove('dragging');
    this.hoverCell = null;
    if (!ds || ds.kind !== 'map') return;

    const cell = this.pointToCell(e);
    if (!this.board.inBounds(cell.row, cell.col)) return; // 拖出地图外 = 取消
    if (!ds.active || (cell.row === ds.fromRow && cell.col === ds.fromCol)) {
      this.selectBlock(ds.block);
      return;
    }

    const target = this.board.get(cell.row, cell.col);
    if (target) {
      const rid = findRecipe(ds.block.elementId, target.elementId);
      if (rid) this.performMerge(ds.block, target);
      else this.rejectMerge(ds.block, target);
    } else {
      this.board.move(ds.block, cell.row, cell.col);
      this.audio.play('click');
      this.updateHud();
      this.autoSave();
    }
  }

  /* ================= 材料栏拖拽 ================= */

  renderTray() {
    const q = this.traySearch.value.trim().toLowerCase();
    const tf = this.trayType.value;
    const list = ELEMENTS.filter((e) =>
      this.encyclopedia.has(e.id) &&
      (tf === 'all' || e.type === tf) &&
      (!q || e.name.toLowerCase().includes(q))
    );
    if (!list.length) {
      this.trayEl.innerHTML = '<div class="tray-empty">没有符合条件的元素</div>';
      return;
    }
    this.trayEl.innerHTML = list.map((e) =>
      `<div class="chip rar-${e.rarity}" data-id="${e.id}">` +
      `<span class="chip-emoji">${e.emoji}</span><span>${e.name}</span></div>`
    ).join('');
    this.trayEl.querySelectorAll('.chip').forEach((chip) => {
      chip.addEventListener('pointerdown', (e) => {
        e.preventDefault();
        this.startTrayDrag(chip.dataset.id, e);
      });
    });
  }

  startTrayDrag(elementId, e) {
    if (this.isModalOpen()) return;
    this.dragState = { kind: 'tray', elementId, x: e.clientX, y: e.clientY, active: false };
    window.addEventListener('pointermove', this.winMove);
    window.addEventListener('pointerup', this.winUp);
  }

  onWindowMove(e) {
    if (!this.dragState) return;
    if (!this.dragState.active &&
        Math.hypot(e.clientX - this.dragState.x, e.clientY - this.dragState.y) > 6) {
      this.dragState.active = true;
    }
    this.dragState.x = e.clientX;
    this.dragState.y = e.clientY;
  }

  onWindowUp(e) {
    window.removeEventListener('pointermove', this.winMove);
    window.removeEventListener('pointerup', this.winUp);
    const ds = this.dragState;
    this.dragState = null;
    if (!ds || ds.kind !== 'tray') return;

    if (!ds.active) {
      // 轻点材料 -> 自动放到第一个空格
      const cell = this.board.randomEmptyCell();
      if (cell) this.placeElement(ds.elementId, cell.row, cell.col);
      else this.showToast('地图已满，先合成或删除一些方块吧');
      return;
    }
    const cell = this.pointToCell(e);
    if (this.board.inBounds(cell.row, cell.col) && this.board.isEmpty(cell.row, cell.col)) {
      this.placeElement(ds.elementId, cell.row, cell.col);
    }
  }

  placeElement(elementId, row, col) {
    if (!this.encyclopedia.has(elementId)) return false;
    if (!this.board.inBounds(row, col) || !this.board.isEmpty(row, col)) return false;
    const b = new Block(elementId, row, col);
    this.board.set(row, col, b);
    this.audio.play('click');
    this.updateHud();
    this.autoSave();
    return true;
  }

  /* ================= 合成 ================= */

  performMerge(a, b) {
    const rid = findRecipe(a.elementId, b.elementId);
    if (!rid) {
      this.rejectMerge(a, b);
      return;
    }
    const cell = this.cellSize();
    const ax = a.col * cell + cell / 2;
    const ay = a.row * cell + cell / 2;
    const bx = b.col * cell + cell / 2;
    const by = b.row * cell + cell / 2;
    const targetRow = b.row;
    const targetCol = b.col;
    this.board.remove(a.row, a.col);
    this.board.remove(b.row, b.col);

    const resultEl = ELEMENTS_BY_ID[rid];
    this.mergeAnims.push({ ax, ay, bx, by, rid, row: targetRow, col: targetCol, t: 0, dur: 0.42 });
    const mx = (ax + bx) / 2;
    const my = (ay + by) / 2;
    this.particles.burst(mx, my, RARITY_INFO[resultEl.rarity].color, 22, 100);
    this.floatText(mx, my - 16, `+${resultEl.attrs.value}`, RARITY_INFO[resultEl.rarity].color);
    this.audio.play('merge');
    if (this.selected && (this.selected === a || this.selected === b)) this.clearSelection();
  }

  /** 合成动画结束后落地结果 */
  finishMerge(anim) {
    const result = new Block(anim.rid, anim.row, anim.col);
    this.board.set(anim.row, anim.col, result);
    const el = ELEMENTS_BY_ID[anim.rid];
    const isNew = this.encyclopedia.add(anim.rid);
    this.score += el.attrs.value;
    if (isNew) {
      this.audio.play('achievement');
      this.showToast(`✨ 新发现：${el.emoji} ${el.name}！`);
      const c = this.cellCenter(anim.row, anim.col);
      this.particles.burst(c.x, c.y, RARITY_INFO[el.rarity].color, 30, 130);
    }
    this.updateWorld();
    this.updateHud();
    this.renderTray();
    this.autoSave();
  }

  rejectMerge(a, b) {
    const ea = ELEMENTS_BY_ID[a.elementId];
    const eb = ELEMENTS_BY_ID[b.elementId];
    this.audio.play('deny');
    this.showToast(`${ea.emoji} ${ea.name} + ${eb.emoji} ${eb.name} 无法合成`);
    this.flashCell(a.row, a.col, 'rgba(255,90,90,0.55)');
    this.flashCell(b.row, b.col, 'rgba(255,90,90,0.55)');
  }

  /* ================= 选中与删除 ================= */

  selectBlock(block) {
    this.selected = block;
    this.renderSelPanel();
  }

  clearSelection() {
    this.selected = null;
    this.renderSelPanel();
  }

  renderSelPanel() {
    const detail = document.getElementById('sel-detail');
    const empty = document.getElementById('sel-empty');
    if (!this.selected || !ELEMENTS_BY_ID[this.selected.elementId]) {
      empty.classList.remove('hidden');
      detail.classList.add('hidden');
      return;
    }
    empty.classList.add('hidden');
    detail.classList.remove('hidden');
    const e = ELEMENTS_BY_ID[this.selected.elementId];
    const r = RARITY_INFO[e.rarity];
    document.getElementById('sel-emoji').textContent = e.emoji;
    document.getElementById('sel-name').textContent = e.name;
    document.getElementById('sel-tags').textContent = `${r.key} · ${e.type}`;
    document.getElementById('sel-desc').textContent = e.desc;
    document.getElementById('sel-nature').textContent = e.attrs.nature;
    document.getElementById('sel-tech').textContent = e.attrs.tech;
    document.getElementById('sel-prosperity').textContent = e.attrs.prosperity;
    document.getElementById('sel-value').textContent = e.attrs.value;

    const parents = getParents(e.id);
    document.getElementById('sel-parents').innerHTML = parents.length
      ? parents.map((p) =>
          `<span class="sel-chip ${this.encyclopedia.has(p.id) ? '' : 'locked'}">` +
          `${this.encyclopedia.has(p.id) ? `${p.emoji} ${p.name}` : '❓ ???'}</span>`
        ).join('<span class="sel-chip" style="background:transparent;border:none">+</span>')
      : '<span class="sel-chip">✨ 初始元素</span>';

    const children = getChildren(e.id);
    const known = children.filter((c) => this.encyclopedia.has(c.id));
    const unknown = children.length - known.length;
    document.getElementById('sel-children').innerHTML = known.length
      ? known.map((c) => `<span class="sel-chip">${c.emoji} ${c.name}</span>`).join('') +
        (unknown ? `<span class="sel-chip locked">❓ 还有 ${unknown} 种未发现</span>` : '')
      : (children.length ? `<span class="sel-chip locked">❓ 有 ${children.length} 种配方尚未探索</span>` : '<span class="sel-chip">暂无已知配方</span>');
  }

  deleteSelected() {
    const b = this.selected;
    if (!b) return;
    const el = ELEMENTS_BY_ID[b.elementId];
    const c = this.cellCenter(b.row, b.col);
    this.board.remove(b.row, b.col);
    this.particles.burst(c.x, c.y, '#ff8a8a', 14, 70);
    this.audio.play('item');
    this.clearSelection();
    this.updateHud();
    this.autoSave();
    this.showToast(`已删除 ${el.emoji} ${el.name}`);
  }

  /* ================= 灾害事件 ================= */

  updateEvents(dt) {
    this.eventTimer -= dt;
    if (this.eventTimer > 0) return;
    this.eventTimer = 50 + Math.random() * 40;
    if (this.encyclopedia.count() < 15) return;
    if (this.board.countEmpty() < 2) return;
    if (Math.random() > 0.55) return;
    this.spawnDisaster();
  }

  spawnDisaster() {
    const cell = this.board.randomEmptyCell();
    if (!cell) return;
    const id = randOf(DISASTER_IDS);
    const b = new Block(id, cell.row, cell.col);
    b.expiresAt = performance.now() + DISASTER_LIFETIME;
    this.board.set(cell.row, cell.col, b);
    const el = ELEMENTS_BY_ID[id];
    const isNew = this.encyclopedia.add(id);
    this.audio.play('level');
    this.showToast(`⚠️ 灾害降临：${el.emoji} ${el.name}${isNew ? '（已记入图鉴）' : ''}`);
    if (isNew) this.renderTray();
    this.updateHud();
    this.autoSave();
  }

  updateDisasters() {
    const now = performance.now();
    for (const b of this.board.allBlocks()) {
      if (b.expiresAt && now > b.expiresAt) {
        const c = this.cellCenter(b.row, b.col);
        this.board.remove(b.row, b.col);
        this.particles.burst(c.x, c.y, '#8fa3c8', 12, 60);
        if (this.selected === b) this.clearSelection();
      }
    }
  }

  /* ================= 图鉴 ================= */

  openCodex(tab) {
    this.renderCodex();
    this.renderRecords();
    this.switchCodexTab(tab);
    this.openModal('modal-codex');
  }

  switchCodexTab(tab) {
    const codexMode = tab === 'codex';
    document.getElementById('tab-codex').classList.toggle('active', codexMode);
    document.getElementById('tab-records').classList.toggle('active', !codexMode);
    document.getElementById('codex-toolbar').classList.toggle('hidden', !codexMode);
    document.getElementById('codex-grid').classList.toggle('hidden', !codexMode);
    document.getElementById('codex-detail').classList.add('hidden');
    document.getElementById('records-list').classList.toggle('hidden', codexMode);
  }

  renderCodex() {
    const q = document.getElementById('codex-search').value.trim().toLowerCase();
    const tf = document.getElementById('codex-type').value;
    const list = ELEMENTS.filter((e) =>
      (tf === 'all' || e.type === tf) && (!q || e.name.toLowerCase().includes(q))
    );
    const grid = document.getElementById('codex-grid');
    grid.innerHTML = list.map((e) => {
      const has = this.encyclopedia.has(e.id);
      const r = RARITY_INFO[e.rarity];
      return has
        ? `<div class="codex-card" data-id="${e.id}">` +
          `<span class="cx-emoji">${e.emoji}</span><span class="cx-name">${e.name}</span>` +
          `<span class="cx-rarity" style="color:${r.color}">${r.key}</span></div>`
        : `<div class="codex-card locked" data-id="${e.id}">` +
          `<span class="cx-emoji">❓</span><span class="cx-name">???</span>` +
          `<span class="cx-rarity">未发现</span></div>`;
    }).join('');
    grid.querySelectorAll('.codex-card').forEach((card) => {
      card.addEventListener('click', () => {
        if (this.encyclopedia.has(card.dataset.id)) this.renderCodexDetail(card.dataset.id);
      });
    });
  }

  renderCodexDetail(id) {
    const e = ELEMENTS_BY_ID[id];
    if (!e || !this.encyclopedia.has(id)) return;
    const r = RARITY_INFO[e.rarity];
    const parents = getParents(e.id).map((p) =>
      this.encyclopedia.has(p.id) ? `${p.emoji} ${p.name}` : '❓ ???'
    ).join(' + ') || '初始元素';
    const children = getChildren(e.id)
      .filter((c) => this.encyclopedia.has(c.id))
      .map((c) => `${c.emoji} ${c.name}`).join('、') || '暂无';
    const detail = document.getElementById('codex-detail');
    detail.innerHTML =
      `<b style="font-size:17px">${e.emoji} ${e.name}</b> ` +
      `<span style="color:${r.color};font-size:12px;font-weight:700">${r.key} · ${e.type}</span>` +
      `<div style="font-size:12px;color:var(--muted)">${escapeHtml(e.desc)}</div>` +
      `<div style="font-size:13px;margin-top:6px">📜 合成：${parents} → ${e.emoji}</div>` +
      `<div style="font-size:13px">🔬 能合成：${children}</div>`;
    detail.classList.remove('hidden');
  }

  renderRecords() {
    const list = document.getElementById('records-list');
    if (!this.encyclopedia.records.length) {
      list.innerHTML = '<p class="empty">还没有解锁记录，去发现新元素吧！</p>';
      return;
    }
    list.innerHTML = this.encyclopedia.records.map((rec) => {
      const e = ELEMENTS_BY_ID[rec.id];
      const d = new Date(rec.t);
      const ts = `${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')} ` +
        `${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`;
      return `<div class="record-item"><span>✨</span><span>发现 ${e.emoji} ${e.name}</span>` +
        `<span class="rec-time">${ts}</span></div>`;
    }).join('');
  }

  /* ================= 弹窗与提示 ================= */

  openModal(id) {
    const el = document.getElementById(id);
    if (el) el.classList.remove('hidden');
  }

  closeModal(id) {
    const el = document.getElementById(id);
    if (el) el.classList.add('hidden');
  }

  closeAllModals() {
    document.querySelectorAll('.modal').forEach((m) => m.classList.add('hidden'));
  }

  isModalOpen() {
    return !!document.querySelector('.modal:not(.hidden)');
  }

  showToast(text) {
    this.toastEl.textContent = text;
    this.toastEl.classList.remove('show');
    void this.toastEl.offsetWidth;
    this.toastEl.classList.add('show');
    clearTimeout(this.toastTimer);
    this.toastTimer = setTimeout(() => this.toastEl.classList.remove('show'), 2600);
  }

  toggleMute() {
    this.audio.toggle();
    this.muteBtn.textContent = this.audio.enabled ? '🔊' : '🔇';
  }

  /* ================= 特效 ================= */

  floatText(x, y, text, color = '#ffffff') {
    this.floatTexts.push({ x, y, text, color, t: 0, dur: 0.9 });
  }

  flashCell(row, col, color) {
    this.cellFlashes.push({ row, col, color, t: 0, dur: 0.35 });
  }

  updateAnims(dt) {
    for (let i = this.mergeAnims.length - 1; i >= 0; i--) {
      const a = this.mergeAnims[i];
      a.t += dt;
      if (a.t >= a.dur) {
        this.mergeAnims.splice(i, 1);
        this.finishMerge(a);
      }
    }
    for (const ft of this.floatTexts) ft.t += dt;
    this.floatTexts = this.floatTexts.filter((ft) => ft.t < ft.dur);
    for (const f of this.cellFlashes) f.t += dt;
    this.cellFlashes = this.cellFlashes.filter((f) => f.t < f.dur);
  }

  /* ================= 主循环 ================= */

  startLoop() {
    const loop = (now) => {
      requestAnimationFrame(loop);
      const dt = Math.min(0.05, Math.max(0, (now - this.last) / 1000) || 0.016);
      this.last = now;
      this.update(dt);
      this.draw();
    };
    requestAnimationFrame(loop);
  }

  update(dt) {
    this.particles.update(dt);
    this.updateAnims(dt);
    this.updateEvents(dt);
    this.updateDisasters();
  }

  /* ================= 渲染 ================= */

  draw() {
    const ctx = this.ctx;
    const size = this.board.size;
    const W = this.canvas.clientWidth || this.canvas.width;
    const cell = W / size;
    ctx.clearRect(0, 0, W, W);

    // 地图底色与格子
    ctx.fillStyle = '#0d1424';
    ctx.fillRect(0, 0, W, W);
    for (let r = 0; r < size; r++) {
      for (let c = 0; c < size; c++) {
        ctx.fillStyle = (r + c) % 2 ? 'rgba(255,255,255,0.028)' : 'rgba(255,255,255,0.018)';
        ctx.fillRect(c * cell + 2, r * cell + 2, cell - 4, cell - 4);
      }
    }

    // 悬停高亮
    if (this.hoverCell && this.board.inBounds(this.hoverCell.row, this.hoverCell.col)) {
      const { row, col } = this.hoverCell;
      ctx.strokeStyle = 'rgba(110,168,255,0.55)';
      ctx.lineWidth = 2;
      ctx.strokeRect(col * cell + 2, row * cell + 2, cell - 4, cell - 4);
    }

    // 拖拽目标提示
    if (this.dragState && this.dragState.kind === 'map' && this.dragState.active &&
        this.hoverCell && this.board.inBounds(this.hoverCell.row, this.hoverCell.col)) {
      const { row, col } = this.hoverCell;
      const target = this.board.get(row, col);
      let ok = false;
      if (target) ok = !!findRecipe(this.dragState.block.elementId, target.elementId);
      else ok = !(row === this.dragState.fromRow && col === this.dragState.fromCol);
      ctx.strokeStyle = ok ? 'rgba(123,237,159,0.85)' : 'rgba(255,107,107,0.85)';
      ctx.lineWidth = 3;
      ctx.strokeRect(col * cell + 2, row * cell + 2, cell - 4, cell - 4);
    }

    // 方块
    for (const b of this.board.allBlocks()) this.drawBlock(b, cell);

    // 合成动画
    for (const a of this.mergeAnims) this.drawMergeAnim(a, cell);

    // 红闪（无效合成）
    for (const f of this.cellFlashes) {
      ctx.globalAlpha = clampNum(1 - f.t / f.dur, 0, 1);
      ctx.fillStyle = f.color;
      ctx.fillRect(f.col * cell + 2, f.row * cell + 2, cell - 4, cell - 4);
      ctx.globalAlpha = 1;
    }

    // 粒子与飘字
    this.particles.draw(ctx);
    for (const ft of this.floatTexts) {
      const p = ft.t / ft.dur;
      ctx.globalAlpha = 1 - p;
      ctx.fillStyle = ft.color;
      ctx.font = '800 15px system-ui,-apple-system,sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.fillText(ft.text, ft.x, ft.y - 30 * p);
      ctx.globalAlpha = 1;
    }

    // 拖拽幽灵
    if (this.dragState && this.dragState.active) {
      const rect = this.canvas.getBoundingClientRect();
      const x = this.dragState.x - rect.left - cell / 2;
      const y = this.dragState.y - rect.top - cell / 2;
      const e = this.dragState.kind === 'tray'
        ? ELEMENTS_BY_ID[this.dragState.elementId]
        : ELEMENTS_BY_ID[this.dragState.block.elementId];
      if (e) this.drawTile(x, y, cell - 6, e, 0.72);
    }
  }

  drawTile(x, y, s, el, alpha) {
    const ctx = this.ctx;
    const r = RARITY_INFO[el.rarity];
    ctx.save();
    ctx.globalAlpha = alpha;
    ctx.shadowColor = r.color;
    ctx.shadowBlur = el.rarity >= 2 ? 10 : 0;
    const grad = ctx.createLinearGradient(x, y, x, y + s);
    grad.addColorStop(0, r.color);
    grad.addColorStop(1, '#1c2440');
    roundRectPath(ctx, x, y, s, s, 10);
    ctx.fillStyle = grad;
    ctx.fill();
    ctx.shadowBlur = 0;
    const shade = ctx.createLinearGradient(x, y, x, y + s);
    shade.addColorStop(0, 'rgba(255,255,255,0.18)');
    shade.addColorStop(1, 'rgba(0,0,0,0.3)');
    ctx.fillStyle = shade;
    ctx.fill();
    ctx.strokeStyle = 'rgba(255,255,255,0.25)';
    ctx.lineWidth = 1.5;
    ctx.stroke();
    ctx.font = `${Math.min(36, s * 0.5)}px "Apple Color Emoji","Segoe UI Emoji","Noto Color Emoji",sans-serif`;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(el.emoji, x + s / 2, y + s / 2 - (s >= 50 ? 8 : 0));
    if (s >= 50) {
      ctx.font = '700 11px system-ui,-apple-system,sans-serif';
      ctx.fillStyle = 'rgba(255,255,255,0.95)';
      ctx.fillText(el.name, x + s / 2, y + s * 0.85);
    }
    ctx.restore();
  }

  drawBlock(b, cell) {
    const e = ELEMENTS_BY_ID[b.elementId];
    if (!e) return;
    const age = (performance.now() - b.createdAt) / 1000;
    let scale = 1;
    if (age < 0.24) {
      const p = age / 0.24;
      scale = 0.4 + 0.6 * easeOutBack(p);
    }
    const s = cell - 6;
    const x = b.col * cell + 3;
    const y = b.row * cell + 3;
    const ctx = this.ctx;
    ctx.save();
    ctx.translate(x + s / 2, y + s / 2);
    ctx.scale(scale, scale);
    ctx.translate(-(x + s / 2), -(y + s / 2));
    this.drawTile(x, y, s, e, 1);
    // 灾害方块：脉动红圈
    if (e.type === '灾害') {
      const pulse = 0.45 + 0.3 * Math.sin(performance.now() / 280);
      ctx.strokeStyle = `rgba(255,80,80,${pulse})`;
      ctx.lineWidth = 2.5;
      roundRectPath(ctx, x + 1, y + 1, s - 2, s - 2, 10);
      ctx.stroke();
    }
    ctx.restore();
  }

  drawMergeAnim(a, cell) {
    const ctx = this.ctx;
    const p = Math.min(1, a.t / a.dur);
    const el = ELEMENTS_BY_ID[a.rid];
    const color = RARITY_INFO[el.rarity].color;
    const mx = (a.ax + a.bx) / 2;
    const my = (a.ay + a.by) / 2;
    ctx.save();
    // 两个旧元素向中心收缩
    ctx.globalAlpha = 1 - p;
    ctx.fillStyle = color;
    for (const [px, py] of [[a.ax, a.ay], [a.bx, a.by]]) {
      const nx = px + (mx - px) * p;
      const ny = py + (my - py) * p;
      ctx.beginPath();
      ctx.arc(nx, ny, cell * 0.36 * (1 - p * 0.6), 0, Math.PI * 2);
      ctx.fill();
    }
    ctx.globalAlpha = 1;
    // 扩散环
    ctx.strokeStyle = color;
    ctx.lineWidth = 3;
    ctx.beginPath();
    ctx.arc(mx, my, cell * 0.3 + p * cell * 1.15, 0, Math.PI * 2);
    ctx.stroke();
    // 结果预览
    if (p > 0.65) {
      const q = (p - 0.65) / 0.35;
      this.drawTile(a.col * cell + 3, a.row * cell + 3, cell - 6, el, q * 0.9);
    }
    ctx.restore();
  }
}

/* ------------------------------ 启动 ------------------------------ */

document.addEventListener('DOMContentLoaded', () => {
  window.game = new Game();
});
