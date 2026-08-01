#!/usr/bin/env bash
#
# 方块炼金师 - 构建脚本
#
# 用法:
#   ./scripts/build.sh check   依赖解析 + 静态分析 + 测试（快速检查）
#   ./scripts/build.sh apk     构建 Android APK（release）
#   ./scripts/build.sh bundle  构建 Android AppBundle（aab）
#   ./scripts/build.sh ios     构建 iOS（不签名，需 macOS + Xcode）
#   ./scripts/build.sh web     构建 Web 版本
#   ./scripts/build.sh all     依次执行以上所有构建
#
set -euo pipefail

cd "$(dirname "$0")/.."
ROOT="$(pwd)"

log() { printf '\033[1;34m[构建]\033[0m %s\n' "$*"; }
fail() { printf '\033[1;31m[构建失败]\033[0m %s\n' "$*" >&2; exit 1; }

command -v flutter >/dev/null 2>&1 ||
  fail "未找到 flutter，请先安装 Flutter SDK 并加入 PATH"

target="${1:-check}"
case "$target" in
  check | apk | bundle | ios | web | all) ;;
  *)
    echo "未知构建目标: $target"
    echo "可用目标: check | apk | bundle | ios | web | all"
    exit 1
    ;;
esac

log "flutter pub get"
flutter pub get

log "flutter analyze"
flutter analyze

log "flutter test"
flutter test

case "$target" in
  check)
    log "快速检查完成 ✔"
    ;;
  apk)
    log "flutter build apk --release"
    flutter build apk --release
    log "APK 输出: ${ROOT}/build/app/outputs/flutter-apk/app-release.apk"
    ;;
  bundle)
    log "flutter build appbundle --release"
    flutter build appbundle --release
    log "AAB 输出: ${ROOT}/build/app/outputs/bundle/release/app-release.aab"
    ;;
  ios)
    log "flutter build ios --release --no-codesign"
    flutter build ios --release --no-codesign
    log "iOS 构建完成（未签名，请在 Xcode 中配置签名后归档）"
    ;;
  web)
    log "flutter build web --release"
    flutter build web --release
    log "Web 输出: ${ROOT}/build/web"
    ;;
  all)
    log "构建 Android APK"
    flutter build apk --release
    log "构建 Android AppBundle"
    flutter build appbundle --release
    if [[ "$(uname -s)" == "Darwin" ]]; then
      log "构建 iOS（不签名）"
      flutter build ios --release --no-codesign || log "iOS 构建失败，已跳过（请检查 Xcode 环境）"
    else
      log "非 macOS 环境，跳过 iOS 构建"
    fi
    log "构建 Web"
    flutter build web --release
    ;;
esac

log "全部完成 ✔"
