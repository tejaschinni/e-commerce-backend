import 'package:riverpoddemo/features/profile_form/domain/entities/user_image_entity.dart';

/// Wire format for [UserImageEntity].
class UserImageModel {
  const UserImageModel({
    required this.imageId,
    required this.userId,
    required this.remoteUrl,
  });

  factory UserImageModel.fromJson(Map<String, dynamic> json) {
    return UserImageModel(
      imageId: json['imageId'] as String,
      userId: json['userId'] as String,
      remoteUrl: json['remoteUrl'] as String,
    );
  }

  factory UserImageModel.fromEntity(UserImageEntity entity) {
    return UserImageModel(
      imageId: entity.imageId,
      userId: entity.userId,
      remoteUrl: entity.remoteUrl,
    );
  }

  final String imageId;
  final String userId;
  final String remoteUrl;

  Map<String, dynamic> toJson() => {
        'imageId': imageId,
        'userId': userId,
        'remoteUrl': remoteUrl,
      };

  UserImageEntity toEntity() => UserImageEntity(
        imageId: imageId,
        userId: userId,
        remoteUrl: remoteUrl,
      );
}
