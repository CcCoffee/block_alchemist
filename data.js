/* ============================================================================
 * 方块炼金师 - 元素数据表
 * ----------------------------------------------------------------------------
 * 每个元素：id / 名称 / 图标 / 类型 / 稀有度 / 配方（recipe: [a, b]）
 * 稀有度：0 基础 | 1 普通 | 2 稀有 | 3 史诗 | 4 传说
 * 属性在底部按类型自动生成：自然 / 科技 / 繁荣 / 价值
 * 规则：不允许数字合并、不允许滑动棋盘，只允许“元素配方合成”。
 * ========================================================================== */

'use strict';

/** 原始数据：[id, 名称, 图标, 类型, 稀有度, 配方] */
const RAW_ELEMENTS = [
  /* ---------- 初始元素 ---------- */
  ['fire',   '火',   '🔥', '元素', 0, null],
  ['water',  '水',   '💧', '元素', 0, null],
  ['earth',  '土',   '🌍', '元素', 0, null],
  ['wind',   '风',   '🌬️', '元素', 0, null],

  /* ---------- 基础合成 ---------- */
  ['stone',  '石头', '🪨', '矿物', 1, ['earth', 'earth']],
  ['mud',    '泥土', '🟫', '资源', 1, ['earth', 'water']],
  ['lava',   '熔岩', '🌋', '资源', 2, ['fire', 'earth']],
  ['steam',  '蒸汽', '♨️', '资源', 1, ['fire', 'water']],
  ['rain',   '雨',   '🌧️', '资源', 1, ['water', 'wind']],
  ['sand',   '沙',   '🏖️', '资源', 1, ['earth', 'wind']],
  ['storm',  '风暴', '⛈️', '灾害', 2, ['wind', 'fire']],
  ['cloud',  '云',   '☁️', '资源', 1, ['steam', 'wind']],
  ['ice',    '冰',   '🧊', '资源', 1, ['water', 'water']],
  ['dust',   '尘埃', '🌫️', '资源', 1, ['wind', 'sand']],
  ['obsidian', '黑曜石', '⚫', '矿物', 2, ['lava', 'water']],
  ['glass',  '玻璃', '🪟', '材料', 1, ['sand', 'fire']],
  ['ore',    '矿石', '⛏️', '矿物', 1, ['stone', 'earth']],
  ['iron',   '铁',   '⚙️', '材料', 2, ['ore', 'fire']],
  ['gold',   '金',   '🪙', '矿物', 3, ['ore', 'lava']],
  ['crystal','水晶', '💎', '矿物', 3, ['obsidian', 'ice']],
  ['gem',    '宝石', '🔮', '矿物', 4, ['crystal', 'gold']],

  /* ---------- 植物世界 ---------- */
  ['seed',   '种子', '🌱', '植物', 1, ['earth', 'rain']],
  ['plant',  '植物', '🌿', '植物', 1, ['seed', 'water']],
  ['tree',   '树',   '🌳', '植物', 1, ['plant', 'earth']],
  ['flower', '花',   '🌸', '植物', 1, ['plant', 'rain']],
  ['wood',   '木材', '🪵', '材料', 1, ['tree', 'stone']],
  ['ash',    '灰烬', '🖤', '资源', 1, ['plant', 'fire']],
  ['grass',  '草',   '🌾', '植物', 1, ['seed', 'wind']],
  ['mushroom', '蘑菇', '🍄', '植物', 1, ['plant', 'mud']],
  ['cactus', '仙人掌', '🌵', '植物', 1, ['plant', 'sand']],
  ['fruit',  '果实', '🍎', '植物', 1, ['tree', 'rain']],
  ['berry',  '浆果', '🫐', '植物', 1, ['flower', 'fruit']],
  ['bamboo', '竹子', '🎋', '植物', 2, ['grass', 'mud']],
  ['cotton', '棉花', '🪶', '资源', 1, ['plant', 'cloud']],
  ['vine',   '藤蔓', '🍃', '植物', 1, ['wood', 'rain']],
  ['wheat',  '小麦', '🌾', '植物', 1, ['grass', 'rain']],

  /* ---------- 动物世界 ---------- */
  ['egg',    '蛋',   '🥚', '资源', 1, ['stone', 'rain']],
  ['bird',   '鸟',   '🐦', '动物', 1, ['egg', 'wind']],
  ['fish',   '鱼',   '🐟', '动物', 1, ['egg', 'water']],
  ['worm',   '虫',   '🐛', '动物', 1, ['mud', 'seed']],
  ['butterfly', '蝴蝶', '🦋', '动物', 2, ['flower', 'worm']],
  ['bee',    '蜜蜂', '🐝', '动物', 2, ['flower', 'wind']],
  ['frog',   '青蛙', '🐸', '动物', 1, ['fish', 'mud']],
  ['snake',  '蛇',   '🐍', '动物', 2, ['worm', 'sand']],
  ['turtle', '龟',   '🐢', '动物', 2, ['egg', 'stone']],
  ['chicken','鸡',   '🐔', '动物', 1, ['bird', 'grass']],
  ['pig',    '猪',   '🐷', '动物', 1, ['mud', 'mushroom']],
  ['cow',    '牛',   '🐮', '动物', 1, ['grass', 'water']],
  ['horse',  '马',   '🐴', '动物', 2, ['cow', 'wind']],
  ['sheep',  '羊',   '🐑', '动物', 2, ['cloud', 'grass']],
  ['rabbit', '兔子', '🐇', '动物', 1, ['grass', 'stone']],
  ['fox',    '狐狸', '🦊', '动物', 2, ['rabbit', 'ice']],
  ['wolf',   '狼',   '🐺', '动物', 2, ['rabbit', 'storm']],
  ['bear',   '熊',   '🐻', '动物', 2, ['wolf', 'tree']],
  ['deer',   '鹿',   '🦌', '动物', 1, ['tree', 'grass']],
  ['cat',    '猫',   '🐱', '动物', 1, ['bird', 'rabbit']],
  ['lion',   '狮子', '🦁', '动物', 3, ['cat', 'fire']],
  ['eagle',  '老鹰', '🦅', '动物', 2, ['bird', 'storm']],
  ['monkey', '猴子', '🐒', '动物', 2, ['tree', 'fruit']],
  ['elephant', '大象', '🐘', '动物', 2, ['tree', 'water']],

  /* ---------- 人类与文明 ---------- */
  ['human',  '人类', '🧑', '文明', 3, ['monkey', 'tool']],
  ['tool',   '工具', '🛠️', '工具', 2, ['stone', 'wood']],
  ['stick',  '木棍', '🥢', '材料', 1, ['wood', 'wind']],
  ['house',  '房子', '🏠', '建筑', 2, ['wood', 'mud']],
  ['farm',   '农场', '🚜', '建筑', 2, ['house', 'seed']],
  ['village','村庄', '🏘️', '建筑', 3, ['house', 'house']],
  ['city',   '城市', '🏙️', '建筑', 4, ['village', 'stone']],
  ['wall',   '城墙', '🧱', '建筑', 2, ['stone', 'stone']],
  ['road',   '道路', '🛣️', '建筑', 2, ['stone', 'sand']],
  ['bridge', '桥',   '🌉', '建筑', 3, ['road', 'wood']],
  ['clay',   '黏土', '🏺', '材料', 1, ['mud', 'sand']],
  ['pottery','陶器', '⚱️', '材料', 2, ['clay', 'fire']],
  ['brick',  '砖',   '🧱', '材料', 2, ['clay', 'wall']],
  ['wheel',  '轮子', '🛞', '工具', 2, ['clay', 'wood']],
  ['cart',   '推车', '🛒', '工具', 2, ['wheel', 'wood']],
  ['boat',   '小船', '🚤', '建筑', 2, ['wood', 'water']],
  ['sail',   '帆',   '⛵', '材料', 2, ['cotton', 'wind']],
  ['ship',   '大船', '🚢', '建筑', 3, ['boat', 'sail']],
  ['paper',  '纸',   '📄', '材料', 2, ['wood', 'grass']],
  ['book',   '书',   '📚', '文明', 3, ['paper', 'paper']],
  ['sword',  '剑',   '⚔️', '工具', 2, ['iron', 'wood']],
  ['shield', '盾',   '🛡️', '工具', 2, ['iron', 'stone']],
  ['armor',  '盔甲', '🪖', '工具', 3, ['shield', 'iron']],
  ['bow',    '弓',   '🏹', '工具', 2, ['vine', 'wood']],
  ['torch',  '火把', '🔦', '工具', 1, ['stick', 'fire']],
  ['campfire','篝火', '🔥', '资源', 1, ['wood', 'fire']],
  ['money',  '金币', '💰', '文明', 3, ['gold', 'paper']],
  ['bank',   '银行', '🏦', '文明', 4, ['money', 'money']],
  ['kingdom','王国', '👑', '文明', 4, ['city', 'sword']],
  ['castle', '城堡', '🏰', '建筑', 4, ['kingdom', 'stone']],
  ['school', '学校', '🏫', '文明', 3, ['book', 'house']],
  ['library','图书馆', '📚', '文明', 3, ['book', 'school']],
  ['temple', '神庙', '🛕', '文明', 3, ['stone', 'human']],
  ['building','大楼', '🏢', '建筑', 3, ['house', 'stone']],
  ['factory','工厂', '🏭', '建筑', 4, ['machine', 'building']],
  ['cinema', '电影院', '🎬', '文明', 4, ['building', 'computer']],
  ['university','大学', '🎓', '文明', 4, ['school', 'city']],
  ['knowledge','知识', '🧠', '文明', 3, ['book', 'human']],
  ['science','科学', '🧪', '文明', 4, ['knowledge', 'telescope']],

  /* ---------- 地形与天文 ---------- */
  ['mountain','山', '⛰️', '地形', 2, ['earth', 'lava']],
  ['forest', '森林', '🌲', '地形', 2, ['tree', 'tree']],
  ['lake',   '湖',   '🏞️', '地形', 1, ['rain', 'mud']],
  ['river',  '河',   '🌊', '地形', 1, ['rain', 'rain']],
  ['sea',    '海',   '🌊', '地形', 2, ['water', 'lake']],
  ['island', '岛',   '🏝️', '地形', 2, ['sand', 'water']],
  ['swamp',  '沼泽', '🐊', '地形', 2, ['mud', 'tree']],
  ['desert', '沙漠', '🏜️', '地形', 2, ['sand', 'sand']],
  ['oasis',  '绿洲', '🌴', '地形', 3, ['desert', 'water']],
  ['cave',   '洞穴', '🕳️', '地形', 2, ['stone', 'mud']],
  ['geyser', '间歇泉', '⛲', '地形', 2, ['steam', 'stone']],
  ['snow',   '雪',   '❄️', '资源', 1, ['ice', 'wind']],
  ['glacier','冰川', '🏔️', '地形', 2, ['snow', 'stone']],
  ['sky',    '天空', '🌌', '地形', 1, ['wind', 'cloud']],
  ['star',   '星星', '⭐', '天文', 3, ['fire', 'sky']],
  ['sun',    '太阳', '🌞', '天文', 3, ['fire', 'star']],
  ['moon',   '月亮', '🌙', '天文', 3, ['star', 'stone']],
  ['night',  '夜晚', '🌃', '天文', 2, ['moon', 'sky']],
  ['rainbow','彩虹', '🌈', '天文', 3, ['rain', 'sun']],

  /* ---------- 科技 ---------- */
  ['electricity','电', '⚡', '科技', 3, ['storm', 'iron']],
  ['machine', '机器', '⚙️', '科技', 3, ['wheel', 'iron']],
  ['engine',  '引擎', '🚂', '科技', 3, ['machine', 'steam']],
  ['lamp',    '灯',   '💡', '科技', 2, ['electricity', 'glass']],
  ['battery', '电池', '🔋', '科技', 3, ['electricity', 'stone']],
  ['music',   '音乐', '🎵', '文明', 2, ['bird', 'wind']],
  ['radio',   '收音机', '📻', '科技', 3, ['electricity', 'music']],
  ['computer','电脑', '💻', '科技', 4, ['machine', 'electricity']],
  ['internet','互联网', '🌐', '科技', 4, ['computer', 'computer']],
  ['phone',   '手机', '📱', '科技', 4, ['computer', 'radio']],
  ['robot',   '机器人', '🤖', '科技', 4, ['machine', 'human']],
  ['rocket',  '火箭', '🚀', '科技', 4, ['fire', 'iron']],
  ['satellite','卫星', '🛰️', '科技', 4, ['rocket', 'radio']],
  ['spaceship','飞船', '🛸', '科技', 4, ['rocket', 'alien']],

  /* ---------- 材料与工业 ---------- */
  ['coal',    '煤炭', '⬛', '矿物', 1, ['wood', 'earth']],
  ['oil',     '石油', '🛢️', '资源', 2, ['coal', 'water']],
  ['plastic', '塑料', '♻️', '材料', 2, ['oil', 'fire']],
  ['rubber',  '橡胶', '🎈', '材料', 2, ['tree', 'oil']],
  ['mirror',  '镜子', '🪞', '材料', 2, ['glass', 'iron']],
  ['magnet',  '磁铁', '🧲', '材料', 3, ['iron', 'iron']],
  ['compass', '指南针', '🧭', '工具', 3, ['magnet', 'wood']],
  ['clock',   '时钟', '🕰️', '工具', 3, ['wheel', 'sun']],
  ['telescope','望远镜', '🔭', '工具', 3, ['glass', 'star']],
  ['microscope','显微镜', '🔬', '工具', 3, ['glass', 'medicine']],
  ['thread',  '线',   '🧵', '材料', 2, ['cotton', 'wheel']],
  ['cloth',   '布',   '🧣', '材料', 2, ['thread', 'thread']],
  ['clothes', '衣服', '👕', '材料', 2, ['cloth', 'human']],
  ['wool',    '羊毛', '🧶', '材料', 2, ['sheep', 'stone']],
  ['medicine','药',   '💊', '材料', 3, ['mushroom', 'fire']],

  /* ---------- 食物 ---------- */
  ['salt',    '盐',   '🧂', '食物', 1, ['sea', 'fire']],
  ['sugar',   '糖',   '🍬', '食物', 2, ['fruit', 'fire']],
  ['spice',   '香料', '🌶️', '食物', 2, ['flower', 'fire']],
  ['bread',   '面包', '🍞', '食物', 2, ['wheat', 'fire']],
  ['milk',    '牛奶', '🥛', '食物', 1, ['cow', 'water']],
  ['cheese',  '奶酪', '🧀', '食物', 2, ['milk', 'fire']],
  ['butter',  '黄油', '🧈', '食物', 2, ['milk', 'stone']],
  ['meat',    '肉',   '🍖', '食物', 2, ['cow', 'fire']],
  ['soup',    '汤',   '🍲', '食物', 2, ['water', 'meat']],
  ['juice',   '果汁', '🧃', '食物', 2, ['fruit', 'water']],
  ['wine',    '葡萄酒', '🍷', '食物', 3, ['fruit', 'rain']],
  ['honey',   '蜂蜜', '🍯', '食物', 3, ['bee', 'flower']],
  ['omelet',  '煎蛋', '🍳', '食物', 2, ['egg', 'fire']],
  ['salad',   '沙拉', '🥗', '食物', 2, ['fruit', 'grass']],
  ['candy',   '糖果', '🍭', '食物', 3, ['sugar', 'sugar']],
  ['cake',    '蛋糕', '🎂', '食物', 3, ['bread', 'milk']],
  ['pizza',   '披萨', '🍕', '食物', 3, ['bread', 'cheese']],

  /* ---------- 灾害事件 ---------- */
  ['drought', '干旱', '☀️', '灾害', 3, ['sand', 'rain']],
  ['flood',   '洪水', '🌊', '灾害', 3, ['rain', 'water']],
  ['volcano', '火山', '🌋', '灾害', 3, ['lava', 'stone']],
  ['earthquake','地震', '💥', '灾害', 3, ['stone', 'storm']],
  ['tornado', '龙卷风', '🌪️', '灾害', 3, ['storm', 'wind']],
  ['blizzard','暴风雪', '🌨️', '灾害', 3, ['storm', 'ice']],
  ['wildfire','野火', '🧯', '灾害', 3, ['fire', 'tree']],
  ['meteor',  '陨石', '☄️', '灾害', 3, ['fire', 'crystal']],
  ['tsunami', '海啸', '🌊', '灾害', 3, ['flood', 'storm']],

  /* ---------- 神话 ---------- */
  ['dragon',  '龙',   '🐉', '神话', 4, ['fire', 'snake']],
  ['unicorn', '独角兽', '🦄', '神话', 4, ['horse', 'rainbow']],
  ['phoenix', '凤凰', '🦩', '神话', 4, ['bird', 'fire']],
  ['giant',   '巨人', '🧌', '神话', 3, ['mountain', 'human']],
  ['mermaid', '美人鱼', '🧜', '神话', 3, ['fish', 'human']],
  ['alien',   '外星人', '👽', '神话', 4, ['star', 'human']],
  ['fairy',   '精灵', '🧚', '神话', 3, ['butterfly', 'human']],
  ['angel',   '天使', '😇', '神话', 3, ['human', 'cloud']],
  ['demon',   '恶魔', '😈', '神话', 3, ['fire', 'human']],
  ['zombie',  '僵尸', '🧟', '神话', 2, ['human', 'swamp']],
  ['ghost',   '幽灵', '👻', '神话', 2, ['human', 'night']],
  ['wizard',  '巫师', '🧙', '神话', 4, ['human', 'crystal']],
];

