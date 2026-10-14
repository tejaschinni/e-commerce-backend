class SellerImageEntity {
  final String id;
  final String sellerId;
  final String imageUrl;
  final String moderationStatus;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SellerImageEntity({
    required this.id,
    required this.sellerId,
    required this.imageUrl,
    required this.moderationStatus,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
  });
}
