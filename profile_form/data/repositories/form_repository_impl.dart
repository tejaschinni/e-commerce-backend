import 'dart:io';

import 'package:riverpoddemo/features/profile_form/data/datasources/form_local_datasource.dart';
import 'package:riverpoddemo/features/profile_form/data/models/form_model.dart';
import 'package:riverpoddemo/features/profile_form/domain/entities/form_entity.dart';
import 'package:riverpoddemo/features/profile_form/domain/entities/user_image_entity.dart';
import 'package:riverpoddemo/features/profile_form/domain/repositories/form_repository.dart';

/// Translates between domain [FormEntity]/[UserImageEntity] and the data
/// layer's models, delegating actual (mocked) I/O to [FormLocalDataSource].
class FormRepositoryImpl implements FormRepository {
  FormRepositoryImpl(this._dataSource);

  final FormLocalDataSource _dataSource;

  @override
  Future<FormEntity?> getDetails(String userId) async {
    final model = await _dataSource.getDetails(userId);
    return model?.toEntity();
  }

  @override
  Future<FormEntity> saveDraft(FormEntity data) async {
    final saved = await _dataSource.saveDraft(FormModel.fromEntity(data));
    return saved.toEntity();
  }

  @override
  Future<void> submitForm(String formId) {
    return _dataSource.submitForm(formId);
  }

  @override
  Future<UserImageEntity> uploadImage(File file, String userId) async {
    final uploaded = await _dataSource.uploadImage(file, userId);
    return uploaded.toEntity();
  }

  @override
  Future<UserImageEntity?> getUploadedImage(String userId) async {
    final model = await _dataSource.getUploadedImage(userId);
    return model?.toEntity();
  }
}
