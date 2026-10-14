import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:society_seva/core/models/session.dart';
import 'package:society_seva/core/providers/app_providers.dart';
import 'package:society_seva/core/storage/local_cache.dart';
import 'package:society_seva/core/storage/secure_storage.dart';
import 'package:society_seva/features/auth/data/models/auth_tokens.dart';
import 'package:society_seva/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:society_seva/features/auth/domain/usecases/google_login_usecase.dart';
import 'package:society_seva/features/auth/domain/usecases/logout_usecase.dart';
import 'package:society_seva/features/auth/domain/usecases/refresh_usecase.dart';
import 'package:society_seva/features/auth/presentation/providers/session_provider.dart';
import 'package:society_seva/features/profile/presentation/providers/profile_provider.dart';
import 'package:society_seva/features/profile/presentation/providers/user_mode_provider.dart';
import 'package:society_seva/features/seller/presentation/provider/seller_provider.dart';

final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepositoryImpl(apiClient);
});

final refreshUseCaseProvider = Provider<RefreshUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RefreshUseCase(repository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

final googleLoginUseCaseProvider = Provider<GoogleLoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GoogleLoginUseCase(repository);
});

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<AuthSessionState>>((
  ref,
) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<AsyncValue<AuthSessionState>> {
  AuthController(this._ref) : super(const AsyncValue.loading()) {
    _bootstrap();
  }

  final Ref _ref;

  Future<void> _bootstrap() async {
    state = await AsyncValue.guard(() async {
      final storage = AppSecureStorage();
      final sessionData = await storage.readSession();
      final accessToken = sessionData['accessToken'];
      final refreshToken = sessionData['refreshToken'];

      if (accessToken == null || refreshToken == null) {
        return AuthSessionState.unauthenticated();
      }

      if (accessToken.isEmpty || refreshToken.isEmpty) {
        return AuthSessionState.unauthenticated();
      }

      return AuthSessionState.authenticated(
        AuthSession(accessToken: accessToken, refreshToken: refreshToken),
      );
    });
  }

  Future<void> authenticate(AuthTokens tokens) async {
    await AppSecureStorage().saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    state = AsyncValue.data(
      AuthSessionState.authenticated(
        AuthSession(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken),
      ),
    );
  }

  Future<String?> logout() async {
    state = const AsyncValue.loading();

    String? failureMessage;
    final storage = AppSecureStorage();
    final refreshToken = await storage.readRefreshToken();

    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _ref.read(logoutUseCaseProvider).call(refreshToken: refreshToken);
      }
    } catch (error) {
      failureMessage = error.toString();
    } finally {
      await storage.clearSession();
      await LocalCache.instance.clearSessionData();
      _resetUserScopedState();
    }

    state = AsyncValue.data(AuthSessionState.unauthenticated());
    return failureMessage;
  }

  Future<void> clearLocalSession() async {
    await AppSecureStorage().clearSession();
    await LocalCache.instance.clearSessionData();
    _resetUserScopedState();
    state = AsyncValue.data(AuthSessionState.unauthenticated());
  }

  /// Riverpod caches `sellerProvider`/`profileControllerProvider` for the
  /// app's whole lifetime, not per-login — without this, whoever logs in
  /// next would see the previous user's cached profile/seller data until
  /// the provider is invalidated or the app restarts.
  void _resetUserScopedState() {
    _ref.invalidate(sellerProvider);
    _ref.invalidate(profileControllerProvider);
    _ref.read(userModeProvider.notifier).reset();
  }

  void clearError() {
    if (state.hasError) {
      state = AsyncValue.data(AuthSessionState.unauthenticated());
    }
  }

  Future<void> googleLogin({required String idToken}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final tokens = await _ref.read(googleLoginUseCaseProvider).call(idToken: idToken);
      await AppSecureStorage().saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      return AuthSessionState.authenticated(
        AuthSession(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken),
      );
    });
  }

  Future<void> refreshSession() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final refreshToken = await AppSecureStorage().readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return AuthSessionState.unauthenticated();
      }

      final tokens = await _ref.read(refreshUseCaseProvider).call(refreshToken: refreshToken);

      await AppSecureStorage().saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      return AuthSessionState.authenticated(
        AuthSession(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken),
      );
    });
  }
}
