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
  ['eagle',  '老鹰', '🦅', '动物', 2, ['bird', 'mountain']],
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
  ['cave',   '洞穴', '🕳️', '地形', 2, ['stone', 'mud']],
  ['geyser', '间歇泉', '⛲', '地形', 2, ['steam', 'earth']],
  ['snow',   '雪',   '❄️', '资源', 1, ['ice', 'wind']],
  ['glacier','冰川', '🏔️', '地形', 2, ['ice', 'mountain']],
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
  ['angel',   '天使', '😇', '神话', 3, ['human', 'bird']],
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

/* ---------------------------- 扩展元素（新增配方） ---------------------------- */

/** 新增元素：[id, 名称, 图标, 类型, 稀有度, 配方] */
const EXTRA_ELEMENTS = [
  /* 自然现象 */
  ['fog',        '雾',       '🌫️', '资源', 1, ['cloud', 'earth']],
  ['dew',        '露水',     '💠', '资源', 1, ['grass', 'night']],
  ['frost',      '霜',       '❄️', '资源', 1, ['cloud', 'ice']],
  ['thunder',    '雷',       '🌩️', '天文', 2, ['electricity', 'cloud']],
  ['lightning',  '闪电',     '⚡', '天文', 2, ['rain', 'electricity']],
  ['typhoon',    '台风',     '🌀', '灾害', 3, ['sea', 'wind']],
  ['avalanche',  '雪崩',     '🏔️', '灾害', 3, ['mountain', 'snow']],
  ['aurora',     '极光',     '💫', '天文', 3, ['sky', 'magnet']],
  ['shootingstar','流星',    '🌟', '天文', 3, ['star', 'meteor']],
  ['springw',    '泉水',     '🫧', '资源', 1, ['mountain', 'water']],
  ['hotspr',     '温泉',     '♨️', '地形', 2, ['springw', 'lava']],

  /* 季节与植物 */
  ['spring',     '春天',     '🌷', '天文', 2, ['seed', 'sun']],
  ['summer',     '夏天',     '🌞', '天文', 2, ['flower', 'sun']],
  ['autumn',     '秋天',     '🍂', '天文', 2, ['fruit', 'wind']],
  ['winter',     '冬天',     '❄️', '天文', 2, ['snow', 'cloud']],
  ['mapleleaf',  '枫叶',     '🍁', '植物', 1, ['tree', 'autumn']],
  ['sakura',     '樱花',     '🌸', '植物', 2, ['flower', 'spring']],
  ['snowflake',  '雪花',     '❄️', '资源', 1, ['ice', 'winter']],
  ['moss',       '苔藓',     '🌿', '植物', 1, ['stone', 'water']],
  ['fern',       '蕨类',     '🌿', '植物', 1, ['plant', 'swamp']],
  ['lotus',      '荷花',     '🪷', '植物', 1, ['flower', 'water']],
  ['pine',       '松树',     '🌲', '植物', 1, ['tree', 'snow']],
  ['apple',      '苹果',     '🍏', '植物', 1, ['tree', 'flower']],
  ['watermelon', '西瓜',     '🍉', '植物', 2, ['fruit', 'summer']],
  ['corn',       '玉米',     '🌽', '植物', 1, ['plant', 'autumn']],
  ['pumpkin',    '南瓜',     '🎃', '植物', 2, ['fruit', 'autumn']],
  ['oak',        '橡树',     '🌳', '植物', 2, ['tree', 'forest']],
  ['beach',      '沙滩',     '🏖️', '地形', 1, ['sand', 'sea']],
  ['coconut',    '椰子',     '🥥', '植物', 2, ['tree', 'beach']],
  ['palm',       '棕榈树',   '🌴', '植物', 2, ['tree', 'desert']],

  /* 动物 */
  ['shark',      '鲨鱼',     '🦈', '动物', 2, ['fish', 'sea']],
  ['whale',      '鲸鱼',     '🐳', '动物', 3, ['fish', 'ice']],
  ['crab',       '螃蟹',     '🦀', '动物', 1, ['sea', 'worm']],
  ['seaturtle',  '海龟',     '🐢', '动物', 2, ['turtle', 'sea']],
  ['penguin',    '企鹅',     '🐧', '动物', 2, ['bird', 'ice']],
  ['polar',      '北极熊',   '🐻', '动物', 3, ['bear', 'snow']],
  ['gorilla',    '猩猩',     '🦍', '动物', 3, ['monkey', 'forest']],
  ['panda',      '熊猫',     '🐼', '动物', 3, ['bear', 'bamboo']],
  ['mouse',      '老鼠',     '🐭', '动物', 1, ['house', 'cheese']],
  ['squirrel',   '松鼠',     '🐿️', '动物', 1, ['mouse', 'tree']],
  ['owl',        '猫头鹰',   '🦉', '动物', 2, ['bird', 'night']],
  ['bat',        '蝙蝠',     '🦇', '动物', 2, ['bird', 'cave']],
  ['dragonfly',  '蜻蜓',     '🪲', '动物', 1, ['butterfly', 'water']],
  ['ant',        '蚂蚁',     '🐜', '动物', 1, ['worm', 'sugar']],
  ['spider',     '蜘蛛',     '🕷️', '动物', 1, ['worm', 'thread']],
  ['scorpion',   '蝎子',     '🦂', '动物', 2, ['worm', 'desert']],
  ['parrot',     '鹦鹉',     '🦜', '动物', 2, ['bird', 'fruit']],
  ['peacock',    '孔雀',     '🦚', '动物', 2, ['bird', 'rainbow']],
  ['swan',       '天鹅',     '🦢', '动物', 1, ['bird', 'lake']],
  ['seagull',    '海鸥',     '🕊️', '动物', 1, ['bird', 'sea']],
  ['raccoon',    '浣熊',     '🦝', '动物', 2, ['fox', 'forest']],

  /* 工具与生活 */
  ['rope',       '绳子',     '🪢', '工具', 1, ['thread', 'vine']],
  ['net',        '渔网',     '🥅', '工具', 1, ['thread', 'water']],
  ['kite',       '风筝',     '🪁', '工具', 1, ['paper', 'wind']],
  ['umbrella',   '雨伞',     '☂️', '工具', 1, ['paper', 'rain']],
  ['glasses',    '眼镜',     '👓', '工具', 2, ['glass', 'glass']],
  ['bottle',     '瓶子',     '🍾', '材料', 1, ['glass', 'water']],
  ['pen',        '笔',       '🖊️', '工具', 1, ['stick', 'paper']],
  ['envelope',   '信封',     '✉️', '材料', 1, ['paper', 'thread']],
  ['map',        '地图',     '🗺️', '工具', 2, ['paper', 'earth']],
  ['flag',       '旗帜',     '🚩', '材料', 1, ['cloth', 'stick']],
  ['tent',       '帐篷',     '⛺', '建筑', 1, ['cloth', 'wood']],
  ['bed',        '床',       '🛏️', '建筑', 1, ['wood', 'cotton']],
  ['chair',      '椅子',     '🪑', '建筑', 1, ['wood', 'tool']],
  ['table',      '桌子',     '🍽️', '建筑', 1, ['chair', 'wood']],
  ['door',       '门',       '🚪', '建筑', 1, ['house', 'wood']],
  ['window',     '窗户',     '🪟', '建筑', 1, ['house', 'glass']],
  ['garden',     '花园',     '🌻', '建筑', 2, ['house', 'flower']],
  ['orchard',    '果园',     '🌳', '建筑', 2, ['garden', 'tree']],
  ['mill',       '风车',     '🎡', '建筑', 2, ['house', 'wind']],
  ['waterwheel', '水车',     '🛞', '工具', 2, ['wheel', 'water']],
  ['hammer',     '锤子',     '🔨', '工具', 1, ['stone', 'stick']],
  ['axe',        '斧头',     '🪓', '工具', 1, ['iron', 'stick']],
  ['saw',        '锯子',     '🪚', '工具', 1, ['iron', 'tree']],
  ['shovel',     '铲子',     '⛏️', '工具', 1, ['iron', 'earth']],
  ['fishingrod', '鱼竿',     '🎣', '工具', 1, ['stick', 'thread']],
  ['lantern',    '灯笼',     '🏮', '工具', 2, ['paper', 'fire']],
  ['key',        '钥匙',     '🔑', '工具', 2, ['iron', 'house']],
  ['lock',       '锁',       '🔒', '工具', 2, ['iron', 'door']],
  ['box',        '箱子',     '📦', '材料', 1, ['wood', 'wood']],
  ['backpack',   '背包',     '🎒', '工具', 2, ['cloth', 'box']],
  ['desk',       '书桌',     '🗄️', '建筑', 2, ['table', 'book']],
  ['calendar',   '日历',     '📅', '工具', 1, ['paper', 'sun']],

  /* 交通 */
  ['bicycle',    '自行车',   '🚲', '工具', 2, ['wheel', 'wheel']],
  ['motorcycle', '摩托车',   '🏍️', '工具', 3, ['bicycle', 'engine']],
  ['car',        '汽车',     '🚗', '工具', 3, ['wheel', 'engine']],
  ['truck',      '卡车',     '🚚', '工具', 3, ['car', 'box']],
  ['bus',        '公交车',   '🚌', '工具', 3, ['car', 'city']],
  ['rail',       '铁轨',     '🛤️', '建筑', 2, ['iron', 'road']],
  ['train',      '火车',     '🚂', '工具', 3, ['engine', 'rail']],
  ['airplane',   '飞机',     '✈️', '工具', 3, ['bird', 'engine']],
  ['helicopter', '直升机',   '🚁', '工具', 3, ['airplane', 'wind']],
  ['balloon',    '热气球',   '🎈', '工具', 2, ['fire', 'cloth']],
  ['canoe',      '独木舟',   '🛶', '工具', 2, ['wood', 'boat']],
  ['submarine',  '潜艇',     '🚤', '工具', 3, ['boat', 'iron']],
  ['subway',     '地铁',     '🚇', '工具', 3, ['train', 'stone']],

  /* 科技 */
  ['solarpanel', '太阳能板', '🔆', '科技', 3, ['sun', 'battery']],
  ['generator',  '发电机',   '🔌', '科技', 3, ['electricity', 'wheel']],
  ['windturbine','风力发电机','💨', '科技', 3, ['wind', 'generator']],
  ['hydro',      '水力发电机','💧', '科技', 3, ['water', 'generator']],
  ['powergrid',  '电网',     '⚡', '科技', 3, ['electricity', 'city']],
  ['tv',         '电视',     '📺', '科技', 3, ['radio', 'glass']],
  ['camera',     '相机',     '📷', '科技', 3, ['phone', 'glass']],
  ['console',    '游戏机',   '🎮', '科技', 3, ['tv', 'computer']],
  ['fridge',     '冰箱',     '❄️', '科技', 3, ['electricity', 'ice']],
  ['ac',         '空调',     '❄️', '科技', 3, ['electricity', 'wind']],
  ['washer',     '洗衣机',   '🧺', '科技', 3, ['electricity', 'water']],
  ['drone',      '无人机',   '🛩️', '科技', 4, ['phone', 'airplane']],
  ['chip',       '芯片',     '💾', '科技', 4, ['sand', 'electricity']],
  ['fiber',      '光纤',     '➰', '科技', 4, ['internet', 'glass']],

  /* 能源与材料 */
  ['naturalgas', '天然气',   '⛽', '资源', 2, ['oil', 'coal']],
  ['sapphire',   '蓝宝石',   '💙', '矿物', 3, ['crystal', 'water']],
  ['ruby',       '红宝石',   '❤️', '矿物', 3, ['gem', 'fire']],
  ['jade',       '翡翠',     '💚', '矿物', 3, ['gem', 'plant']],
  ['porcelain',  '瓷器',     '⚱️', '材料', 3, ['pottery', 'fire']],
  ['steel',      '钢',       '🔩', '材料', 3, ['iron', 'coal']],
  ['alloy',      '合金',     '🔗', '材料', 3, ['iron', 'gold']],
  ['soap',       '肥皂',     '🧼', '材料', 2, ['oil', 'ash']],
  ['paint',      '颜料',     '🎨', '材料', 2, ['fruit', 'oil']],
  ['brush',      '画笔',     '🖌️', '工具', 1, ['stick', 'paint']],
  ['painting',   '绘画',     '🖼️', '文明', 2, ['paper', 'paint']],
  ['sculpture',  '雕塑',     '🗿', '文明', 3, ['stone', 'tool']],
  ['statue',     '雕像',     '🗿', '文明', 3, ['sculpture', 'stone']],

  /* 食物 */
  ['coffeebean', '咖啡豆',   '🫘', '植物', 1, ['plant', 'sun']],
  ['coffee',     '咖啡',     '☕', '食物', 2, ['coffeebean', 'fire']],
  ['tea',        '茶',       '🍵', '食物', 1, ['grass', 'fire']],
  ['cola',       '可乐',     '🥤', '食物', 2, ['sugar', 'water']],
  ['milkshake',  '奶昔',     '🥤', '食物', 2, ['milk', 'icecream']],
  ['icecream',   '冰淇淋',   '🍦', '食物', 2, ['milk', 'ice']],
  ['popcorn',    '爆米花',   '🍿', '食物', 1, ['corn', 'fire']],
  ['potato',     '土豆',     '🥔', '植物', 1, ['seed', 'earth']],
  ['fries',      '薯条',     '🍟', '食物', 1, ['potato', 'oil']],
  ['tomato',     '番茄',     '🍅', '植物', 1, ['fruit', 'sun']],
  ['chili',      '辣椒',     '🌶️', '食物', 2, ['spice', 'fire']],
  ['rice',       '大米',     '🍚', '食物', 1, ['grass', 'swamp']],
  ['sushi',      '寿司',     '🍣', '食物', 2, ['rice', 'fish']],
  ['noodles',    '面条',     '🍜', '食物', 2, ['wheat', 'water']],
  ['dough',      '面团',     '🥖', '食物', 1, ['wheat', 'milk']],
  ['dumpling',   '饺子',     '🥟', '食物', 2, ['dough', 'meat']],
  ['burger',     '汉堡',     '🍔', '食物', 2, ['bread', 'meat']],
  ['chips',      '薯片',     '🍘', '食物', 1, ['potato', 'salt']],
  ['jam',        '果酱',     '🫙', '食物', 2, ['fruit', 'sugar']],
  ['cacao',      '可可',     '🫘', '植物', 2, ['plant', 'fruit']],
  ['chocolate',  '巧克力',   '🍫', '食物', 3, ['cacao', 'sugar']],
  ['flour',      '面粉',     '🫓', '食物', 1, ['wheat', 'stone']],
  ['mooncake',   '月饼',     '🥮', '食物', 3, ['flour', 'moon']],
  ['jelly',      '果冻',     '🍮', '食物', 2, ['juice', 'ice']],

  /* 神话 */
  ['ninetails',  '九尾狐',   '🦊', '神话', 4, ['fox', 'moon']],
  ['siren',      '海妖',     '🧜', '神话', 3, ['mermaid', 'sea']],
  ['centaur',    '半人马',   '🏇', '神话', 3, ['horse', 'human']],
  ['griffin',    '狮鹫',     '🦅', '神话', 4, ['eagle', 'lion']],
  ['gargoyle',   '石像鬼',   '👹', '神话', 3, ['castle', 'stone']],
  ['wand',       '魔杖',     '🪄', '神话', 4, ['wizard', 'stick']],
  ['potion',     '药水',     '🧪', '神话', 3, ['wizard', 'bottle']],
  ['crystalball','水晶球',   '🔮', '神话', 4, ['wizard', 'glass']],
  ['dragonegg',  '龙蛋',     '🥚', '神话', 4, ['dragon', 'egg']],

  /* 灾害 */
  ['firedisaster','火灾',    '🔥', '灾害', 3, ['house', 'fire']],
  ['thunderstorm','雷暴',    '⛈️', '灾害', 3, ['thunder', 'rain']],
  ['coldwave',   '寒潮',     '🥶', '灾害', 2, ['winter', 'wind']],

  /* 艺术 */
  ['piano',      '钢琴',     '🎹', '文明', 2, ['wood', 'music']],
  ['guitar',     '吉他',     '🎸', '文明', 2, ['wood', 'thread']],
  ['violin',     '小提琴',   '🎻', '文明', 2, ['music', 'thread']],

  /* 地形 */
  ['waterfall',  '瀑布',     '💦', '地形', 2, ['springw', 'river']],
  ['peninsula',  '半岛',     '🗾', '地形', 2, ['island', 'mountain']],
  ['mountainrange','山脉',   '⛰️', '地形', 2, ['mountain', 'mountain']],
  ['prairie',    '草原',     '🌾', '地形', 1, ['grass', 'grass']],
  ['wetland',    '湿地',     '🌿', '地形', 1, ['swamp', 'water']],
  ['coralreef',  '珊瑚礁',   '🪸', '地形', 3, ['sea', 'flower']],
  ['shell',      '贝壳',     '🐚', '资源', 1, ['sea', 'stone']],
  ['pearl',      '珍珠',     '🦪', '资源', 3, ['shell', 'sand']],
];

