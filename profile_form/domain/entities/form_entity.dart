/// Pure domain representation of the profile form, independent of any
/// transport or persistence format.
class FormEntity {
  const FormEntity({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.bio,
  });

  /// Empty, unsaved form for a given user. [id] is assigned by the backend
  /// on the first successful [FormEntity] save.
  factory FormEntity.empty(String userId) => FormEntity(
        id: '',
        userId: userId,
        fullName: '',
        email: '',
        phoneNumber: '',
        bio: '',
      );

  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String bio;

  bool get isNew => id.isEmpty;

  FormEntity copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? bio,
  }) {
    return FormEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
    );
  }
}
