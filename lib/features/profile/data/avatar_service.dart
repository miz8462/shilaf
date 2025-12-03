import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 画像選択結果を格納するクラス
/// Webとモバイルの両方に対応
class ImagePickerResult {
  final File? file;
  final Uint8List? bytes;
  final String fileName;

  ImagePickerResult({
    this.file,
    this.bytes,
    required this.fileName,
  });

  bool get isWeb => bytes != null;
  bool get isMobile => file != null;
}

/// アバター画像のアップロード・管理を行うサービス
class AvatarService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  /// 現在ログイン中のユーザーIDを取得
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// 画像を選択する（カメラまたはギャラリーから）
  Future<ImagePickerResult?> pickImage({bool useCamera = false}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: useCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // Webの場合はバイト配列として読み込む
          final bytes = await pickedFile.readAsBytes();
          return ImagePickerResult(
            bytes: bytes,
            fileName: pickedFile.name,
          );
        } else {
          // モバイルの場合はFileとして扱う
          return ImagePickerResult(
            file: File(pickedFile.path),
            fileName: pickedFile.name,
          );
        }
      }
      return null;
    } catch (e) {
      throw Exception('画像の選択に失敗しました: $e');
    }
  }

  /// アバター画像をアップロードする（Webとモバイル共通）
  Future<String> uploadAvatar(ImagePickerResult result) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // 画像のバリデーション
      if (!isValidImageResult(result)) {
        throw Exception('無効な画像ファイルです。2MB以下のJPEG、PNG、GIF、WebP形式の画像を選択してください。');
      }

      // ファイル名を生成（ユーザーID + タイムスタンプ + 拡張子）
      final fileExtension = result.fileName.split('.').last.toLowerCase();
      final fileName =
          '$userId/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      if (result.isWeb) {
        // Web用アップロード
        await _supabase.storage.from('avatars').uploadBinary(
              fileName,
              result.bytes!,
              fileOptions: FileOptions(
                contentType: _getContentType(fileExtension),
                upsert: true,
              ),
            );
      } else {
        // モバイル用アップロード
        final fileBytes = await result.file!.readAsBytes();
        await _supabase.storage.from('avatars').uploadBinary(
              fileName,
              fileBytes,
              fileOptions: FileOptions(
                contentType: _getContentType(fileExtension),
                upsert: true,
              ),
            );
      }

      // 公開URLを取得
      final publicUrl =
          _supabase.storage.from('avatars').getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      throw Exception('画像のアップロードに失敗しました: $e');
    }
  }

  /// 既存のアバターを削除する
  Future<void> deleteAvatar(String avatarUrl) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // URLからファイルパスを抽出
      final uri = Uri.parse(avatarUrl);
      final pathSegments = uri.pathSegments;

      // avatars/bucket/userId/filename 形式を想定
      if (pathSegments.length >= 3 && pathSegments[0] == 'avatars') {
        final fileName = pathSegments.sublist(2).join('/');

        await _supabase.storage.from('avatars').remove([fileName]);
      }
    } catch (e) {
      // 削除に失敗しても続行（古い画像が残る可能性あり）
      debugPrint('Failed to delete old avatar: $e');
    }
  }

  /// MIMEタイプを取得
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// 画像のバリデーション
  bool isValidImageResult(ImagePickerResult result) {
    final fileExtension = result.fileName.split('.').last.toLowerCase();

    // 拡張子チェック
    const validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    if (!validExtensions.contains(fileExtension)) {
      return false;
    }

    // ファイルサイズチェック（2MB以下）
    if (result.isWeb) {
      return result.bytes!.length <= 2 * 1024 * 1024;
    } else {
      return result.file!.lengthSync() <= 2 * 1024 * 1024;
    }
  }
}