/* ---------------------------- 替代配方（让已有方块有更多合成路径） ---------------------------- */

/** 为已有元素追加的替代配方：元素id -> [[a, b], ...] */
const ALT_RECIPES = {
  rain: [['cloud', 'water']],          // 云遇冷凝结成雨
  sand: [['stone', 'wind']],           // 石头风化粉碎成沙
  mud: [['clay', 'water']],            // 黏土遇水成泥
  ice: [['snow', 'water']],            // 雪水冻结成冰
  glass: [['sand', 'lightning']],      // 闪电击中沙地烧成玻璃
  lava: [['volcano', 'fire']],         // 火山喷发带来熔岩
  snow: [['rain', 'ice']],             // 雨遇冰成雪
  storm: [['thunder', 'cloud']],       // 雷云聚集形成风暴
  fruit: [['tree', 'sun']],            // 果实被阳光催熟
  bread: [['dough', 'fire']],          // 面团烤成面包
  milk: [['cow', 'grass']],            // 牛吃草产奶
  egg: [['chicken', 'chicken'], ['bird', 'bird']], // 鸡生蛋 / IGN: 鸟+鸟
  wood: [['axe', 'tree']],             // 斧头砍树得木材
  butter: [['milk', 'machine']],       // 机器搅打牛奶出黄油
  cheese: [['milk', 'mushroom']],      // 牛奶发酵成奶酪
  city: [['village', 'house'], ['village', 'village']], // 村庄扩建 / IGN: 村+村
  village: [['house', 'farm']],        // 农家聚集成村
  ship: [['wood', 'sail']],            // 木板配帆成船
  electricity: [['thunder', 'iron']],  // 雷击铁器引发电
  lamp: [['glass', 'fire']],           // 玻璃罩住火焰成灯
  salt: [['sea', 'sun']],              // 海水晒干得盐
  rocket: [['engine', 'sky']],         // 引擎飞天成为火箭
  computer: [['machine', 'tv']],       // 机器与电视结合成电脑
  phone: [['radio', 'radio']],         // 无线电对讲机进化成手机
  robot: [['machine', 'computer']],    // 机器装上电脑变成机器人
  paper: [['bamboo', 'stone']],        // 竹浆压制造纸
  umbrella: [['cloth', 'rain']],       // 布挡雨成伞
  kite: [['cloth', 'wind']],           // 布借风成风筝
  rope: [['vine', 'vine']],            // 藤蔓编织成绳
  chocolate: [['cacao', 'milk']],      // 可可加奶成牛奶巧克力
  candy: [['sugar', 'honey']],         // 糖与蜜熬成糖果
  cake: [['bread', 'butter']],         // 面包涂黄油升级成蛋糕
  pizza: [['bread', 'tomato']],        // 面包加番茄酱成披萨
  sushi: [['rice', 'sea']],            // 海味配米饭成寿司
  // ---- 依据 Little Alchemy 标准配方表（IGN）补充的替代路径 ----
  dew: [['fog', 'grass']],             // IGN: 雾+草
  brick: [['mud', 'fire']],            // IGN: 泥+火
  bridge: [['river', 'wood']],         // IGN: 河+木
  bus: [['car', 'car']],               // IGN: 车+车
  blizzard: [['snow', 'storm']],       // IGN: 雪+风暴
  dough: [['flour', 'water']],         // IGN: 面粉+水
  bank: [['house', 'money']],          // IGN: 房子+金币
  drone: [['airplane', 'robot']],      // IGN: 飞机+机器人
  jam: [['juice', 'sugar']],           // IGN: 果汁+糖
};

