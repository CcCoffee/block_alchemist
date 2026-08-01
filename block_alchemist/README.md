# 方块炼金师 (Block Alchemist)

原创元素合成探索游戏：Little Alchemy 式配方合成 + 模拟经营成长。

> 本项目以 `RedisManager`（Flutter）为脚手架改造而来，沿用其
> `core/`（storage / theme / router / i18n）+ `features/<模块>/`（screen / providers / widgets）的分层架构。

## 玩法

- 初始元素：🔥 火、💧 水、🌍 土、🌬️ 风
- 从材料栏拖出方块放到地图，把一个方块拖到另一个方块上尝试合成
- 共 354 种可发现元素、395 条合成配方（含 Little Alchemy 标准替代配方）：植物、动物、村落、城市、科技、灾害、神话……
- 探索进度推动世界成长：地图从 6×6 扩大到 8×8
- 图鉴、解锁记录、地图与分数自动保存在本地（SharedPreferences）

## 运行

```bash
cd block_alchemist
flutter pub get
flutter run
```

## 测试

```bash
flutter analyze
flutter test
```

## 构建与脚本

```bash
# 快速检查（pub get + analyze + test）
./scripts/build.sh check

# 构建 Android APK / AppBundle
./scripts/build.sh apk
./scripts/build.sh bundle

# 构建 iOS（需 macOS + Xcode，不签名）
./scripts/build.sh ios

# 构建 Web 版本
./scripts/build.sh web

# 依次构建 apk + aab + ios + web
./scripts/build.sh all
```

`scripts/gen_elements.js` 用于同步元素数据：修改仓库根目录的
`data.js`（网页版数据源）后，重新生成 Flutter 版数据文件：

```bash
node scripts/gen_elements.js
```

## 目录结构

```
lib/
├── core/
│   ├── i18n/            # 本地化代理
│   ├── router/          # go_router 路由
│   ├── storage/         # SharedPreferences 存档
│   └── theme/           # 深色主题
├── features/
│   └── alchemist/       # 游戏模块
│       ├── data/        # 354 种元素数据（由 data.js 生成）
│       ├── widgets/     # 图鉴/材料栏/选中面板/帮助
│       ├── alchemist_screen.dart
│       ├── board_painter.dart   # Canvas 棋盘
│       └── game_controller.dart # 游戏状态与逻辑
└── main.dart
scripts/
├── build.sh            # 构建/检查脚本
└── gen_elements.js     # 元素数据生成脚本
```
