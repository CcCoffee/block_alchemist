// 由 scripts/gen_elements.js 自动生成 — 方块炼金师元素数据（请勿手改）
import 'dart:ui' show Color;

/// 元素定义：名称 / 类型 / 稀有度 / 属性 / 配方
class ElementDef {
  final String id;
  final String name;
  final String emoji;
  final String type;
  final int rarity;
  final String desc;
  final int nature;
  final int tech;
  final int prosperity;
  final int value;
  /// [a, b] 无序配方，null 表示初始元素
  final List<String>? recipe;
  const ElementDef({
    required this.id,
    required this.name,
    required this.emoji,
    required this.type,
    required this.rarity,
    required this.desc,
    required this.nature,
    required this.tech,
    required this.prosperity,
    required this.value,
    this.recipe,
  });
}

const List<ElementDef> kElements = <ElementDef>[
  ElementDef(id: 'fire', name: '火', emoji: '🔥', type: '元素', rarity: 0, desc: '火——天地初开的原始力量', nature: 3, tech: 1, prosperity: 1, value: 5, recipe: null),
  ElementDef(id: 'water', name: '水', emoji: '💧', type: '元素', rarity: 0, desc: '水——天地初开的原始力量', nature: 3, tech: 1, prosperity: 1, value: 5, recipe: null),
  ElementDef(id: 'earth', name: '土', emoji: '🌍', type: '元素', rarity: 0, desc: '土——天地初开的原始力量', nature: 3, tech: 1, prosperity: 1, value: 5, recipe: null),
  ElementDef(id: 'wind', name: '风', emoji: '🌬️', type: '元素', rarity: 0, desc: '风——天地初开的原始力量', nature: 3, tech: 1, prosperity: 1, value: 5, recipe: null),
  ElementDef(id: 'stone', name: '石头', emoji: '🪨', type: '矿物', rarity: 1, desc: '石头——深埋地下的珍贵矿物', nature: 3, tech: 2, prosperity: 2, value: 10, recipe: ['earth', 'earth']),
  ElementDef(id: 'mud', name: '泥土', emoji: '🟫', type: '资源', rarity: 1, desc: '泥土——可以被利用的自然资源', nature: 4, tech: 1, prosperity: 2, value: 10, recipe: ['earth', 'water']),
  ElementDef(id: 'lava', name: '熔岩', emoji: '🌋', type: '资源', rarity: 2, desc: '熔岩——可以被利用的自然资源', nature: 4, tech: 1, prosperity: 2, value: 25, recipe: ['fire', 'earth']),
  ElementDef(id: 'steam', name: '蒸汽', emoji: '♨️', type: '资源', rarity: 1, desc: '蒸汽——可以被利用的自然资源', nature: 4, tech: 1, prosperity: 2, value: 10, recipe: ['fire', 'water']),
  ElementDef(id: 'rain', name: '雨', emoji: '🌧️', type: '资源', rarity: 1, desc: '雨——可以被利用的自然资源', nature: 4, tech: 1, prosperity: 2, value: 10, recipe: ['water', 'wind']),
  ElementDef(id: 'sand', name: '沙', emoji: '🏖️', type: '资源', rarity: 1, desc: '沙——可以被利用的自然资源', nature: 4, tech: 1, prosperity: 2, value: 10, recipe: ['earth', 'wind']),
  ElementDef(id: 'storm', name: '风暴', emoji: '⛈️', type: '灾害', rarity: 2, desc: '风暴——带来威胁的灾难', nature: -4, tech: -2, prosperity: -5, value: 25, recipe: ['wind', 'fire']),
  ElementDef(id: 'cloud', name: '云', emoji: '☁️', type: '资源', rarity: 1, desc: '云——可以被利用的自然资源', nature: 4, tech: 1, prosperity: 2, value: 10, recipe: ['steam', 'wind']),
  ElementDef(id: 'ice', name: '冰', emoji: '🧊', type: '资源', rarity: 1, desc: '冰——可以被利用的自然资源', nature: 4, tech: 1, prosperity: 2, value: 10, recipe: ['water', 'water']),
  ElementDef(id: 'dust', name: '尘埃', emoji: '🌫️', type: '资源', rarity: 1, desc: '尘埃——可以被利用的自然资源', nature: 4, tech: 1, prosperity: 2, value: 10, recipe: ['wind', 'sand']),
  ElementDef(id: 'obsidian', name: '黑曜石', emoji: '⚫', type: '矿物', rarity: 2, desc: '黑曜石——深埋地下的珍贵矿物', nature: 3, tech: 2, prosperity: 2, value: 25, recipe: ['lava', 'water']),
  ElementDef(id: 'glass', name: '玻璃', emoji: '🪟', type: '材料', rarity: 1, desc: '玻璃——经双手加工而成的材料', nature: 2, tech: 3, prosperity: 2, value: 10, recipe: ['sand', 'fire']),
  ElementDef(id: 'ore', name: '矿石', emoji: '⛏️', type: '矿物', rarity: 1, desc: '矿石——深埋地下的珍贵矿物', nature: 3, tech: 2, prosperity: 2, value: 10, recipe: ['stone', 'earth']),
  ElementDef(id: 'iron', name: '铁', emoji: '⚙️', type: '材料', rarity: 2, desc: '铁——经双手加工而成的材料', nature: 2, tech: 3, prosperity: 2, value: 25, recipe: ['ore', 'fire']),
  ElementDef(id: 'gold', name: '金', emoji: '🪙', type: '矿物', rarity: 3, desc: '金——深埋地下的珍贵矿物', nature: 3, tech: 2, prosperity: 2, value: 60, recipe: ['ore', 'lava']),
  ElementDef(id: 'crystal', name: '水晶', emoji: '💎', type: '矿物', rarity: 3, desc: '水晶——深埋地下的珍贵矿物', nature: 3, tech: 2, prosperity: 2, value: 60, recipe: ['obsidian', 'ice']),
  ElementDef(id: 'gem', name: '宝石', emoji: '🔮', type: '矿物', rarity: 4, desc: '宝石——深埋地下的珍贵矿物', nature: 3, tech: 2, prosperity: 2, value: 150, recipe: ['crystal', 'gold']),
  ElementDef(id: 'seed', name: '种子', emoji: '🌱', type: '植物', rarity: 1, desc: '种子——富有生命力的植物', nature: 8, tech: 0, prosperity: 2, value: 10, recipe: ['earth', 'rain']),
  ElementDef(id: 'plant', name: '植物', emoji: '🌿', type: '植物', rarity: 1, desc: '植物——富有生命力的植物', nature: 8, tech: 0, prosperity: 2, value: 10, recipe: ['seed', 'water']),
  ElementDef(id: 'tree', name: '树', emoji: '🌳', type: '植物', rarity: 1, desc: '树——富有生命力的植物', nature: 8, tech: 0, prosperity: 2, value: 10, recipe: ['plant', 'earth']),
  ElementDef(id: 'flower', name: '花', emoji: '🌸', type: '植物', rarity: 1, desc: '花——富有生命力的植物', nature: 8, tech: 0, prosperity: 2, value: 10, recipe: ['plant', 'rain']),
  ElementDef(id: 'wood', name: '木材', emoji: '🪵', type: '材料', rarity: 1, desc: '木材——经双手加工而成的材料', nature: 2, tech: 3, prosperity: 2, value: 10, recipe: ['tree', 'stone']),
  ElementDef(id: 'ash', name: '灰烬', emoji: '🖤', type: '资源', rarity: 1, desc: '灰烬——可以被利用的自然资源', nature: 4, tech: 1, prosperity: 2, value: 10, recipe: ['plant', 'fire']),
  ElementDef(id: 'grass', name: '草', emoji: '🌾', type: '植物', rarity: 1, desc: '草——富有生命力的植物', nature: 8, tech: 0, prosperity: 2, value: 10, recipe: ['seed', 'wind']),
  ElementDef(id: 'mushroom', name: '蘑菇', emoji: '🍄', type: '植物', rarity: 1, desc: '蘑菇——富有生命力的植物', nature: 8, tech: 0, prosperity: 2, value: 10, recipe: ['plant', 'mud']),
  ElementDef(id: 'cactus', name: '仙人掌', emoji: '🌵', type: '植物', rarity: 1, desc: '仙人掌——富有生命力的植物', nature: 8, tech: 0, prosperity: 2, value: 10, recipe: ['plant', 'sand']),
  ElementDef(id: 'fruit', name: '果实', emoji: '🍎', type: '植物', rarity: 1, desc: '果实——富有生命力的植物', nature: 8, tech: 0, prosperity: 2, value: 10, recipe: ['tree', 'rain']),
  ElementDef(id: 'berry', name: '浆果', emoji: '🫐', type: '植物', rarity: 1, desc: '浆果——富有生命力的植物', nature: 8, tech: 0, prosperity: 2, value: 10, recipe: ['flower', 'fruit']),
  ElementDef(id: 'bamboo', name: '竹子', emoji: '🎋', type: '植物', rarity: 2, desc: '竹子——富有生命力的植物', nature: 8, tech: 0, prosperity: 2, value: 25, recipe: ['grass', 'mud']),
  ElementDef(id: 'cotton', name: '棉花', emoji: '🪶', type: '资源', rarity: 1, desc: '棉花——可以被利用的自然资源', nature: 4, tech: 1, prosperity: 2, value: 10, recipe: ['plant', 'cloud']),
  ElementDef(id: 'vine', name: '藤蔓', emoji: '🍃', type: '植物', rarity: 1, desc: '藤蔓——富有生命力的植物', nature: 8, tech: 0, prosperity: 2, value: 10, recipe: ['wood', 'rain']),
  ElementDef(id: 'wheat', name: '小麦', emoji: '🌾', type: '植物', rarity: 1, desc: '小麦——富有生命力的植物', nature: 8, tech: 0, prosperity: 2, value: 10, recipe: ['grass', 'rain']),
  ElementDef(id: 'egg', name: '蛋', emoji: '🥚', type: '资源', rarity: 1, desc: '蛋——可以被利用的自然资源', nature: 4, tech: 1, prosperity: 2, value: 10, recipe: ['stone', 'rain']),
  ElementDef(id: 'bird', name: '鸟', emoji: '🐦', type: '动物', rarity: 1, desc: '鸟——生机勃勃的动物', nature: 7, tech: 1, prosperity: 2, value: 10, recipe: ['egg', 'wind']),
  ElementDef(id: 'fish', name: '鱼', emoji: '🐟', type: '动物', rarity: 1, desc: '鱼——生机勃勃的动物', nature: 7, tech: 1, prosperity: 2, value: 10, recipe: ['egg', 'water']),
  ElementDef(id: 'worm', name: '虫', emoji: '🐛', type: '动物', rarity: 1, desc: '虫——生机勃勃的动物', nature: 7, tech: 1, prosperity: 2, value: 10, recipe: ['mud', 'seed']),
  ElementDef(id: 'butterfly', name: '蝴蝶', emoji: '🦋', type: '动物', rarity: 2, desc: '蝴蝶——生机勃勃的动物', nature: 7, tech: 1, prosperity: 2, value: 25, recipe: ['flower', 'worm']),
  ElementDef(id: 'bee', name: '蜜蜂', emoji: '🐝', type: '动物', rarity: 2, desc: '蜜蜂——生机勃勃的动物', nature: 7, tech: 1, prosperity: 2, value: 25, recipe: ['flower', 'wind']),
  ElementDef(id: 'frog', name: '青蛙', emoji: '🐸', type: '动物', rarity: 1, desc: '青蛙——生机勃勃的动物', nature: 7, tech: 1, prosperity: 2, value: 10, recipe: ['fish', 'mud']),
  ElementDef(id: 'snake', name: '蛇', emoji: '🐍', type: '动物', rarity: 2, desc: '蛇——生机勃勃的动物', nature: 7, tech: 1, prosperity: 2, value: 25, recipe: ['worm', 'sand']),
  ElementDef(id: 'turtle', name: '龟', emoji: '🐢', type: '动物', rarity: 2, desc: '龟——生机勃勃的动物', nature: 7, tech: 1, prosperity: 2, value: 25, recipe: ['egg', 'stone']),
  ElementDef(id: 'chicken', name: '鸡', emoji: '🐔', type: '动物', rarity: 1, desc: '鸡——生机勃勃的动物', nature: 7, tech: 1, prosperity: 2, value: 10, recipe: ['bird', 'grass']),
  ElementDef(id: 'pig', name: '猪', emoji: '🐷', type: '动物', rarity: 1, desc: '猪——生机勃勃的动物', nature: 7, tech: 1, prosperity: 2, value: 10, recipe: ['mud', 'mushroom']),
  ElementDef(id: 'cow', name: '牛', emoji: '🐮', type: '动物', rarity: 1, desc: '牛——生机勃勃的动物', nature: 7, tech: 1, prosperity: 2, value: 10, recipe: ['grass', 'water']),
  ElementDef(id: 'horse', name: '马', emoji: '🐴', type: '动物', rarity: 2, desc: '马——生机勃勃的动物', nature: 7, tech: 1, prosperity: 2, value: 25, recipe: ['cow', 'wind']),
  ElementDef(id: 'sheep', name: '羊', emoji: '🐑', type: '动物', rarity: 2, desc: '羊——生机勃勃的动物', nature: 7, tech: 1, prosperity: 2, value: 25, recipe: ['cloud', 'grass']),
  ElementDef(id: 'rabbit', name: '兔子', emoji: '🐇', type: '动物', rarity: 1, desc: '兔子——生机勃勃的动物', nature: 7, tech: 1, prosperity: 2, value: 10, recipe: ['grass', 'stone']),
  ElementDef(id: 'fox', name: '狐狸', emoji: '🦊', type: '动物', rarity: 2, desc: '狐狸——生机勃勃的动物', nature: 7, tech: 1, prosperity: 2, value: 25, recipe: ['rabbit', 'ice']),
  ElementDef(id: 'wolf', name: '狼', emoji: '🐺', type: '动物', rarity: 2, desc: '狼——生机勃勃的动物', nature: 7, tech: 1, prosperity: 2, value: 25, recipe: ['rabbit', 'storm']),
  ElementDef(id: 'bear', name: '熊', emoji: '🐻', type: '动物', rarity: 2, desc: '熊——生机勃勃的动物', nature: 7, tech: 1, prosperity: 2, value: 25, recipe: ['wolf', 'tree']),
  ElementDef(id: 'deer', name: '鹿', emoji: '🦌', type: '动物', rarity: 1, desc: '鹿——生机勃勃的动物', nature: 7, tech: 1, prosperity: 2, value: 10, recipe: ['tree', 'grass']),
  ElementDef(id: 'cat', name: '猫', emoji: '🐱', type: '动物', rarity: 1, desc: '猫——生机勃勃的动物', nature: 7, tech: 1, prosperity: 2, value: 10, recipe: ['bird', 'rabbit']),
  ElementDef(id: 'lion', name: '狮子', emoji: '🦁', type: '动物', rarity: 3, desc: '狮子——生机勃勃的动物', nature: 7, tech: 1, prosperity: 2, value: 60, recipe: ['cat', 'fire']),
  ElementDef(id: 'eagle', name: '老鹰', emoji: '🦅', type: '动物', rarity: 2, desc: '老鹰——生机勃勃的动物', nature: 7, tech: 1, prosperity: 2, value: 25, recipe: ['bird', 'storm']),
  ElementDef(id: 'monkey', name: '猴子', emoji: '🐒', type: '动物', rarity: 2, desc: '猴子——生机勃勃的动物', nature: 7, tech: 1, prosperity: 2, value: 25, recipe: ['tree', 'fruit']),
  ElementDef(id: 'elephant', name: '大象', emoji: '🐘', type: '动物', rarity: 2, desc: '大象——生机勃勃的动物', nature: 7, tech: 1, prosperity: 2, value: 25, recipe: ['tree', 'water']),
  ElementDef(id: 'human', name: '人类', emoji: '🧑', type: '文明', rarity: 3, desc: '人类——文明发展的结晶', nature: 1, tech: 4, prosperity: 6, value: 60, recipe: ['monkey', 'tool']),
  ElementDef(id: 'tool', name: '工具', emoji: '🛠️', type: '工具', rarity: 2, desc: '工具——实用的工具', nature: 1, tech: 5, prosperity: 3, value: 25, recipe: ['stone', 'wood']),
  ElementDef(id: 'stick', name: '木棍', emoji: '🥢', type: '材料', rarity: 1, desc: '木棍——经双手加工而成的材料', nature: 2, tech: 3, prosperity: 2, value: 10, recipe: ['wood', 'wind']),
  ElementDef(id: 'house', name: '房子', emoji: '🏠', type: '建筑', rarity: 2, desc: '房子——人类建造的设施', nature: 1, tech: 4, prosperity: 6, value: 25, recipe: ['wood', 'mud']),
  ElementDef(id: 'farm', name: '农场', emoji: '🚜', type: '建筑', rarity: 2, desc: '农场——人类建造的设施', nature: 1, tech: 4, prosperity: 6, value: 25, recipe: ['house', 'seed']),
  ElementDef(id: 'village', name: '村庄', emoji: '🏘️', type: '建筑', rarity: 3, desc: '村庄——人类建造的设施', nature: 1, tech: 4, prosperity: 6, value: 60, recipe: ['house', 'house']),
  ElementDef(id: 'city', name: '城市', emoji: '🏙️', type: '建筑', rarity: 4, desc: '城市——人类建造的设施', nature: 1, tech: 4, prosperity: 6, value: 150, recipe: ['village', 'stone']),
  ElementDef(id: 'wall', name: '城墙', emoji: '🧱', type: '建筑', rarity: 2, desc: '城墙——人类建造的设施', nature: 1, tech: 4, prosperity: 6, value: 25, recipe: ['stone', 'stone']),
  ElementDef(id: 'road', name: '道路', emoji: '🛣️', type: '建筑', rarity: 2, desc: '道路——人类建造的设施', nature: 1, tech: 4, prosperity: 6, value: 25, recipe: ['stone', 'sand']),
  ElementDef(id: 'bridge', name: '桥', emoji: '🌉', type: '建筑', rarity: 3, desc: '桥——人类建造的设施', nature: 1, tech: 4, prosperity: 6, value: 60, recipe: ['road', 'wood']),
  ElementDef(id: 'clay', name: '黏土', emoji: '🏺', type: '材料', rarity: 1, desc: '黏土——经双手加工而成的材料', nature: 2, tech: 3, prosperity: 2, value: 10, recipe: ['mud', 'sand']),
  ElementDef(id: 'pottery', name: '陶器', emoji: '⚱️', type: '材料', rarity: 2, desc: '陶器——经双手加工而成的材料', nature: 2, tech: 3, prosperity: 2, value: 25, recipe: ['clay', 'fire']),
  ElementDef(id: 'brick', name: '砖', emoji: '🧱', type: '材料', rarity: 2, desc: '砖——经双手加工而成的材料', nature: 2, tech: 3, prosperity: 2, value: 25, recipe: ['clay', 'wall']),
  ElementDef(id: 'wheel', name: '轮子', emoji: '🛞', type: '工具', rarity: 2, desc: '轮子——实用的工具', nature: 1, tech: 5, prosperity: 3, value: 25, recipe: ['clay', 'wood']),
  ElementDef(id: 'cart', name: '推车', emoji: '🛒', type: '工具', rarity: 2, desc: '推车——实用的工具', nature: 1, tech: 5, prosperity: 3, value: 25, recipe: ['wheel', 'wood']),
  ElementDef(id: 'boat', name: '小船', emoji: '🚤', type: '建筑', rarity: 2, desc: '小船——人类建造的设施', nature: 1, tech: 4, prosperity: 6, value: 25, recipe: ['wood', 'water']),
  ElementDef(id: 'sail', name: '帆', emoji: '⛵', type: '材料', rarity: 2, desc: '帆——经双手加工而成的材料', nature: 2, tech: 3, prosperity: 2, value: 25, recipe: ['cotton', 'wind']),
  ElementDef(id: 'ship', name: '大船', emoji: '🚢', type: '建筑', rarity: 3, desc: '大船——人类建造的设施', nature: 1, tech: 4, prosperity: 6, value: 60, recipe: ['boat', 'sail']),
  ElementDef(id: 'paper', name: '纸', emoji: '📄', type: '材料', rarity: 2, desc: '纸——经双手加工而成的材料', nature: 2, tech: 3, prosperity: 2, value: 25, recipe: ['wood', 'grass']),
  ElementDef(id: 'book', name: '书', emoji: '📚', type: '文明', rarity: 3, desc: '书——文明发展的结晶', nature: 1, tech: 4, prosperity: 6, value: 60, recipe: ['paper', 'paper']),
  ElementDef(id: 'sword', name: '剑', emoji: '⚔️', type: '工具', rarity: 2, desc: '剑——实用的工具', nature: 1, tech: 5, prosperity: 3, value: 25, recipe: ['iron', 'wood']),
  ElementDef(id: 'shield', name: '盾', emoji: '🛡️', type: '工具', rarity: 2, desc: '盾——实用的工具', nature: 1, tech: 5, prosperity: 3, value: 25, recipe: ['iron', 'stone']),
  ElementDef(id: 'armor', name: '盔甲', emoji: '🪖', type: '工具', rarity: 3, desc: '盔甲——实用的工具', nature: 1, tech: 5, prosperity: 3, value: 60, recipe: ['shield', 'iron']),
  ElementDef(id: 'bow', name: '弓', emoji: '🏹', type: '工具', rarity: 2, desc: '弓——实用的工具', nature: 1, tech: 5, prosperity: 3, value: 25, recipe: ['vine', 'wood']),
  ElementDef(id: 'torch', name: '火把', emoji: '🔦', type: '工具', rarity: 1, desc: '火把——实用的工具', nature: 1, tech: 5, prosperity: 3, value: 10, recipe: ['stick', 'fire']),
  ElementDef(id: 'campfire', name: '篝火', emoji: '🔥', type: '资源', rarity: 1, desc: '篝火——可以被利用的自然资源', nature: 4, tech: 1, prosperity: 2, value: 10, recipe: ['wood', 'fire']),
  ElementDef(id: 'money', name: '金币', emoji: '💰', type: '文明', rarity: 3, desc: '金币——文明发展的结晶', nature: 1, tech: 4, prosperity: 6, value: 60, recipe: ['gold', 'paper']),
  ElementDef(id: 'bank', name: '银行', emoji: '🏦', type: '文明', rarity: 4, desc: '银行——文明发展的结晶', nature: 1, tech: 4, prosperity: 6, value: 150, recipe: ['money', 'money']),
  ElementDef(id: 'kingdom', name: '王国', emoji: '👑', type: '文明', rarity: 4, desc: '王国——文明发展的结晶', nature: 1, tech: 4, prosperity: 6, value: 150, recipe: ['city', 'sword']),
  ElementDef(id: 'castle', name: '城堡', emoji: '🏰', type: '建筑', rarity: 4, desc: '城堡——人类建造的设施', nature: 1, tech: 4, prosperity: 6, value: 150, recipe: ['kingdom', 'stone']),
  ElementDef(id: 'school', name: '学校', emoji: '🏫', type: '文明', rarity: 3, desc: '学校——文明发展的结晶', nature: 1, tech: 4, prosperity: 6, value: 60, recipe: ['book', 'house']),
  ElementDef(id: 'library', name: '图书馆', emoji: '📚', type: '文明', rarity: 3, desc: '图书馆——文明发展的结晶', nature: 1, tech: 4, prosperity: 6, value: 60, recipe: ['book', 'school']),
  ElementDef(id: 'temple', name: '神庙', emoji: '🛕', type: '文明', rarity: 3, desc: '神庙——文明发展的结晶', nature: 1, tech: 4, prosperity: 6, value: 60, recipe: ['stone', 'human']),
  ElementDef(id: 'building', name: '大楼', emoji: '🏢', type: '建筑', rarity: 3, desc: '大楼——人类建造的设施', nature: 1, tech: 4, prosperity: 6, value: 60, recipe: ['house', 'stone']),
  ElementDef(id: 'factory', name: '工厂', emoji: '🏭', type: '建筑', rarity: 4, desc: '工厂——人类建造的设施', nature: 1, tech: 4, prosperity: 6, value: 150, recipe: ['machine', 'building']),
  ElementDef(id: 'cinema', name: '电影院', emoji: '🎬', type: '文明', rarity: 4, desc: '电影院——文明发展的结晶', nature: 1, tech: 4, prosperity: 6, value: 150, recipe: ['building', 'computer']),
  ElementDef(id: 'university', name: '大学', emoji: '🎓', type: '文明', rarity: 4, desc: '大学——文明发展的结晶', nature: 1, tech: 4, prosperity: 6, value: 150, recipe: ['school', 'city']),
  ElementDef(id: 'knowledge', name: '知识', emoji: '🧠', type: '文明', rarity: 3, desc: '知识——文明发展的结晶', nature: 1, tech: 4, prosperity: 6, value: 60, recipe: ['book', 'human']),
  ElementDef(id: 'science', name: '科学', emoji: '🧪', type: '文明', rarity: 4, desc: '科学——文明发展的结晶', nature: 1, tech: 4, prosperity: 6, value: 150, recipe: ['knowledge', 'telescope']),
  ElementDef(id: 'mountain', name: '山', emoji: '⛰️', type: '地形', rarity: 2, desc: '山——塑造世界的自然地形', nature: 5, tech: 0, prosperity: 1, value: 25, recipe: ['earth', 'lava']),
  ElementDef(id: 'forest', name: '森林', emoji: '🌲', type: '地形', rarity: 2, desc: '森林——塑造世界的自然地形', nature: 5, tech: 0, prosperity: 1, value: 25, recipe: ['tree', 'tree']),
  ElementDef(id: 'lake', name: '湖', emoji: '🏞️', type: '地形', rarity: 1, desc: '湖——塑造世界的自然地形', nature: 5, tech: 0, prosperity: 1, value: 10, recipe: ['rain', 'mud']),
  ElementDef(id: 'river', name: '河', emoji: '🌊', type: '地形', rarity: 1, desc: '河——塑造世界的自然地形', nature: 5, tech: 0, prosperity: 1, value: 10, recipe: ['rain', 'rain']),
  ElementDef(id: 'sea', name: '海', emoji: '🌊', type: '地形', rarity: 2, desc: '海——塑造世界的自然地形', nature: 5, tech: 0, prosperity: 1, value: 25, recipe: ['water', 'lake']),
  ElementDef(id: 'island', name: '岛', emoji: '🏝️', type: '地形', rarity: 2, desc: '岛——塑造世界的自然地形', nature: 5, tech: 0, prosperity: 1, value: 25, recipe: ['sand', 'water']),
  ElementDef(id: 'swamp', name: '沼泽', emoji: '🐊', type: '地形', rarity: 2, desc: '沼泽——塑造世界的自然地形', nature: 5, tech: 0, prosperity: 1, value: 25, recipe: ['mud', 'tree']),
  ElementDef(id: 'desert', name: '沙漠', emoji: '🏜️', type: '地形', rarity: 2, desc: '沙漠——塑造世界的自然地形', nature: 5, tech: 0, prosperity: 1, value: 25, recipe: ['sand', 'sand']),
  ElementDef(id: 'oasis', name: '绿洲', emoji: '🌴', type: '地形', rarity: 3, desc: '绿洲——塑造世界的自然地形', nature: 5, tech: 0, prosperity: 1, value: 60, recipe: ['desert', 'water']),
  ElementDef(id: 'cave', name: '洞穴', emoji: '🕳️', type: '地形', rarity: 2, desc: '洞穴——塑造世界的自然地形', nature: 5, tech: 0, prosperity: 1, value: 25, recipe: ['stone', 'mud']),
  ElementDef(id: 'geyser', name: '间歇泉', emoji: '⛲', type: '地形', rarity: 2, desc: '间歇泉——塑造世界的自然地形', nature: 5, tech: 0, prosperity: 1, value: 25, recipe: ['steam', 'stone']),
  ElementDef(id: 'snow', name: '雪', emoji: '❄️', type: '资源', rarity: 1, desc: '雪——可以被利用的自然资源', nature: 4, tech: 1, prosperity: 2, value: 10, recipe: ['ice', 'wind']),
  ElementDef(id: 'glacier', name: '冰川', emoji: '🏔️', type: '地形', rarity: 2, desc: '冰川——塑造世界的自然地形', nature: 5, tech: 0, prosperity: 1, value: 25, recipe: ['snow', 'stone']),
  ElementDef(id: 'sky', name: '天空', emoji: '🌌', type: '地形', rarity: 1, desc: '天空——塑造世界的自然地形', nature: 5, tech: 0, prosperity: 1, value: 10, recipe: ['wind', 'cloud']),
  ElementDef(id: 'star', name: '星星', emoji: '⭐', type: '天文', rarity: 3, desc: '星星——来自天空与星辰的奇观', nature: 4, tech: 4, prosperity: 2, value: 60, recipe: ['fire', 'sky']),
  ElementDef(id: 'sun', name: '太阳', emoji: '🌞', type: '天文', rarity: 3, desc: '太阳——来自天空与星辰的奇观', nature: 4, tech: 4, prosperity: 2, value: 60, recipe: ['fire', 'star']),
  ElementDef(id: 'moon', name: '月亮', emoji: '🌙', type: '天文', rarity: 3, desc: '月亮——来自天空与星辰的奇观', nature: 4, tech: 4, prosperity: 2, value: 60, recipe: ['star', 'stone']),
  ElementDef(id: 'night', name: '夜晚', emoji: '🌃', type: '天文', rarity: 2, desc: '夜晚——来自天空与星辰的奇观', nature: 4, tech: 4, prosperity: 2, value: 25, recipe: ['moon', 'sky']),
  ElementDef(id: 'rainbow', name: '彩虹', emoji: '🌈', type: '天文', rarity: 3, desc: '彩虹——来自天空与星辰的奇观', nature: 4, tech: 4, prosperity: 2, value: 60, recipe: ['rain', 'sun']),
  ElementDef(id: 'electricity', name: '电', emoji: '⚡', type: '科技', rarity: 3, desc: '电——改变世界的科技', nature: 1, tech: 8, prosperity: 5, value: 60, recipe: ['storm', 'iron']),
  ElementDef(id: 'machine', name: '机器', emoji: '⚙️', type: '科技', rarity: 3, desc: '机器——改变世界的科技', nature: 1, tech: 8, prosperity: 5, value: 60, recipe: ['wheel', 'iron']),
  ElementDef(id: 'engine', name: '引擎', emoji: '🚂', type: '科技', rarity: 3, desc: '引擎——改变世界的科技', nature: 1, tech: 8, prosperity: 5, value: 60, recipe: ['machine', 'steam']),
  ElementDef(id: 'lamp', name: '灯', emoji: '💡', type: '科技', rarity: 2, desc: '灯——改变世界的科技', nature: 1, tech: 8, prosperity: 5, value: 25, recipe: ['electricity', 'glass']),
  ElementDef(id: 'battery', name: '电池', emoji: '🔋', type: '科技', rarity: 3, desc: '电池——改变世界的科技', nature: 1, tech: 8, prosperity: 5, value: 60, recipe: ['electricity', 'stone']),
  ElementDef(id: 'music', name: '音乐', emoji: '🎵', type: '文明', rarity: 2, desc: '音乐——文明发展的结晶', nature: 1, tech: 4, prosperity: 6, value: 25, recipe: ['bird', 'wind']),
  ElementDef(id: 'radio', name: '收音机', emoji: '📻', type: '科技', rarity: 3, desc: '收音机——改变世界的科技', nature: 1, tech: 8, prosperity: 5, value: 60, recipe: ['electricity', 'music']),
  ElementDef(id: 'computer', name: '电脑', emoji: '💻', type: '科技', rarity: 4, desc: '电脑——改变世界的科技', nature: 1, tech: 8, prosperity: 5, value: 150, recipe: ['machine', 'electricity']),
  ElementDef(id: 'internet', name: '互联网', emoji: '🌐', type: '科技', rarity: 4, desc: '互联网——改变世界的科技', nature: 1, tech: 8, prosperity: 5, value: 150, recipe: ['computer', 'computer']),
  ElementDef(id: 'phone', name: '手机', emoji: '📱', type: '科技', rarity: 4, desc: '手机——改变世界的科技', nature: 1, tech: 8, prosperity: 5, value: 150, recipe: ['computer', 'radio']),
  ElementDef(id: 'robot', name: '机器人', emoji: '🤖', type: '科技', rarity: 4, desc: '机器人——改变世界的科技', nature: 1, tech: 8, prosperity: 5, value: 150, recipe: ['machine', 'human']),
  ElementDef(id: 'rocket', name: '火箭', emoji: '🚀', type: '科技', rarity: 4, desc: '火箭——改变世界的科技', nature: 1, tech: 8, prosperity: 5, value: 150, recipe: ['fire', 'iron']),
  ElementDef(id: 'satellite', name: '卫星', emoji: '🛰️', type: '科技', rarity: 4, desc: '卫星——改变世界的科技', nature: 1, tech: 8, prosperity: 5, value: 150, recipe: ['rocket', 'radio']),
  ElementDef(id: 'spaceship', name: '飞船', emoji: '🛸', type: '科技', rarity: 4, desc: '飞船——改变世界的科技', nature: 1, tech: 8, prosperity: 5, value: 150, recipe: ['rocket', 'alien']),
  ElementDef(id: 'coal', name: '煤炭', emoji: '⬛', type: '矿物', rarity: 1, desc: '煤炭——深埋地下的珍贵矿物', nature: 3, tech: 2, prosperity: 2, value: 10, recipe: ['wood', 'earth']),
  ElementDef(id: 'oil', name: '石油', emoji: '🛢️', type: '资源', rarity: 2, desc: '石油——可以被利用的自然资源', nature: 4, tech: 1, prosperity: 2, value: 25, recipe: ['coal', 'water']),
  ElementDef(id: 'plastic', name: '塑料', emoji: '♻️', type: '材料', rarity: 2, desc: '塑料——经双手加工而成的材料', nature: 2, tech: 3, prosperity: 2, value: 25, recipe: ['oil', 'fire']),
  ElementDef(id: 'rubber', name: '橡胶', emoji: '🎈', type: '材料', rarity: 2, desc: '橡胶——经双手加工而成的材料', nature: 2, tech: 3, prosperity: 2, value: 25, recipe: ['tree', 'oil']),
  ElementDef(id: 'mirror', name: '镜子', emoji: '🪞', type: '材料', rarity: 2, desc: '镜子——经双手加工而成的材料', nature: 2, tech: 3, prosperity: 2, value: 25, recipe: ['glass', 'iron']),
  ElementDef(id: 'magnet', name: '磁铁', emoji: '🧲', type: '材料', rarity: 3, desc: '磁铁——经双手加工而成的材料', nature: 2, tech: 3, prosperity: 2, value: 60, recipe: ['iron', 'iron']),
  ElementDef(id: 'compass', name: '指南针', emoji: '🧭', type: '工具', rarity: 3, desc: '指南针——实用的工具', nature: 1, tech: 5, prosperity: 3, value: 60, recipe: ['magnet', 'wood']),
  ElementDef(id: 'clock', name: '时钟', emoji: '🕰️', type: '工具', rarity: 3, desc: '时钟——实用的工具', nature: 1, tech: 5, prosperity: 3, value: 60, recipe: ['wheel', 'sun']),
  ElementDef(id: 'telescope', name: '望远镜', emoji: '🔭', type: '工具', rarity: 3, desc: '望远镜——实用的工具', nature: 1, tech: 5, prosperity: 3, value: 60, recipe: ['glass', 'star']),
  ElementDef(id: 'microscope', name: '显微镜', emoji: '🔬', type: '工具', rarity: 3, desc: '显微镜——实用的工具', nature: 1, tech: 5, prosperity: 3, value: 60, recipe: ['glass', 'medicine']),
  ElementDef(id: 'thread', name: '线', emoji: '🧵', type: '材料', rarity: 2, desc: '线——经双手加工而成的材料', nature: 2, tech: 3, prosperity: 2, value: 25, recipe: ['cotton', 'wheel']),
  ElementDef(id: 'cloth', name: '布', emoji: '🧣', type: '材料', rarity: 2, desc: '布——经双手加工而成的材料', nature: 2, tech: 3, prosperity: 2, value: 25, recipe: ['thread', 'thread']),
  ElementDef(id: 'clothes', name: '衣服', emoji: '👕', type: '材料', rarity: 2, desc: '衣服——经双手加工而成的材料', nature: 2, tech: 3, prosperity: 2, value: 25, recipe: ['cloth', 'human']),
  ElementDef(id: 'wool', name: '羊毛', emoji: '🧶', type: '材料', rarity: 2, desc: '羊毛——经双手加工而成的材料', nature: 2, tech: 3, prosperity: 2, value: 25, recipe: ['sheep', 'stone']),
  ElementDef(id: 'medicine', name: '药', emoji: '💊', type: '材料', rarity: 3, desc: '药——经双手加工而成的材料', nature: 2, tech: 3, prosperity: 2, value: 60, recipe: ['mushroom', 'fire']),
  ElementDef(id: 'salt', name: '盐', emoji: '🧂', type: '食物', rarity: 1, desc: '盐——令人满足的食物', nature: 3, tech: 2, prosperity: 3, value: 10, recipe: ['sea', 'fire']),
  ElementDef(id: 'sugar', name: '糖', emoji: '🍬', type: '食物', rarity: 2, desc: '糖——令人满足的食物', nature: 3, tech: 2, prosperity: 3, value: 25, recipe: ['fruit', 'fire']),
  ElementDef(id: 'spice', name: '香料', emoji: '🌶️', type: '食物', rarity: 2, desc: '香料——令人满足的食物', nature: 3, tech: 2, prosperity: 3, value: 25, recipe: ['flower', 'fire']),
  ElementDef(id: 'bread', name: '面包', emoji: '🍞', type: '食物', rarity: 2, desc: '面包——令人满足的食物', nature: 3, tech: 2, prosperity: 3, value: 25, recipe: ['wheat', 'fire']),
  ElementDef(id: 'milk', name: '牛奶', emoji: '🥛', type: '食物', rarity: 1, desc: '牛奶——令人满足的食物', nature: 3, tech: 2, prosperity: 3, value: 10, recipe: ['cow', 'water']),
  ElementDef(id: 'cheese', name: '奶酪', emoji: '🧀', type: '食物', rarity: 2, desc: '奶酪——令人满足的食物', nature: 3, tech: 2, prosperity: 3, value: 25, recipe: ['milk', 'fire']),
  ElementDef(id: 'butter', name: '黄油', emoji: '🧈', type: '食物', rarity: 2, desc: '黄油——令人满足的食物', nature: 3, tech: 2, prosperity: 3, value: 25, recipe: ['milk', 'stone']),
  ElementDef(id: 'meat', name: '肉', emoji: '🍖', type: '食物', rarity: 2, desc: '肉——令人满足的食物', nature: 3, tech: 2, prosperity: 3, value: 25, recipe: ['cow', 'fire']),
  ElementDef(id: 'soup', name: '汤', emoji: '🍲', type: '食物', rarity: 2, desc: '汤——令人满足的食物', nature: 3, tech: 2, prosperity: 3, value: 25, recipe: ['water', 'meat']),
  ElementDef(id: 'juice', name: '果汁', emoji: '🧃', type: '食物', rarity: 2, desc: '果汁——令人满足的食物', nature: 3, tech: 2, prosperity: 3, value: 25, recipe: ['fruit', 'water']),
  ElementDef(id: 'wine', name: '葡萄酒', emoji: '🍷', type: '食物', rarity: 3, desc: '葡萄酒——令人满足的食物', nature: 3, tech: 2, prosperity: 3, value: 60, recipe: ['fruit', 'rain']),
  ElementDef(id: 'honey', name: '蜂蜜', emoji: '🍯', type: '食物', rarity: 3, desc: '蜂蜜——令人满足的食物', nature: 3, tech: 2, prosperity: 3, value: 60, recipe: ['bee', 'flower']),
  ElementDef(id: 'omelet', name: '煎蛋', emoji: '🍳', type: '食物', rarity: 2, desc: '煎蛋——令人满足的食物', nature: 3, tech: 2, prosperity: 3, value: 25, recipe: ['egg', 'fire']),
  ElementDef(id: 'salad', name: '沙拉', emoji: '🥗', type: '食物', rarity: 2, desc: '沙拉——令人满足的食物', nature: 3, tech: 2, prosperity: 3, value: 25, recipe: ['fruit', 'grass']),
  ElementDef(id: 'candy', name: '糖果', emoji: '🍭', type: '食物', rarity: 3, desc: '糖果——令人满足的食物', nature: 3, tech: 2, prosperity: 3, value: 60, recipe: ['sugar', 'sugar']),
  ElementDef(id: 'cake', name: '蛋糕', emoji: '🎂', type: '食物', rarity: 3, desc: '蛋糕——令人满足的食物', nature: 3, tech: 2, prosperity: 3, value: 60, recipe: ['bread', 'milk']),
  ElementDef(id: 'pizza', name: '披萨', emoji: '🍕', type: '食物', rarity: 3, desc: '披萨——令人满足的食物', nature: 3, tech: 2, prosperity: 3, value: 60, recipe: ['bread', 'cheese']),
  ElementDef(id: 'drought', name: '干旱', emoji: '☀️', type: '灾害', rarity: 3, desc: '干旱——带来威胁的灾难', nature: -4, tech: -2, prosperity: -5, value: 60, recipe: ['sand', 'rain']),
  ElementDef(id: 'flood', name: '洪水', emoji: '🌊', type: '灾害', rarity: 3, desc: '洪水——带来威胁的灾难', nature: -4, tech: -2, prosperity: -5, value: 60, recipe: ['rain', 'water']),
  ElementDef(id: 'volcano', name: '火山', emoji: '🌋', type: '灾害', rarity: 3, desc: '火山——带来威胁的灾难', nature: -4, tech: -2, prosperity: -5, value: 60, recipe: ['lava', 'stone']),
  ElementDef(id: 'earthquake', name: '地震', emoji: '💥', type: '灾害', rarity: 3, desc: '地震——带来威胁的灾难', nature: -4, tech: -2, prosperity: -5, value: 60, recipe: ['stone', 'storm']),
  ElementDef(id: 'tornado', name: '龙卷风', emoji: '🌪️', type: '灾害', rarity: 3, desc: '龙卷风——带来威胁的灾难', nature: -4, tech: -2, prosperity: -5, value: 60, recipe: ['storm', 'wind']),
  ElementDef(id: 'blizzard', name: '暴风雪', emoji: '🌨️', type: '灾害', rarity: 3, desc: '暴风雪——带来威胁的灾难', nature: -4, tech: -2, prosperity: -5, value: 60, recipe: ['storm', 'ice']),
  ElementDef(id: 'wildfire', name: '野火', emoji: '🧯', type: '灾害', rarity: 3, desc: '野火——带来威胁的灾难', nature: -4, tech: -2, prosperity: -5, value: 60, recipe: ['fire', 'tree']),
  ElementDef(id: 'meteor', name: '陨石', emoji: '☄️', type: '灾害', rarity: 3, desc: '陨石——带来威胁的灾难', nature: -4, tech: -2, prosperity: -5, value: 60, recipe: ['fire', 'crystal']),
  ElementDef(id: 'tsunami', name: '海啸', emoji: '🌊', type: '灾害', rarity: 3, desc: '海啸——带来威胁的灾难', nature: -4, tech: -2, prosperity: -5, value: 60, recipe: ['flood', 'storm']),
  ElementDef(id: 'dragon', name: '龙', emoji: '🐉', type: '神话', rarity: 4, desc: '龙——流传于传说中的存在', nature: 5, tech: 2, prosperity: 3, value: 150, recipe: ['fire', 'snake']),
  ElementDef(id: 'unicorn', name: '独角兽', emoji: '🦄', type: '神话', rarity: 4, desc: '独角兽——流传于传说中的存在', nature: 5, tech: 2, prosperity: 3, value: 150, recipe: ['horse', 'rainbow']),
  ElementDef(id: 'phoenix', name: '凤凰', emoji: '🦩', type: '神话', rarity: 4, desc: '凤凰——流传于传说中的存在', nature: 5, tech: 2, prosperity: 3, value: 150, recipe: ['bird', 'fire']),
  ElementDef(id: 'giant', name: '巨人', emoji: '🧌', type: '神话', rarity: 3, desc: '巨人——流传于传说中的存在', nature: 5, tech: 2, prosperity: 3, value: 60, recipe: ['mountain', 'human']),
  ElementDef(id: 'mermaid', name: '美人鱼', emoji: '🧜', type: '神话', rarity: 3, desc: '美人鱼——流传于传说中的存在', nature: 5, tech: 2, prosperity: 3, value: 60, recipe: ['fish', 'human']),
  ElementDef(id: 'alien', name: '外星人', emoji: '👽', type: '神话', rarity: 4, desc: '外星人——流传于传说中的存在', nature: 5, tech: 2, prosperity: 3, value: 150, recipe: ['star', 'human']),
  ElementDef(id: 'fairy', name: '精灵', emoji: '🧚', type: '神话', rarity: 3, desc: '精灵——流传于传说中的存在', nature: 5, tech: 2, prosperity: 3, value: 60, recipe: ['butterfly', 'human']),
  ElementDef(id: 'angel', name: '天使', emoji: '😇', type: '神话', rarity: 3, desc: '天使——流传于传说中的存在', nature: 5, tech: 2, prosperity: 3, value: 60, recipe: ['human', 'cloud']),
  ElementDef(id: 'demon', name: '恶魔', emoji: '😈', type: '神话', rarity: 3, desc: '恶魔——流传于传说中的存在', nature: 5, tech: 2, prosperity: 3, value: 60, recipe: ['fire', 'human']),
  ElementDef(id: 'zombie', name: '僵尸', emoji: '🧟', type: '神话', rarity: 2, desc: '僵尸——流传于传说中的存在', nature: 5, tech: 2, prosperity: 3, value: 25, recipe: ['human', 'swamp']),
  ElementDef(id: 'ghost', name: '幽灵', emoji: '👻', type: '神话', rarity: 2, desc: '幽灵——流传于传说中的存在', nature: 5, tech: 2, prosperity: 3, value: 25, recipe: ['human', 'night']),
  ElementDef(id: 'wizard', name: '巫师', emoji: '🧙', type: '神话', rarity: 4, desc: '巫师——流传于传说中的存在', nature: 5, tech: 2, prosperity: 3, value: 150, recipe: ['human', 'crystal']),
];

