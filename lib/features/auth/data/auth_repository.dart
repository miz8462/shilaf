import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Web専用のURL取得関数（条件付きインポート）
String _getCurrentUrl() {
  if (kIsWeb) {
    // ignore: avoid_web_libraries_in_flutter
    // ignore: deprecated_member_use
    return Uri.base.toString().split('#')[0];
  }
  throw UnsupportedError('This function is only available on web');
}

/// 認証処理を担当するリポジトリ
class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 現在ログイン中のユーザーを取得
  User? get currentUser => _supabase.auth.currentUser;

  /// 認証状態の変化を監視するStream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// メールアドレスとパスワードでサインアップ
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// メールアドレスとパスワードでサインイン
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Googleアカウントでサインイン（Web/App対応）
  Future<void> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web版: リダイレクトベース認証（リダイレクトするだけ）
        await _signInWithGoogleWeb();
        // リダイレクト後に戻ってきたら自動的に認証済み
      } else {
        // モバイル版: ネイティブGoogle Sign-Inを使用
        await signInWithGoogleNative();
      }
    } on AuthException catch (e) {
      // Supabaseの認証エラーを詳細に処理
      if (e.message.contains('provider is not enabled')) {
        throw Exception(
            'Google認証が有効になっていません。SupabaseダッシュボードでGoogleプロバイダーを有効にしてください。');
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Web版のGoogle認証
  Future<bool> _signInWithGoogleWeb() async {
    // 現在のURLを取得してリダイレクト先に設定
    // Supabaseは自動的に現在のURLを推測するが、明示的に指定する
    final baseUrl = _getCurrentUrl();

    final result = await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: baseUrl,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
    return result;
  }

  /// アプリ版のGoogle認証
  Future<AuthResponse> signInWithGoogleNative() async {
    // プラットフォーム別のGoogle Sign-In設定
    GoogleSignIn googleSignIn;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // iOS用設定
      googleSignIn = GoogleSignIn(
        clientId: dotenv.env['GOOGLE_IOS_CLIENT_ID'],
        serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
        scopes: ['email', 'profile'],
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // Android用設定（serverClientIdのみ必要）
      googleSignIn = GoogleSignIn(
        serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
        scopes: ['email', 'profile'],
      );
    } else {
      throw UnsupportedError(
          'Google Sign-In is not supported on this platform');
    }

    // Googleアカウント選択
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign in aborted');
    }

    // 認証情報取得
    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null || idToken == null) {
      throw Exception('Missing Google Auth Token');
    }

    // Supabaseにサインイン
    final response = await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    return response;
  }

  /// サインアウト
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// パスワードリセットメール送信
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }
}
