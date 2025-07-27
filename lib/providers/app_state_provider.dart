import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLoadingState {
  idle,
  loading,
  success,
  error,
}

class AppState {
  final AppLoadingState loadingState;
  final String? errorMessage;
  final String? successMessage;

  const AppState({
    this.loadingState = AppLoadingState.idle,
    this.errorMessage,
    this.successMessage,
  });

  AppState copyWith({
    AppLoadingState? loadingState,
    String? errorMessage,
    String? successMessage,
  }) {
    return AppState(
      loadingState: loadingState ?? this.loadingState,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  bool get isLoading => loadingState == AppLoadingState.loading;
  bool get hasError => loadingState == AppLoadingState.error;
  bool get hasSuccess => loadingState == AppLoadingState.success;
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState());

  void setLoading() {
    state = state.copyWith(
      loadingState: AppLoadingState.loading,
      errorMessage: null,
      successMessage: null,
    );
  }

  void setSuccess([String? message]) {
    state = state.copyWith(
      loadingState: AppLoadingState.success,
      successMessage: message,
      errorMessage: null,
    );
  }

  void setError(String message) {
    state = state.copyWith(
      loadingState: AppLoadingState.error,
      errorMessage: message,
      successMessage: null,
    );
  }

  void setIdle() {
    state = state.copyWith(
      loadingState: AppLoadingState.idle,
      errorMessage: null,
      successMessage: null,
    );
  }

  void clearMessages() {
    state = state.copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }
}