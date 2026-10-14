// Riverpod state management for the seller onboarding flow: fetching the
// current user's seller profile and pushing edits back to the server.
//
// NOTE: `seller_provider.dart` lives in this same folder and already
// declares top-level providers with the exact same names as the ones below
// (`sellerRemoteDataSource`, `sellerRepository`, `fetchSellerProfileUseCase`),
// plus its own `ProfileController`/`sellerActionProvider`. That file is what
// the live seller onboarding screen actually uses today. This file compiles
// fine on its own because nothing currently imports it, but importing it
// alongside `seller_provider.dart` (or `profile_provider.dart`, which has its
// own unrelated `ProfileController`) in the same library would be an
// ambiguous-name compile error. Keep that in mind before wiring this in.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:society_seva/core/providers/app_providers.dart';
import 'package:society_seva/features/seller/data/datasources/seller_remote_data_source.dart';
import 'package:society_seva/features/seller/data/models/seller_profile_request.dart';
import 'package:society_seva/features/seller/domain/entities/seller_profile_entity.dart';
import 'package:society_seva/features/seller/domain/repositories/seller_repository.dart';
import 'package:society_seva/features/seller/domain/usecase/fetch_seller_profile_usecase.dart';
import 'package:society_seva/features/seller/domain/usecase/update_seller_profile_by_id_use_case.dart';

// --- Dependency injection chain: data source -> repository -> usecases ----

/// Talks to the seller API endpoints over the shared [ApiClient].
final sellerRemoteDataSource = Provider<SellerRemoteDataSource>((ref) {
  return SellerRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

/// Maps data-source models to domain entities for the rest of the app.
final sellerRepository = Provider<SellerRepository>((ref) {
  return SellerRepositoryImpl(sellerRemoteDataSource: ref.watch(sellerRemoteDataSource));
});

/// Fetches the current user's seller profile (null if they haven't applied).
final fetchSellerProfileUseCase = Provider<FetchSellerProfileUseCase>((ref) {
  return FetchSellerProfileUseCase(ref.watch(sellerRepository));
});

/// Overwrites an existing seller profile (by id) with new field values.
final updateSellerProfileUseCase = Provider<UpdateSellerProfileByIdUseCase>((ref) {
  return UpdateSellerProfileByIdUseCase(ref.watch(sellerRepository));
});

/// Lifecycle of the seller profile as far as this controller is concerned.
/// `create`/`submit`/`deleting` are reserved for future use — only
/// `loading`/`loaded`/`updating`/`error` are actually set below today.
enum SellerStatus { initial, loading, loaded, create, submit, updating, error, deleting }

/// Immutable state held by [ProfileController]: what's currently happening,
/// the last-loaded profile (if any), and the last error/message to show.
class SellerState {
  const SellerState({required this.status, this.profile, this.errorMessage, this.message});

  const SellerState.initial() : this(status: SellerStatus.initial);

  final SellerStatus status;
  final SellerProfileEntity? profile;
  final String? errorMessage;
  final String? message;

  /// Returns a copy with the given fields replaced. `profile` and `message`
  /// only ever grow/replace (there's no way to null them back out here);
  /// pass `clearError: true` to drop a previous error when starting a new
  /// action.
  SellerState copyWith({
    SellerStatus? status,
    SellerProfileEntity? profile,
    String? errorMessage,
    String? message,
    bool clearError = false,
  }) {
    return SellerState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      message: message ?? this.message,
    );
  }
}

/// Loads and updates the current user's seller profile, exposing a
/// [SellerState] so the UI can render loading/error/loaded states directly
/// from `state.status`.
class ProfileController extends StateNotifier<SellerState> {
  ProfileController(this._ref) : super(const SellerState.initial());

  final Ref _ref;

  /// Fetches the seller profile. By default this is a no-op if a fetch is
  /// already in flight or has already completed — pass `force: true` (e.g.
  /// on pull-to-refresh) to re-fetch regardless.
  Future<void> fetchSellerProfile({bool force = false}) async {
    if (!force && (state.status == SellerStatus.loading || state.status == SellerStatus.loaded)) {
      return;
    }

    state = state.copyWith(status: SellerStatus.loading, clearError: true);

    try {
      final profile = await _ref.read(fetchSellerProfileUseCase).call();
      state = SellerState(status: SellerStatus.loaded, profile: profile);
    } catch (error) {
      state = state.copyWith(status: SellerStatus.error, errorMessage: error.toString());
    }
  }

  /// Sends the given [request] to update the seller profile identified by
  /// [sellerId], and swaps `state.profile` for the server's response on
  /// success. Returns whether the update succeeded, so callers can decide
  /// what to do next (e.g. pop the screen, show a snackbar) without having
  /// to inspect `state` themselves.
  Future<bool> updateSellerProfile({
    required SellerProfileRequest request,
    required String sellerId,
  }) async {
    state = state.copyWith(status: SellerStatus.updating, clearError: true);

    try {
      final profile = await _ref
          .read(updateSellerProfileUseCase)
          .call(request: request, sellerId: sellerId);
      state = SellerState(status: SellerStatus.loaded, profile: profile);
      return true;
    } catch (error) {
      state = state.copyWith(status: SellerStatus.error, errorMessage: error.toString());
      return false;
    }
  }
}

/// The provider widgets actually consume: exposes [ProfileController] and
/// its [SellerState] together, the way `profileControllerProvider` does for
/// the profile feature.
final sellerOnboardingControllerProvider = StateNotifierProvider<ProfileController, SellerState>((
  ref,
) {
  return ProfileController(ref);
});

// ---------------------------------------------------------------------------
// Example usage (not compiled — for reference only):
//
// class SellerOnboardingExampleScreen extends ConsumerWidget {
//   const SellerOnboardingExampleScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Kick off the initial fetch once, e.g. from initState via
//     // Future.microtask, or here with ref.listen's fireImmediately pattern.
//     final state = ref.watch(sellerOnboardingControllerProvider);
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Seller profile')),
//       body: switch (state.status) {
//         SellerStatus.initial || SellerStatus.loading =>
//           const Center(child: CircularProgressIndicator()),
//         SellerStatus.error => Center(child: Text(state.errorMessage ?? 'Something went wrong')),
//         _ => ListView(
//             children: [
//               Text(state.profile?.displayName ?? 'No profile yet'),
//               FilledButton(
//                 onPressed: () async {
//                   final ok = await ref
//                       .read(sellerOnboardingControllerProvider.notifier)
//                       .updateSellerProfile(
//                         sellerId: state.profile!.id,
//                         request: SellerProfileRequest(
//                           userId: state.profile!.userId,
//                           displayName: 'New name',
//                           sellerType: state.profile!.sellerType,
//                           address: state.profile!.address,
//                           city: state.profile!.city,
//                           state: state.profile!.state,
//                           country: state.profile!.country,
//                           pinCode: state.profile!.pinCode,
//                         ),
//                       );
//                   if (ok && context.mounted) {
//                     ScaffoldMessenger.of(context)
//                         .showSnackBar(const SnackBar(content: Text('Updated')));
//                   }
//                 },
//                 child: const Text('Save changes'),
//               ),
//             ],
//           ),
//       },
//     );
//   }
// }
//
// // Trigger the first load (e.g. in a parent widget's initState):
// // Future.microtask(
// //   () => ref.read(sellerOnboardingControllerProvider.notifier).fetchSellerProfile(),
// // );
// ---------------------------------------------------------------------------
