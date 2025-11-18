// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timeline_post_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TimelinePost _$TimelinePostFromJson(Map<String, dynamic> json) {
  return _TimelinePost.fromJson(json);
}

/// @nodoc
mixin _$TimelinePost {
  String get id => throw _privateConstructorUsedError; // posts.id
  String get userId => throw _privateConstructorUsedError; // posts.user_id
  String? get userName =>
      throw _privateConstructorUsedError; // JOINしたユーザー名（users.name）
  String get content => throw _privateConstructorUsedError; // posts.content
  DateTime? get createdAt =>
      throw _privateConstructorUsedError; // posts.created_at
  String? get imageUrl => throw _privateConstructorUsedError;

  /// Serializes this TimelinePost to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimelinePost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimelinePostCopyWith<TimelinePost> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimelinePostCopyWith<$Res> {
  factory $TimelinePostCopyWith(
          TimelinePost value, $Res Function(TimelinePost) then) =
      _$TimelinePostCopyWithImpl<$Res, TimelinePost>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String? userName,
      String content,
      DateTime? createdAt,
      String? imageUrl});
}

/// @nodoc
class _$TimelinePostCopyWithImpl<$Res, $Val extends TimelinePost>
    implements $TimelinePostCopyWith<$Res> {
  _$TimelinePostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimelinePost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? userName = freezed,
    Object? content = null,
    Object? createdAt = freezed,
    Object? imageUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimelinePostImplCopyWith<$Res>
    implements $TimelinePostCopyWith<$Res> {
  factory _$$TimelinePostImplCopyWith(
          _$TimelinePostImpl value, $Res Function(_$TimelinePostImpl) then) =
      __$$TimelinePostImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String? userName,
      String content,
      DateTime? createdAt,
      String? imageUrl});
}

/// @nodoc
class __$$TimelinePostImplCopyWithImpl<$Res>
    extends _$TimelinePostCopyWithImpl<$Res, _$TimelinePostImpl>
    implements _$$TimelinePostImplCopyWith<$Res> {
  __$$TimelinePostImplCopyWithImpl(
      _$TimelinePostImpl _value, $Res Function(_$TimelinePostImpl) _then)
      : super(_value, _then);

  /// Create a copy of TimelinePost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? userName = freezed,
    Object? content = null,
    Object? createdAt = freezed,
    Object? imageUrl = freezed,
  }) {
    return _then(_$TimelinePostImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimelinePostImpl implements _TimelinePost {
  const _$TimelinePostImpl(
      {required this.id,
      required this.userId,
      this.userName,
      required this.content,
      this.createdAt,
      this.imageUrl});

  factory _$TimelinePostImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimelinePostImplFromJson(json);

  @override
  final String id;
// posts.id
  @override
  final String userId;
// posts.user_id
  @override
  final String? userName;
// JOINしたユーザー名（users.name）
  @override
  final String content;
// posts.content
  @override
  final DateTime? createdAt;
// posts.created_at
  @override
  final String? imageUrl;

  @override
  String toString() {
    return 'TimelinePost(id: $id, userId: $userId, userName: $userName, content: $content, createdAt: $createdAt, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimelinePostImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, userId, userName, content, createdAt, imageUrl);

  /// Create a copy of TimelinePost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimelinePostImplCopyWith<_$TimelinePostImpl> get copyWith =>
      __$$TimelinePostImplCopyWithImpl<_$TimelinePostImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimelinePostImplToJson(
      this,
    );
  }
}

abstract class _TimelinePost implements TimelinePost {
  const factory _TimelinePost(
      {required final String id,
      required final String userId,
      final String? userName,
      required final String content,
      final DateTime? createdAt,
      final String? imageUrl}) = _$TimelinePostImpl;

  factory _TimelinePost.fromJson(Map<String, dynamic> json) =
      _$TimelinePostImpl.fromJson;

  @override
  String get id; // posts.id
  @override
  String get userId; // posts.user_id
  @override
  String? get userName; // JOINしたユーザー名（users.name）
  @override
  String get content; // posts.content
  @override
  DateTime? get createdAt; // posts.created_at
  @override
  String? get imageUrl;

  /// Create a copy of TimelinePost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimelinePostImplCopyWith<_$TimelinePostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
