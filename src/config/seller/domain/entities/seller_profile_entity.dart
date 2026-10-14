class SellerProfileEntity {
  final String id;
  final String userId;
  final String displayName;
  final String sellerType;
  final String availabilityStatus;
  final String approvalStatus;
  final String fssaiStatus;
  final bool fssaiRequired;
  final String renewalStatus;
  final int totalListings;
  final double averageRating;
  final int rejectedOrders;
  final int cancelledOrders;
  final int totalOrders;
  final int totalReviews;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pinCode;
  final String createdAt;
  final String updatedAt;
  final String? societyId;
  final String? businessName;
  final String? bio;
  final String? fssaiCertificateId;
  final String? socialMediaLinks;
  final String? websiteUrl;
  final String? legalCompliance;
  final double? latitude;
  final double? longitude;
  final String? geofencePolygon;
  final double? deliveryRadiusKm;
  final String? targetArea;

  const SellerProfileEntity({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.sellerType,
    required this.availabilityStatus,
    required this.approvalStatus,
    required this.fssaiStatus,
    required this.fssaiRequired,
    required this.renewalStatus,
    required this.totalListings,
    required this.averageRating,
    required this.rejectedOrders,
    required this.cancelledOrders,
    required this.totalOrders,
    required this.totalReviews,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pinCode,
    required this.createdAt,
    required this.updatedAt,
    this.societyId,
    this.businessName,
    this.bio,
    this.fssaiCertificateId,
    this.socialMediaLinks,
    this.websiteUrl,
    this.legalCompliance,
    this.latitude,
    this.longitude,
    this.geofencePolygon,
    this.deliveryRadiusKm,
    this.targetArea,
  });

  SellerProfileEntity copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? sellerType,
    String? availabilityStatus,
    String? approvalStatus,
    String? fssaiStatus,
    bool? fssaiRequired,
    String? renewalStatus,
    int? totalListings,
    double? averageRating,
    int? rejectedOrders,
    int? cancelledOrders,
    int? totalOrders,
    int? totalReviews,
    String? address,
    String? city,
    String? state,
    String? country,
    String? pinCode,
    String? createdAt,
    String? updatedAt,
    String? societyId,
    String? businessName,
    String? bio,
    String? fssaiCertificateId,
    String? socialMediaLinks,
    String? websiteUrl,
    String? legalCompliance,
    double? latitude,
    double? longitude,
    String? geofencePolygon,
    double? deliveryRadiusKm,
    String? targetArea,
  }) {
    return SellerProfileEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      sellerType: sellerType ?? this.sellerType,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      fssaiStatus: fssaiStatus ?? this.fssaiStatus,
      fssaiRequired: fssaiRequired ?? this.fssaiRequired,
      renewalStatus: renewalStatus ?? this.renewalStatus,
      totalListings: totalListings ?? this.totalListings,
      averageRating: averageRating ?? this.averageRating,
      rejectedOrders: rejectedOrders ?? this.rejectedOrders,
      cancelledOrders: cancelledOrders ?? this.cancelledOrders,
      totalOrders: totalOrders ?? this.totalOrders,
      totalReviews: totalReviews ?? this.totalReviews,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      pinCode: pinCode ?? this.pinCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      societyId: societyId ?? this.societyId,
      businessName: businessName ?? this.businessName,
      bio: bio ?? this.bio,
      fssaiCertificateId: fssaiCertificateId ?? this.fssaiCertificateId,
      socialMediaLinks: socialMediaLinks ?? this.socialMediaLinks,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      legalCompliance: legalCompliance ?? this.legalCompliance,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geofencePolygon: geofencePolygon ?? this.geofencePolygon,
      deliveryRadiusKm: deliveryRadiusKm ?? this.deliveryRadiusKm,
      targetArea: targetArea ?? this.targetArea,
    );
  }
}
