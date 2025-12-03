import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shilaf/features/profile/data/models/user_model.dart';
import 'package:shilaf/features/profile/providers/user_provider.dart';

/// プロフィール編集画面のラッパー
/// ルーターから呼ばれる際に使用
class ProfileEditPageWrapper extends ConsumerWidget {
  const ProfileEditPageWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(currentUserDataProvider);

    return userDataAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: Text('ユーザー情報が見つかりません'),
            ),
          );
        }
        return ProfileEditPage(user: user);
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Text('エラー: $err'),
        ),
      ),
    );
  }
}

/// プロフィール編集画面
class ProfileEditPage extends ConsumerStatefulWidget {
  final UserModel user;

  const ProfileEditPage({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  late final TextEditingController _weeklyDrinkingCostController;
  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  @override
  void initState() {
    super.initState();
    // 初期値を設定
    _usernameController = TextEditingController(text: widget.user.username);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _weeklyDrinkingCostController = TextEditingController(
      text: widget.user.weeklyDrinkingCost?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _weeklyDrinkingCostController.dispose();
    super.dispose();
  }

  /// 保存処理
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final username = _usernameController.text.trim();
      final bio = _bioController.text.trim();
      final weeklyDrinkingCostText = _weeklyDrinkingCostController.text.trim();

      // ユーザー名が変更されている場合は重複チェック
      if (username != widget.user.username) {
        final isAvailable = await ref
            .read(userNotifierProvider.notifier)
            .checkUsernameAvailability(username);

        if (!isAvailable && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('このユーザー名は既に使用されています'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // アバター画像が選択されている場合はアップロード
      if (_selectedImage != null) {
        await ref
            .read(userNotifierProvider.notifier)
            .updateAvatar(_selectedImage!);
      } else if (_selectedImageBytes != null && _selectedImageName != null) {
        await ref.read(userNotifierProvider.notifier).updateAvatarFromBytes(
              _selectedImageBytes!,
              _selectedImageName!,
            );
      }

      // プロフィールを更新
      await ref.read(userNotifierProvider.notifier).updateUser(
            username: username,
            bio: bio.isEmpty ? null : bio,
            weeklyDrinkingCost: weeklyDrinkingCostText.isEmpty
                ? null
                : int.tryParse(weeklyDrinkingCostText),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('プロフィールを更新しました'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 画像を選択する
  Future<void> _pickImage({bool useCamera = false}) async {
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
          setState(() {
            _selectedImageBytes = bytes;
            _selectedImageName = pickedFile.name;
            _selectedImage = null;
          });
        } else {
          // モバイルの場合はFileとして扱う
          setState(() {
            _selectedImage = File(pickedFile.path);
            _selectedImageBytes = null;
            _selectedImageName = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('画像の選択に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 画像選択ダイアログを表示
  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('アバター画像を選択'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('ギャラリーから選択'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(useCamera: false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('カメラで撮影'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(useCamera: true);
                },
              ),
              if (_selectedImage != null || _selectedImageBytes != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title:
                      const Text('画像を削除', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _selectedImage = null;
                      _selectedImageBytes = null;
                      _selectedImageName = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// アバター画像を表示するWidget
  Widget _buildAvatarImage() {
    if (_selectedImage != null) {
      // 新しく選択された画像（モバイル）
      return CircleAvatar(
        radius: 50,
        backgroundImage: FileImage(_selectedImage!),
      );
    } else if (_selectedImageBytes != null) {
      // 新しく選択された画像（Web）
      return CircleAvatar(
        radius: 50,
        backgroundImage: MemoryImage(_selectedImageBytes!),
      );
    } else if (widget.user.avatarUrl != null) {
      // 既存のアバターURL
      return CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(widget.user.avatarUrl!),
      );
    } else {
      // デフォルトアイコン
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[300],
        child: const Icon(
          Icons.person,
          size: 50,
          color: Colors.grey,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール編集'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                '保存',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // プロフィール画像
            Center(
              child: Stack(
                children: [
                  _buildAvatarImage(),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _showImagePickerDialog,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ユーザー名
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'ユーザー名',
                hintText: 'ユーザー名を入力',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'ユーザー名を入力してください';
                }
                if (value.trim().length < 2) {
                  return 'ユーザー名は2文字以上で入力してください';
                }
                if (value.trim().length > 20) {
                  return 'ユーザー名は20文字以内で入力してください';
                }
                return null;
              },
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // 自己紹介
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: '自己紹介',
                hintText: '自己紹介を入力（任意）',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              maxLength: 200,
              validator: (value) {
                if (value != null && value.trim().length > 200) {
                  return '自己紹介は200文字以内で入力してください';
                }
                return null;
              },
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // 週あたりの飲酒コスト
            TextFormField(
              controller: _weeklyDrinkingCostController,
              decoration: const InputDecoration(
                labelText: '週あたりの飲酒コスト',
                hintText: '金額を入力（任意）',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_yen_rounded),
                suffixText: '円/週',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  final cost = int.tryParse(value.trim());
                  if (cost == null) {
                    return '数値を入力してください';
                  }
                  if (cost < 0) {
                    return '0以上の値を入力してください';
                  }
                  if (cost > 1000000) {
                    return '100万円以下で入力してください';
                  }
                }
                return null;
              },
              enabled: !_isLoading,
            ),
            const SizedBox(height: 24),

            // 説明テキスト
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '週あたりの飲酒コストについて',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '断酒を続けることで節約できる金額の目安として使用されます。空欄の場合は計算に含まれません。',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
