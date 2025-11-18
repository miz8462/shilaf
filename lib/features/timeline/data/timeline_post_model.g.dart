// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimelinePostImpl _$$TimelinePostImplFromJson(Map<String, dynamic> json) =>
    _$TimelinePostImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String?,
      content: json['content'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$$TimelinePostImplToJson(_$TimelinePostImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'content': instance.content,
      'createdAt': instance.createdAt?.toIso8601String(),
      'imageUrl': instance.imageUrl,
    };