/* ---------------------------- 图标去重表 ---------------------------- */

/**
 * 为避免重复图标，为部分元素指定独立 emoji（只影响展示，不影响配方/可达性）。
 * 少数概念没有更贴切的替代图标（如 山/丘陵/泰坦），允许少量共用。
 */
const EMOJI_OVERRIDES = {
  // 火系
  campfire: '🏕️',
  firedisaster: '🚒',
  // 水系
  hydro: '🚰',
  // 熔岩 / 火山
  volcano: '🗻',
  // 温泉
  hotspr: '🛁',
  // 沙 / 沙滩
  beach: '⛱️',
  // 天气
  thunderstorm: '🌦️',
  fog: '🌁',
  thunder: '🔊',
  lightning: '🌩️',
  powergrid: '🗼',
  // 玻璃 / 窗户
  glass: '🥃',
  // 矿石 / 铲子
  shovel: '⚒️',
  // 铁 / 机器
  machine: '🔧',
  // 宝石 / 水晶球
  gem: '🔷',
  // 植物系
  plant: '🪴',
  moss: '🍀',
  fern: '🥬',
  grass: '🌿',
  prairie: '🌼',
  wetland: '🦟',
  // 树木系
  oak: '🌰',
  orchard: '🍑',
  pine: '🎄',
  // 花系
  sakura: '🌺',
  // 蛋 / 龙蛋
  dragonegg: '🪺',
  // 龟 / 海龟
  seaturtle: '🦎',
  // 狐狸 / 九尾狐
  ninetails: '🐈',
  // 熊 / 北极熊
  polar: '🧸',
  // 鹰 / 狮鹫
  griffin: '🐲',
  // 城墙 / 砖
  wall: '🏯',
  // 陶器 / 瓷器
  porcelain: '🍶',
  // 轮子 / 水车
  waterwheel: '🪣',
  // 小船 / 潜艇
  submarine: '🤿',
  // 书 / 图书馆
  library: '📖',
  // 科学 / 药水
  potion: '⚗️',
  // 山系
  mountainrange: '🌄',
  // 水系地形
  river: '🏞️',
  lake: '🌅',
  flood: '🚨',
  tsunami: '🛟',
  // 雪系
  frost: '🌨️',
  winter: '🎿',
  snowflake: '☃️',
  blizzard: '⛄',
  avalanche: '🏂',
  fridge: '🥶',
  ac: '🪭',
  coldwave: '🧥',
  // 太阳 / 夏天
  summer: '🩳',
  // 引擎 / 火车
  engine: '🏎️',
  // 橡胶 / 热气球
  rubber: '🏐',
  // 香料 / 辣椒
  chili: '🥵',
  // 龙卷风 / 沙尘暴
  // 美人鱼 / 海妖
  siren: '🎶',
  // 雕塑 / 雕像 / 泰坦
  statue: '🧍',
  // 咖啡豆 / 可可
  cacao: '🍇',
  // 可乐 / 奶昔
  milkshake: '🍹',
};

