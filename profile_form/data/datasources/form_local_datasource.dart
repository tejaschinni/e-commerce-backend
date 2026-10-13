import 'dart:io';

import 'package:riverpoddemo/features/profile_form/data/models/form_model.dart';
import 'package:riverpoddemo/features/profile_form/data/models/user_image_model.dart';

/// Local, in-memory stand-in for a real backend. Every call simulates
/// network latency via [Future.delayed] so the presentation layer behaves
/// exactly as it would against a real API.
///
/// Storage is held in process memory only - data resets on app restart.
class FormLocalDataSource {
  final Map<String, FormModel> _draftsByUserId = {};
  final Map<String, FormModel> _submittedById = {};
  final Map<String, UserImageModel> _imagesByUserId = {};

  static const _latency = Duration(milliseconds: 600);
  int _idCounter = 0;

  String _nextId(String prefix) => '${prefix}_${++_idCounter}';

  Future<FormModel?> getDetails(String userId) async {
    await Future.delayed(_latency);
    return _draftsByUserId[userId];
  }

  Future<FormModel> saveDraft(FormModel data) async {
    await Future.delayed(_latency);
    final saved = data.id.isEmpty ? data.copyWith(id: _nextId('form')) : data;
    _draftsByUserId[saved.userId] = saved;
    return saved;
  }

  Future<void> submitForm(String formId) async {
    await Future.delayed(_latency);
    final draft = _draftsByUserId.values.firstWhere(
      (form) => form.id == formId,
      orElse: () => throw StateError('No draft found for formId $formId'),
    );
    _submittedById[formId] = draft;
  }

  Future<UserImageModel> uploadImage(File file, String userId) async {
    await Future.delayed(_latency);
    final uploaded = UserImageModel(
      imageId: _nextId('image'),
      userId: userId,
      remoteUrl: 'https://mock-cdn.local/uploads/${file.uri.pathSegments.last}',
    );
    _imagesByUserId[userId] = uploaded;
    return uploaded;
  }

  Future<UserImageModel?> getUploadedImage(String userId) async {
    await Future.delayed(_latency);
    return _imagesByUserId[userId];
  }
}
