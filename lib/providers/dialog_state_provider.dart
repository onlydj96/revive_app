import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/media_item.dart';
import '../widgets/upload_media_dialog.dart';

// Generic dialog state management
class DialogState {
  final bool isLoading;
  final double progress;
  final String? error;
  final Map<String, dynamic> data;

  const DialogState({
    this.isLoading = false,
    this.progress = 0.0,
    this.error,
    this.data = const {},
  });

  DialogState copyWith({
    bool? isLoading,
    double? progress,
    String? error,
    Map<String, dynamic>? data,
  }) {
    return DialogState(
      isLoading: isLoading ?? this.isLoading,
      progress: progress ?? this.progress,
      error: error ?? this.error,
      data: data ?? this.data,
    );
  }
}

class DialogStateNotifier extends StateNotifier<DialogState> {
  DialogStateNotifier() : super(const DialogState());

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setProgress(double progress) {
    state = state.copyWith(progress: progress);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void setData(String key, dynamic value) {
    final newData = Map<String, dynamic>.from(state.data);
    newData[key] = value;
    state = state.copyWith(data: newData);
  }

  void clearData() {
    state = state.copyWith(data: {});
  }

  void reset() {
    state = const DialogState();
  }
}

// Generic dialog provider that can be used by any dialog
final dialogStateProvider =
    StateNotifierProvider.family<DialogStateNotifier, DialogState, String>(
  (ref, dialogId) => DialogStateNotifier(),
);

// Convenience providers for backward compatibility
final createFolderLoadingProvider = StateProvider<bool>((ref) => false);
final createFolderThumbnailProvider = StateProvider<XFile?>((ref) => null);
final createFolderThumbnailUrlProvider = StateProvider<String?>((ref) => null);

final uploadMediaLoadingProvider = StateProvider<bool>((ref) => false);
final uploadProgressProvider = StateProvider<double>((ref) => 0.0);
final selectedMediaItemsProvider =
    StateProvider<List<UploadMediaItem>>((ref) => []);

final createAlbumLoadingProvider = StateProvider<bool>((ref) => false);
final selectedPhotosProvider = StateProvider<List<XFile>>((ref) => []);
final coverPhotoIndexProvider = StateProvider<int?>((ref) => null);
final albumCategoryProvider =
    StateProvider<MediaCategory>((ref) => MediaCategory.general);
