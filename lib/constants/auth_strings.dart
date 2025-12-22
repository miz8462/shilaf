class AuthStrings {
  // ===== ページタイトル・説明 =====
  static const String loginPageTitle = 'ログイン';
  static const String signupPageTitle = '新規登録';
  static const String signupTitle = 'アカウント作成';
  static const String signupDescription = 'Shilafで断酒の旅を始めましょう';
  static const String loginDescription = 'ソバーキュリアスSNS';

  // ===== バリデーション設定 =====
  static const int passwordMinLength = 8;

  // ===== ラベル =====
  static const String emailLabel = 'メールアドレス';
  static const String passwordLabel = 'パスワード';
  static const String confirmPasswordLabel = 'パスワード（確認）';

  // ===== ヒント =====
  static const String emailHint = 'example@email.com';
  static const String passwordHint = '8文字以上';
  static const String confirmPasswordHint = '同じパスワードを入力';

  // ===== バリデーションエラー =====
  static const String emailRequired = 'メールアドレスを入力してください';
  static const String emailInvalid = '有効なメールアドレスを入力してください';
  static const String passwordRequired = 'パスワードを入力してください';
  static const String passwordTooShort = 'パスワードは8文字以上で入力してください';
  static const String confirmPasswordRequired = 'パスワード（確認）を入力してください';
  static const String passwordMismatch = 'パスワードが一致しません';

  // ===== ボタン =====
  static const String signupButton = '登録する';
  static const String loginButton = 'ログイン';
  static const String googleSignupButton = 'Googleで登録';
  static const String googleLoginButton = 'Googleでログイン';

  // ===== エラーメッセージ =====
  static const String signupError = '登録エラー';
  static const String loginError = 'ログインエラー';
  static const String googleSignupError = 'Google登録エラー';
  static const String googleLoginError = 'Googleログインエラー';

  // ===== 成功メッセージ =====
  static const String signupSuccess = '登録完了！確認メールをご確認ください。';

  // ===== その他 =====
  static const String dividerOr = 'または';
  static const String alreadyHaveAccount = 'すでにアカウントをお持ちの方は';
  static const String noAccount = 'アカウントをお持ちでない方は';
  static const String newRegistration = '新規登録';
}
