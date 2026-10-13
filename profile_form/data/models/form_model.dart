import 'package:riverpoddemo/features/profile_form/domain/entities/form_entity.dart';

/// Wire format for [FormEntity]. Keeps (de)serialization concerns out of the
/// domain layer.
class FormModel {
  const FormModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.bio,
  });

  factory FormModel.fromJson(Map<String, dynamic> json) {
    return FormModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      bio: json['bio'] as String,
    );
  }

  factory FormModel.fromEntity(FormEntity entity) {
    return FormModel(
      id: entity.id,
      userId: entity.userId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      bio: entity.bio,
    );
  }

  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String bio;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'bio': bio,
      };

  FormEntity toEntity() => FormEntity(
        id: id,
        userId: userId,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        bio: bio,
      );

  FormModel copyWith({String? id}) => FormModel(
        id: id ?? this.id,
        userId: userId,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        bio: bio,
      );
}
