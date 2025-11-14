import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// 画面のインポート
import 'package:shilaf/features/auth/presentation/pages/login_page.dart';
import 'package:shilaf/features/auth/presentation/pages/signup_page.dart';
// 認証プロバイダーのインポート
import 'package:shilaf/features/auth/providers/auth_provider.dart';
import 'package:shilaf/features/home/presentation/pages/home_page.dart';
import 'package:shilaf/features/profile/presentation/pages/onboarding_page.dart';
// ユーザープロバイダーのインポート（追加）
import 'package:shilaf/features/profile/providers/user_provider.dart';

/// ルーターのプロバイダー
/// アプリ全体のルーティングを管理する
final routerProvider = Provider<GoRouter>((ref) {
  // 認証状態を監視
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    // 初期表示する画面のパス
    initialLocation: '/login',

    // デバッグモード（開発中はtrueにすると遷移ログが見れる）
    debugLogDiagnostics: true,

    // リダイレクト処理（認証チェック + 初期設定チェック）
    // 画面遷移のたびに呼ばれる
    redirect: (BuildContext context, GoRouterState state) async {
      // 認証状態を取得
      final isAuthenticated = authState.asData?.value.session != null;

      // 初期設定完了状態を取得
      final hasCompletedOnboarding = isAuthenticated
          ? await ref.read(hasCompletedOnboardingProvider.future)
          : false;

      // 現在アクセスしようとしているパス
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToSignup = state.matchedLocation == '/signup';
      final isGoingToOnboarding = state.matchedLocation == '/onboarding';

      // 【優先順位1】未認証なのに認証が必要な画面にアクセスしようとした場合
      if (!isAuthenticated && !isGoingToLogin && !isGoingToSignup) {
        return '/login'; // ログイン画面にリダイレクト
      }

      // 【優先順位2】認証済みだが初期設定未完了
      if (isAuthenticated && !hasCompletedOnboarding && !isGoingToOnboarding) {
        return '/onboarding'; // 初期設定画面にリダイレクト
      }

      // 【優先順位3】認証済み & 初期設定完了なのにログイン画面にアクセス
      if (isAuthenticated &&
          hasCompletedOnboarding &&
          (isGoingToLogin || isGoingToSignup || isGoingToOnboarding)) {
        return '/home'; // ホーム画面にリダイレクト
      }

      // 【優先順位4】問題なし（リダイレクト不要）
      return null;
    },

    // ルート定義（画面とURLの紐付け）
    routes: [
      // ========================
      // 認証関連の画面（未認証でもアクセス可能）
      // ========================

      /// ログイン画面
      /// パス: /login
      GoRoute(
        path: '/login',
        name: 'login', // 名前をつけると context.goNamed('login') で遷移できる
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),

      /// サインアップ画面
      /// パス: /signup
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (BuildContext context, GoRouterState state) {
          return const SignupPage();
        },
      ),

      // ========================
      // 認証後の画面（認証必須）
      // ========================

      /// 初期設定画面
      /// パス: /onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (BuildContext context, GoRouterState state) {
          return const OnboardingPage();
        },
      ),

      /// ホーム画面
      /// パス: /home
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (BuildContext context, GoRouterState state) {
          return const HomePage();
        },
      ),

      // ========================
      // Phase 3以降で追加予定
      // ========================
      // GoRoute(
      //   path: '/profile',
      //   name: 'profile',
      //   builder: (context, state) => const ProfilePage(),
      // ),
      //
      // GoRoute(
      //   path: '/streaks',
      //   name: 'streaks',
      //   builder: (context, state) => const StreaksPage(),
      // ),
    ],

    // エラー画面（存在しないパスにアクセスした場合）
    errorBuilder: (BuildContext context, GoRouterState state) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                '404: ページが見つかりません',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('パス: ${state.matchedLocation}'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('ログイン画面に戻る'),
              ),
            ],
          ),
        ),
      );
    },
  );
});
