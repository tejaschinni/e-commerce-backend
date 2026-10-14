class SellerProfileRequest {
  final String userId;
  final int? societyId; // optional, only if user has joined a society
  final String displayName;
  final String? businessName;
  final String sellerType; // FOOD_SELLER, SERVICE_PROVIDER, PRODUCT_SELLER, CONSULTANT, TRAINER, FREE_HELP_PROVIDER, MIXED
  final String? bio;
  final bool? fssaiRequired;
  final String? fssaiCertificateId;
  final String? socialMediaLinks;
  final String? websiteUrl;
  final String? legalCompliance;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pinCode;
  final double? latitude;
  final double? longitude;
  final String? geofencePolygon;
  final double? deliveryRadiusKm;
  final String? targetArea;

  SellerProfileRequest({
    required this.userId,
    this.societyId,
    required this.displayName,
    this.businessName,
    required this.sellerType,
    this.bio,
    this.fssaiRequired,
    this.fssaiCertificateId,
    this.socialMediaLinks,
    this.websiteUrl,
    this.legalCompliance,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pinCode,
    this.latitude,
    this.longitude,
    this.geofencePolygon,
    this.deliveryRadiusKm,
    this.targetArea,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'userId': userId,
      'societyId': societyId,
      'displayName': displayName,
      'businessName': businessName,
      'sellerType': sellerType,
      'bio': bio,
      'fssaiRequired': fssaiRequired,
      'fssaiCertificateId': fssaiCertificateId,
      'socialMediaLinks': socialMediaLinks,
      'websiteUrl': websiteUrl,
      'legalCompliance': legalCompliance,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pinCode': pinCode,
      'latitude': latitude,
      'longitude': longitude,
      'geofencePolygon': geofencePolygon,
      'deliveryRadiusKm': deliveryRadiusKm,
      'targetArea': targetArea,
    };
    // Drop optional fields that are null so the backend sees them as absent
    map.removeWhere(
      (key, value) => value == null || (value is String && value.trim().isEmpty) || value == "null",
    );
    return map;
  }

  bool get isEmpty {
    bool blank(String? s) => s == null || s.isEmpty;
    return blank(displayName) &&
        blank(businessName) &&
        blank(bio) &&
        blank(sellerType) &&
        blank(address) &&
        blank(city) &&
        blank(state) &&
        blank(country) &&
        blank(pinCode) &&
        latitude == null &&
        longitude == null &&
        blank(fssaiCertificateId) &&
        fssaiRequired == null &&
        blank(legalCompliance) &&
        blank(socialMediaLinks) &&
        blank(websiteUrl) &&
        deliveryRadiusKm == null &&
        blank(targetArea);
  }
}

class SellerProfile {
  final String id;
  final String status; // DRAFT, PENDING, ...
  final String displayName;

  const SellerProfile({required this.id, required this.status, required this.displayName});

  bool get isDraft => status.toUpperCase() == 'DRAFT';
  bool get isPending => status.toUpperCase() == 'PENDING';

  factory SellerProfile.fromJson(Map<String, dynamic> json) => SellerProfile(
    id: json['id'].toString(),
    status: (json['status'] ?? '').toString(),
    displayName: (json['displayName'] ?? '').toString(),
  );
}

class SellerImage {
  final String id;
  final String url;
  const SellerImage({required this.id, required this.url});

  factory SellerImage.fromJson(Map<String, dynamic> json) =>
      SellerImage(id: json['id'].toString(), url: json['url'].toString());
}
