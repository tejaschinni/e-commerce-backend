import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpoddemo/features/profile_form/data/datasources/form_local_datasource.dart';
import 'package:riverpoddemo/features/profile_form/data/repositories/form_repository_impl.dart';
import 'package:riverpoddemo/features/profile_form/domain/entities/form_entity.dart';
import 'package:riverpoddemo/features/profile_form/domain/repositories/form_repository.dart';
import 'package:riverpoddemo/features/profile_form/presentation/controllers/form_state.dart';

// Kept alive for the app's lifetime: there is only ever one mock "backend"
// and we don't want it recreated (losing saved drafts) whenever the form
// screen is disposed.
final formLocalDataSourceProvider = Provider<FormLocalDataSource>((ref) {
  return FormLocalDataSource();
});

final formRepositoryProvider = Provider<FormRepository>((ref) {
  return FormRepositoryImpl(ref.watch(formLocalDataSourceProvider));
});

/// Drives the profile form screen for a given `userId` (the family
/// argument). Exposed as `AsyncValue<ProfileFormState>`: the initial
/// `getDetails` + `getUploadedImage` fetch is the async `build`, and
/// `.autoDispose` means the mock "session" resets if the screen is popped
/// and re-pushed.
final formControllerProvider = AsyncNotifierProvider.autoDispose
    .family<FormController, ProfileFormState, String>(FormController.new);

class FormController extends AutoDisposeFamilyAsyncNotifier<ProfileFormState, String> {
  @override
  FutureOr<ProfileFormState> build(String userId) async {
    final repository = ref.watch(formRepositoryProvider);

    final detailsFuture = repository.getDetails(userId);
    final imageFuture = repository.getUploadedImage(userId);
    final details = await detailsFuture;
    final image = await imageFuture;

    final entity = details ?? FormEntity.empty(userId);
    return ProfileFormState.fromEntity(entity, remoteImageUrl: image?.remoteUrl);
  }

  void updateFullName(String value) => _updateField((s) => s.copyWith(fullName: value));

  void updateEmail(String value) => _updateField((s) => s.copyWith(email: value));

  void updatePhoneNumber(String value) => _updateField((s) => s.copyWith(phoneNumber: value));

  void updateBio(String value) => _updateField((s) => s.copyWith(bio: value));

  void _updateField(ProfileFormState Function(ProfileFormState current) update) {
    final current = state.valueOrNull;
    if (current == null) return;
    // Any edit invalidates the last saved draft.
    state = AsyncData(update(current).copyWith(isDraftSaved: false, errorMessage: null));
  }

  /// Opens the image picker, immediately previews the local file, then
  /// uploads it in the background. Call this directly from the "pick image"
  /// tap handler for pick-time uploads.
  Future<void> pickImage({ImageSource source = ImageSource.gallery}) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final picked = await ImagePicker().pickImage(source: source);
    if (picked == null) return;

    final file = File(picked.path);
    state = AsyncData(
      current.copyWith(localImageFile: file, isDraftSaved: false, errorMessage: null),
    );

    await _uploadImage(file);
  }

  /// Uploads [file] for the current user. Exposed separately from
  /// [pickImage] so callers (e.g. [saveDraft]) can trigger the upload at
  /// save-time instead of immediately after picking, without duplicating
  /// the API call.
  Future<void> _uploadImage(File file) async {
    final beforeUpload = state.valueOrNull;
    if (beforeUpload == null) return;

    state = AsyncData(beforeUpload.copyWith(isUploadingImage: true));
    try {
      final uploaded = await ref.read(formRepositoryProvider).uploadImage(file, beforeUpload.userId);
      final latest = state.valueOrNull ?? beforeUpload;
      state = AsyncData(
        latest.copyWith(isUploadingImage: false, remoteImageUrl: uploaded.remoteUrl),
      );
    } catch (error) {
      final latest = state.valueOrNull ?? beforeUpload;
      state = AsyncData(
        latest.copyWith(isUploadingImage: false, errorMessage: 'Image upload failed: $error'),
      );
    }
  }

  /// Saves the current fields as a draft via `saveDraft`. Used directly by
  /// the "Save Draft" button and internally by [submit] when the draft is
  /// stale.
  Future<void> saveDraft() async {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.copyWith(isSavingDraft: true, errorMessage: null));
    try {
      final saved = await ref.read(formRepositoryProvider).saveDraft(current.toEntity());
      final latest = state.valueOrNull ?? current;
      state = AsyncData(
        latest.copyWith(formId: saved.id, isSavingDraft: false, isDraftSaved: true),
      );
    } catch (error) {
      final latest = state.valueOrNull ?? current;
      state = AsyncData(
        latest.copyWith(isSavingDraft: false, errorMessage: 'Could not save draft: $error'),
      );
      rethrow;
    }
  }

  /// Smart save-then-submit workflow:
  /// - Draft stale (new form, or edited since the last save) -> `saveDraft`
  ///   runs first and `submitForm` only fires once it completes.
  /// - Draft already saved and unmodified -> `submitForm` runs directly.
  Future<void> submit() async {
    final current = state.valueOrNull;
    if (current == null) return;

    if (!current.isDraftSaved) {
      try {
        await saveDraft();
      } catch (_) {
        return; // saveDraft already recorded the error in state.
      }
    }

    final toSubmit = state.valueOrNull ?? current;
    state = AsyncData(toSubmit.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await ref.read(formRepositoryProvider).submitForm(toSubmit.formId);
      final latest = state.valueOrNull ?? toSubmit;
      state = AsyncData(latest.copyWith(isSubmitting: false, isSubmitted: true));
    } catch (error) {
      final latest = state.valueOrNull ?? toSubmit;
      state = AsyncData(
        latest.copyWith(isSubmitting: false, errorMessage: 'Could not submit form: $error'),
      );
    }
  }
}