/* ---------------------------- 数据归一化 ---------------------------- */

const ELEMENTS = [...RAW_ELEMENTS, ...EXTRA_ELEMENTS].map(
  ([id, name, emoji, type, rarity, recipe]) => {
    const recipes = [recipe, ...(ALT_RECIPES[id] || [])].filter(Boolean);
    return {
      id,
      name,
      emoji: EMOJI_OVERRIDES[id] || emoji,
      type,
      rarity,
      recipe: recipes[0] || null, // 主配方（兼容旧代码）
      recipes,                     // 全部配方（支持一物多配方）
      desc: `${name}——${TYPE_FLAVOR[type]}`,
      attrs: {
        ...TYPE_ATTRS[type],
        value: VALUE_BY_RARITY[rarity],
      },
    };
  },
);

const ELEMENTS_BY_ID = Object.fromEntries(ELEMENTS.map((e) => [e.id, e]));

/** 配方索引：无序元素对 -> 合成结果 id */
const RECIPE_INDEX = new Map();
function pairKey(a, b) {
  return a < b ? `${a}|${b}` : `${b}|${a}`;
}
for (const e of ELEMENTS) {
  for (const [a, b] of e.recipes) {
    RECIPE_INDEX.set(pairKey(a, b), e.id);
  }
}

/** 查询两个元素的合成结果；没有配方返回 null */
function findRecipe(aId, bId) {
  if (!aId || !bId) return null;
  return RECIPE_INDEX.get(pairKey(aId, bId)) || null;
}

/** 某元素的所有“孩子”（它能参与合成出什么） */
function getChildren(id) {
  return ELEMENTS.filter((e) =>
    e.recipes.some(([a, b]) => a === id || b === id),
  );
}

/** 最终物品：无法再参与任何合成（与 Little Alchemy 2 的 Final Items 同义） */
function isFinalElement(id) {
  return getChildren(id).length === 0;
}

/** 某元素的全部配方（每对配方返回 [父A, 父B]） */
function getRecipes(id) {
  const e = ELEMENTS_BY_ID[id];
  if (!e) return [];
  return e.recipes.map(([a, b]) => [ELEMENTS_BY_ID[a], ELEMENTS_BY_ID[b]]);
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