/* ---------------------------- 稀有度与类型 ---------------------------- */

const RARITY_INFO = [
  { key: '基础', color: '#8b95a5' },
  { key: '普通', color: '#c8d3e0' },
  { key: '稀有', color: '#4da3ff' },
  { key: '史诗', color: '#b06bff' },
  { key: '传说', color: '#ffb62e' },
];

const VALUE_BY_RARITY = [5, 10, 25, 60, 150];

const TYPE_COLORS = {
  '元素': '#8b95a5',
  '矿物': '#b8935a',
  '资源': '#58b368',
  '植物': '#7bed9f',
  '动物': '#ffa94d',
  '材料': '#9ad0ff',
  '建筑': '#e0c07a',
  '工具': '#b8c4d4',
  '文明': '#ff8fa3',
  '科技': '#7ed6ff',
  '食物': '#ffd34d',
  '灾害': '#ff6b6b',
  '神话': '#c792ff',
  '地形': '#8fd3a8',
  '天文': '#9aa7ff',
};

const TYPE_FLAVOR = {
  '元素': '天地初开的原始力量',
  '矿物': '深埋地下的珍贵矿物',
  '资源': '可以被利用的自然资源',
  '植物': '富有生命力的植物',
  '动物': '生机勃勃的动物',
  '材料': '经双手加工而成的材料',
  '建筑': '人类建造的设施',
  '工具': '实用的工具',
  '文明': '文明发展的结晶',
  '科技': '改变世界的科技',
  '食物': '令人满足的食物',
  '灾害': '带来威胁的灾难',
  '神话': '流传于传说中的存在',
  '地形': '塑造世界的自然地形',
  '天文': '来自天空与星辰的奇观',
};

