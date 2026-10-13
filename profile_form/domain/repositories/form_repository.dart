import 'dart:io';

import 'package:riverpoddemo/features/profile_form/domain/entities/form_entity.dart';
import 'package:riverpoddemo/features/profile_form/domain/entities/user_image_entity.dart';

/// Contract the presentation layer depends on. The data layer provides the
/// concrete (currently mocked) implementation.
abstract class FormRepository {
  /// Returns the existing form for [userId], or `null` if the user has never
  /// saved one.
  Future<FormEntity?> getDetails(String userId);

  /// Persists [data] as a draft and returns the saved entity (with a server
  /// assigned [FormEntity.id] when it was previously new).
  Future<FormEntity> saveDraft(FormEntity data);

  /// Finalizes the form identified by [formId].
  Future<void> submitForm(String formId);

  /// Uploads [file] for [userId] and returns the resulting remote reference.
  Future<UserImageEntity> uploadImage(File file, String userId);

  /// Returns the previously uploaded image for [userId], or `null` if none
  /// exists yet.
  Future<UserImageEntity?> getUploadedImage(String userId);
}
