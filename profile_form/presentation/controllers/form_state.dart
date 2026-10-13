import 'dart:io';

import 'package:riverpoddemo/features/profile_form/domain/entities/form_entity.dart';

/// Sentinel used by [ProfileFormState.copyWith] so callers can explicitly
/// reset a nullable field to `null` instead of leaving it unchanged.
const Object _unset = Object();

/// Everything the profile form screen needs to render: field values, the
/// image (local and/or remote), and the in-flight/validation flags that
/// drive button and spinner states.
class ProfileFormState {
  const ProfileFormState({
    required this.userId,
    this.formId = '',
    this.fullName = '',
    this.email = '',
    this.phoneNumber = '',
    this.bio = '',
    this.localImageFile,
    this.remoteImageUrl,
    this.isDraftSaved = false,
    this.isSavingDraft = false,
    this.isUploadingImage = false,
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.errorMessage,
  });

  factory ProfileFormState.fromEntity(FormEntity entity, {String? remoteImageUrl}) {
    return ProfileFormState(
      userId: entity.userId,
      formId: entity.id,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      bio: entity.bio,
      remoteImageUrl: remoteImageUrl,
      // An existing, previously persisted form counts as "saved" until the
      // user changes something.
      isDraftSaved: !entity.isNew,
    );
  }

  final String userId;
  final String formId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String bio;

  /// Freshly picked image awaiting upload/preview. Takes priority over
  /// [remoteImageUrl] in the UI once set.
  final File? localImageFile;

  /// URL of the image already stored on the backend, if any.
  final String? remoteImageUrl;

  /// False whenever a saved draft is stale with respect to current field
  /// values (new form, or edited after the last save).
  final bool isDraftSaved;

  final bool isSavingDraft;
  final bool isUploadingImage;
  final bool isSubmitting;
  final bool isSubmitted;
  final String? errorMessage;

  bool get isBusy => isSavingDraft || isUploadingImage || isSubmitting;

  FormEntity toEntity() => FormEntity(
        id: formId,
        userId: userId,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        bio: bio,
      );

  ProfileFormState copyWith({
    String? formId,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? bio,
    Object? localImageFile = _unset,
    Object? remoteImageUrl = _unset,
    bool? isDraftSaved,
    bool? isSavingDraft,
    bool? isUploadingImage,
    bool? isSubmitting,
    bool? isSubmitted,
    Object? errorMessage = _unset,
  }) {
    return ProfileFormState(
      userId: userId,
      formId: formId ?? this.formId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      localImageFile:
          identical(localImageFile, _unset) ? this.localImageFile : localImageFile as File?,
      remoteImageUrl:
          identical(remoteImageUrl, _unset) ? this.remoteImageUrl : remoteImageUrl as String?,
      isDraftSaved: isDraftSaved ?? this.isDraftSaved,
      isSavingDraft: isSavingDraft ?? this.isSavingDraft,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
    );
  }
}
