import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/media_item.dart';

class CreatePhotoAlbumDialog extends StatefulWidget {
  final Function(
    String title,
    String? description,
    MediaCategory category,
    List<String> photoFiles,
    String? photographer,
    List<String> tags,
    int? coverPhotoIndex,
  ) onCreateAlbum;

  const CreatePhotoAlbumDialog({
    super.key,
    required this.onCreateAlbum,
  });

  @override
  State<CreatePhotoAlbumDialog> createState() => _CreatePhotoAlbumDialogState();
}

class _CreatePhotoAlbumDialogState extends State<CreatePhotoAlbumDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _photographerController = TextEditingController();
  final _tagsController = TextEditingController();
  
  MediaCategory _selectedCategory = MediaCategory.general;
  List<XFile> _selectedPhotos = [];
  int? _coverPhotoIndex;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _photographerController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    try {
      // Check and request permissions
      bool hasPermission = await _checkAndRequestPermissions();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('사진 접근 권한이 필요합니다')),
          );
        }
        return;
      }

      final ImagePicker picker = ImagePicker();
      
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('사진을 선택하는 중...'),
            duration: Duration(seconds: 1),
          ),
        );
      }
      
      List<XFile> photos = [];
      
      try {
        photos = await picker.pickMultiImage(
          imageQuality: 80,
          maxWidth: 1920,
          maxHeight: 1080,
          limit: 20, // Limit to 20 photos maximum
        );
      } catch (platformException) {
        // If multi-image picker fails, try single image picker as fallback
        if (mounted) {
          final shouldTrySingle = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('다중 선택 실패'),
              content: const Text('여러 사진 선택에 실패했습니다. 한 장씩 선택하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('한 장씩 선택'),
                ),
              ],
            ),
          );
          
          if (shouldTrySingle == true) {
            final singlePhoto = await picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 80,
              maxWidth: 1920,
              maxHeight: 1080,
            );
            if (singlePhoto != null) {
              photos = [singlePhoto];
            }
          }
        }
      }
      
      if (photos.isNotEmpty) {
        setState(() {
          _selectedPhotos = photos;
          _coverPhotoIndex = null; // Reset cover photo selection
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사진 선택 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  Future<bool> _checkAndRequestPermissions() async {
    if (Platform.isAndroid) {
      final androidVersion = await _getAndroidVersion();
      
      if (androidVersion >= 33) {
        // Android 13+ (API 33+) uses scoped storage and photo picker
        // Check for the new media permissions
        var status = await Permission.photos.status;
        if (status.isDenied) {
          status = await Permission.photos.request();
        }
        
        // If photos permission is not available, try the legacy storage permission
        if (status.isPermanentlyDenied || status.isDenied) {
          final storageStatus = await Permission.storage.request();
          return storageStatus.isGranted;
        }
        
        return status.isGranted;
      } else {
        // For Android versions below 13, use storage permission
        var status = await Permission.storage.status;
        if (status.isDenied) {
          status = await Permission.storage.request();
        }
        
        if (status.isPermanentlyDenied) {
          // Show dialog to go to settings
          if (mounted) {
            _showPermissionSettingsDialog();
          }
          return false;
        }
        
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      var status = await Permission.photos.status;
      if (status.isDenied) {
        status = await Permission.photos.request();
      }
      
      if (status.isPermanentlyDenied) {
        if (mounted) {
          _showPermissionSettingsDialog();
        }
        return false;
      }
      
      return status.isGranted;
    }
    
    return true; // For other platforms
  }
  
  void _showPermissionSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('권한 필요'),
        content: const Text('사진을 선택하려면 저장소 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }

  Future<int> _getAndroidVersion() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt;
    } catch (e) {
      return 30; // Default to older version if detection fails
    }
  }

  void _setCoverPhoto(int index) {
    setState(() {
      _coverPhotoIndex = index;
    });
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
      if (_coverPhotoIndex == index) {
        _coverPhotoIndex = null;
      } else if (_coverPhotoIndex != null && _coverPhotoIndex! > index) {
        _coverPhotoIndex = _coverPhotoIndex! - 1;
      }
    });
  }

  Future<void> _createAlbum() async {
    if (!_formKey.currentState!.validate() || _selectedPhotos.isEmpty) {
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final photoFiles = _selectedPhotos.map((photo) => photo.path).toList();

      await widget.onCreateAlbum(
        _titleController.text,
        _descriptionController.text.isEmpty ? null : _descriptionController.text,
        _selectedCategory,
        photoFiles,
        _photographerController.text.isEmpty ? null : _photographerController.text,
        tags,
        _coverPhotoIndex,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('앨범 생성 중 오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('사진 앨범 만들기'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '앨범 제목 *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '앨범 제목을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '앨범 설명',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<MediaCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: '카테고리',
                  border: OutlineInputBorder(),
                ),
                items: MediaCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(_getCategoryLabel(category)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _photographerController,
                decoration: const InputDecoration(
                  labelText: '사진작가',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: '태그 (쉼표로 구분)',
                  border: OutlineInputBorder(),
                  hintText: '예배, 찬양, 기도',
                ),
              ),
              const SizedBox(height: 20),
              
              // Photo selection section
              Row(
                children: [
                  Text(
                    '사진 선택',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _pickPhotos,
                    icon: const Icon(Icons.photo_library),
                    label: Text(_selectedPhotos.isEmpty ? '사진 선택' : '사진 변경'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              if (_selectedPhotos.isEmpty)
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('사진을 선택해주세요', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  height: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '선택된 사진 (${_selectedPhotos.length}장)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _selectedPhotos.length,
                          itemBuilder: (context, index) {
                            final photo = _selectedPhotos[index];
                            final isCover = _coverPhotoIndex == index;
                            
                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isCover ? Colors.blue : Colors.grey[300]!,
                                      width: isCover ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.file(
                                      File(photo.path),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                                
                                // Cover photo indicator
                                if (isCover)
                                  Positioned(
                                    top: 4,
                                    left: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.star,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                                
                                // Remove button
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: () => _removePhoto(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                // Set as cover button
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: () => _setCoverPhoto(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: isCover ? Colors.blue : Colors.grey[600],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Icon(
                                        Icons.star,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      if (_coverPhotoIndex == null && _selectedPhotos.isNotEmpty)
                        Text(
                          '첫 번째 사진이 표지가 됩니다. 별표를 눌러 표지를 변경할 수 있습니다.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isUploading || _selectedPhotos.isEmpty ? null : _createAlbum,
          child: _isUploading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('만들기'),
        ),
      ],
    );
  }

  String _getCategoryLabel(MediaCategory category) {
    switch (category) {
      case MediaCategory.worship:
        return '예배';
      case MediaCategory.sermon:
        return '설교';
      case MediaCategory.fellowship:
        return '교제';
      case MediaCategory.outreach:
        return '봉사';
      case MediaCategory.youth:
        return '청년부';
      case MediaCategory.children:
        return '어린이부';
      case MediaCategory.general:
        return '일반';
    }
  }
}