/** 按类型生成的属性：自然 / 科技 / 繁荣（灾害为负值，会拉低世界繁荣） */
const TYPE_ATTRS = {
  '元素': { nature: 3, tech: 1, prosperity: 1 },
  '矿物': { nature: 3, tech: 2, prosperity: 2 },
  '资源': { nature: 4, tech: 1, prosperity: 2 },
  '植物': { nature: 8, tech: 0, prosperity: 2 },
  '动物': { nature: 7, tech: 1, prosperity: 2 },
  '材料': { nature: 2, tech: 3, prosperity: 2 },
  '建筑': { nature: 1, tech: 4, prosperity: 6 },
  '工具': { nature: 1, tech: 5, prosperity: 3 },
  '文明': { nature: 1, tech: 4, prosperity: 6 },
  '科技': { nature: 1, tech: 8, prosperity: 5 },
  '食物': { nature: 3, tech: 2, prosperity: 3 },
  '灾害': { nature: -4, tech: -2, prosperity: -5 },
  '神话': { nature: 5, tech: 2, prosperity: 3 },
  '地形': { nature: 5, tech: 0, prosperity: 1 },
  '天文': { nature: 4, tech: 4, prosperity: 2 },
};

/* ---------------------------- 数据归一化 ---------------------------- */

const ELEMENTS = RAW_ELEMENTS.map(([id, name, emoji, type, rarity, recipe]) => ({
  id,
  name,
  emoji,
  type,
  rarity,
  recipe, // [aId, bId] 或 null（初始元素）
  desc: `${name}——${TYPE_FLAVOR[type]}`,
  attrs: {
    ...TYPE_ATTRS[type],
    value: VALUE_BY_RARITY[rarity],
  },
}));

