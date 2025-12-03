import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dialog_utils.dart';

class ImagePickerUtils {
  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> pickSingleImage(
    BuildContext context, {
    ImageSource source = ImageSource.gallery,
    int maxWidth = 1920,
    int maxHeight = 1080,
    int imageQuality = 85,
  }) async {
    try {
      if (!await _checkAndRequestPermissions(context, source)) {
        return null;
      }

      return await _picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );
    } catch (e) {
      if (context.mounted) {
        DialogUtils.showErrorSnackBar(context, '이미지 선택 중 오류가 발생했습니다: $e');
      }
      return null;
    }
  }

  static Future<List<XFile>> pickMultipleImages(
    BuildContext context, {
    int limit = 20,
    int maxWidth = 1920,
    int maxHeight = 1080,
    int imageQuality = 85,
  }) async {
    try {
      if (!await _checkAndRequestPermissions(context, ImageSource.gallery)) {
        return [];
      }

      if (context.mounted) {
        DialogUtils.showInfoSnackBar(context, '사진을 선택하는 중...');
      }

      List<XFile> images = [];

      try {
        images = await _picker.pickMultiImage(
          imageQuality: imageQuality,
          maxWidth: maxWidth.toDouble(),
          maxHeight: maxHeight.toDouble(),
          limit: limit,
        );
      } catch (platformException) {
        // Fallback to single image picker
        if (context.mounted) {
          final shouldTrySingle = await DialogUtils.showConfirmationDialog(
            context,
            title: '다중 선택 실패',
            content: '여러 사진 선택에 실패했습니다. 한 장씩 선택하시겠습니까?',
            confirmText: '한 장씩 선택',
          );

          if (shouldTrySingle == true) {
            final singleImage = await pickSingleImage(context);
            if (singleImage != null) {
              images = [singleImage];
            }
          }
        }
      }

      return images;
    } catch (e) {
      if (context.mounted) {
        DialogUtils.showErrorSnackBar(context, '사진 선택 중 오류가 발생했습니다: $e');
      }
      return [];
    }
  }

  static Future<XFile?> pickVideo(
    BuildContext context, {
    ImageSource source = ImageSource.gallery,
    Duration? maxDuration,
  }) async {
    try {
      if (!await _checkAndRequestPermissions(context, source)) {
        return null;
      }

      return await _picker.pickVideo(
        source: source,
        maxDuration: maxDuration,
      );
    } catch (e) {
      if (context.mounted) {
        DialogUtils.showErrorSnackBar(context, '동영상 선택 중 오류가 발생했습니다: $e');
      }
      return null;
    }
  }

  static Future<bool> _checkAndRequestPermissions(
    BuildContext context,
    ImageSource source,
  ) async {
    if (Platform.isAndroid) {
      final androidVersion = await _getAndroidVersion();

      Permission permission;
      if (source == ImageSource.camera) {
        permission = Permission.camera;
      } else {
        permission =
            androidVersion >= 33 ? Permission.photos : Permission.storage;
      }

      var status = await permission.status;
      if (status.isDenied) {
        status = await permission.request();
      }

      if (status.isPermanentlyDenied && context.mounted) {
        _showPermissionSettingsDialog(context);
        return false;
      }

      return status.isGranted;
    } else if (Platform.isIOS) {
      Permission permission =
          source == ImageSource.camera ? Permission.camera : Permission.photos;

      var status = await permission.status;
      if (status.isDenied) {
        status = await permission.request();
      }

      if (status.isPermanentlyDenied && context.mounted) {
        _showPermissionSettingsDialog(context);
        return false;
      }

      return status.isGranted;
    }

    return true; // For other platforms
  }

  static Future<int> _getAndroidVersion() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt;
    } catch (e) {
      return 30; // Default to older version if detection fails
    }
  }

  static void _showPermissionSettingsDialog(BuildContext context) {
    DialogUtils.showConfirmationDialog(
      context,
      title: '권한 필요',
      content: '기능을 사용하려면 권한이 필요합니다. 설정에서 권한을 허용해주세요.',
      confirmText: '설정으로 이동',
      cancelText: '취소',
    ).then((result) {
      if (result == true) {
        openAppSettings();
      }
    });
  }
}
