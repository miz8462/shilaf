import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
        // アプリ版: 今は未実装（Phase 3で対応）
        throw UnimplementedError(
            'Google Sign In for mobile is not implemented yet');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Web版のGoogle認証
  Future<bool> _signInWithGoogleWeb() async {
    final result = await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb
          ? Uri.base.origin // 現在のURLを自動取得
          : 'http://localhost:3000/auth/callback',
    );
    return result;
  }

  /// アプリ版のGoogle認証
  Future<AuthResponse> signInWithGoogleNative() async {
    // Google Sign Inのインスタンス取得
    final googleSignIn = GoogleSignIn(
      clientId: dotenv.env['GOOGLE_IOS_CLIENT_ID'], // iOS用
      serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'], // Web用
    );

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
