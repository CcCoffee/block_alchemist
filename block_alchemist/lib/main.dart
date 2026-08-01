import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/storage/game_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/i18n/app_localizations.dart';

/// 方块炼金师应用入口
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化本地存档（SharedPreferences）
  await GameStorage.instance.init();

  runApp(const ProviderScope(child: AlchemistApp()));
}

/// 方块炼金师顶层应用
class AlchemistApp extends ConsumerWidget {
  const AlchemistApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: '方块炼金师',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
