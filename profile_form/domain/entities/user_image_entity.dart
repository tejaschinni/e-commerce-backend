/// Pure domain representation of an uploaded profile image.
class UserImageEntity {
  const UserImageEntity({
    required this.imageId,
    required this.userId,
    required this.remoteUrl,
  });

  final String imageId;
  final String userId;
  final String remoteUrl;

  UserImageEntity copyWith({
    String? imageId,
    String? userId,
    String? remoteUrl,
  }) {
    return UserImageEntity(
      imageId: imageId ?? this.imageId,
      userId: userId ?? this.userId,
      remoteUrl: remoteUrl ?? this.remoteUrl,
    );
  }
}