const List<String> kRarityNames = <String>['基础', '普通', '稀有', '史诗', '传说'];
const List<Color> kRarityColors = <Color>[
  Color(0xFF8b95a5),
  Color(0xFFc8d3e0),
  Color(0xFF4da3ff),
  Color(0xFFb06bff),
  Color(0xFFffb62e),
];

const List<String> kStarterIds = <String>['fire', 'water', 'earth', 'wind'];

/// id -> 元素
final Map<String, ElementDef> elementById = <String, ElementDef>{
  for (final e in kElements) e.id: e,
};

String _pairKey(String a, String b) => a.compareTo(b) <= 0 ? "$a|$b" : "$b|$a";

final Map<String, String> _recipeIndex = <String, String>{
  for (final e in kElements)
    if (e.recipe != null) _pairKey(e.recipe![0], e.recipe![1]): e.id,
};

/// 查询两个元素的合成结果；没有配方返回 null
String? findRecipe(String? aId, String? bId) {
  if (aId == null || bId == null) return null;
  return _recipeIndex[_pairKey(aId, bId)];
}

/// 某元素能参与合成的所有“孩子”
List<ElementDef> childrenOf(String id) => kElements
    .where((e) => e.recipe != null && (e.recipe![0] == id || e.recipe![1] == id))
    .toList();

/// 某元素的合成配方“父母”
List<ElementDef> parentsOf(String id) {
  final e = elementById[id];
  if (e == null || e.recipe == null) return const [];
  return e.recipe!.map((p) => elementById[p]!).toList();
}

final List<String> kDisasterIds = kElements.where((e) => e.type == '灾害').map((e) => e.id).toList();
final List<String> kTypeList = <String>['元素', '矿物', '资源', '灾害', '材料', '植物', '动物', '文明', '工具', '建筑', '地形', '天文', '科技', '食物', '神话'];