const ELEMENTS_BY_ID = Object.fromEntries(ELEMENTS.map((e) => [e.id, e]));

/** 配方索引：无序元素对 -> 合成结果 id */
const RECIPE_INDEX = new Map();
function pairKey(a, b) {
  return a < b ? `${a}|${b}` : `${b}|${a}`;
}
for (const e of ELEMENTS) {
  if (e.recipe) RECIPE_INDEX.set(pairKey(e.recipe[0], e.recipe[1]), e.id);
}

/** 查询两个元素的合成结果；没有配方返回 null */
function findRecipe(aId, bId) {
  if (!aId || !bId) return null;
  return RECIPE_INDEX.get(pairKey(aId, bId)) || null;
}

/** 某元素的所有“孩子”（它能参与合成出什么） */
function getChildren(id) {
  return ELEMENTS.filter((e) => e.recipe && (e.recipe[0] === id || e.recipe[1] === id));
}

/** 某元素的“父母”（它的配方是什么） */
function getParents(id) {
  const e = ELEMENTS_BY_ID[id];
  if (!e || !e.recipe) return [];
  return e.recipe.map((pid) => ELEMENTS_BY_ID[pid]);
}

const DISASTER_IDS = ELEMENTS.filter((e) => e.type === '灾害').map((e) => e.id);
const STARTER_IDS = ['fire', 'water', 'earth', 'wind'];
const TYPE_LIST = [...new Set(ELEMENTS.map((e) => e.type))];
