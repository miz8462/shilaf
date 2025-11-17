import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shilaf/core/constants/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ルーターのインポート
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .envファイルを読み込み
  await dotenv.load(fileName: '.env');

  // Supabase初期化
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// StatelessWidget → ConsumerWidgetに変更（Riverpodでルーターを取得するため）
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ルーターを取得
    final router = ref.watch(routerProvider);

    // MaterialApp → MaterialApp.routerに変更
    return MaterialApp.router(
      // ルーターの設定
      routerConfig: router,

      // アプリ設定
      title: 'Shilaf',
      theme: AppTheme.lightTheme,

      // アプリ全体に最大幅を設定
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },

      // debugShowCheckedModeBannerを非表示（お好みで）
      debugShowCheckedModeBanner: false,

      // ローカライズ
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ja'),
      ],
    );
  }
}
