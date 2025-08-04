import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../providers/dialog_state_provider.dart';

class CreateMediaFolderDialog extends ConsumerStatefulWidget {
  final String? parentFolderId;
  final Function(String name, String? description, String folderPath, String? thumbnailUrl) onCreateFolder;

  const CreateMediaFolderDialog({
    super.key,
    this.parentFolderId,
    required this.onCreateFolder,
  });

  @override
  ConsumerState<CreateMediaFolderDialog> createState() => _CreateMediaFolderDialogState();
}

class _CreateMediaFolderDialogState extends ConsumerState<CreateMediaFolderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _folderPathController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Auto-generate folder path based on name
    _nameController.addListener(_updateFolderPath);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _folderPathController.dispose();
    // Reset providers when dialog is closed
    ref.read(createFolderLoadingProvider.notifier).state = false;
    ref.read(createFolderThumbnailProvider.notifier).state = null;
    ref.read(createFolderThumbnailUrlProvider.notifier).state = null;
    super.dispose();
  }

  Future<void> _pickThumbnailImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        ref.read(createFolderThumbnailProvider.notifier).state = image;
        ref.read(createFolderThumbnailUrlProvider.notifier).state = image.path; // In real app, this would be uploaded to storage
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 선택 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateFolderPath() {
    final name = _nameController.text;
    if (name.isNotEmpty) {
      // Convert to safe folder path
      final safeName = name
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9가-힣\s-]'), '')
          .replaceAll(RegExp(r'\s+'), '_')
          .trim();
      
      final basePath = widget.parentFolderId != null ? 'subfolder' : 'root';
      _folderPathController.text = '$basePath/$safeName';
    }
  }

  Future<void> _createFolder() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(createFolderLoadingProvider.notifier).state = true;

    try {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim();
      final folderPath = _folderPathController.text.trim();
      final thumbnailUrl = ref.read(createFolderThumbnailUrlProvider);

      await widget.onCreateFolder(name, description, folderPath, thumbnailUrl);
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating folder: $e')),
        );
      }
    } finally {
      if (mounted) {
        ref.read(createFolderLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(createFolderLoadingProvider);
    final selectedThumbnail = ref.watch(createFolderThumbnailProvider);
    
    return AlertDialog(
      title: const Text('새 폴더 만들기'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Folder name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '폴더 이름 *',
                  hintText: '예: 주일 예배',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '폴더 이름을 입력해주세요';
                  }
                  if (value.trim().length < 2) {
                    return '폴더 이름은 최소 2글자 이상이어야 합니다';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '설명 (선택사항)',
                  hintText: '폴더에 대한 간단한 설명',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Folder path field (auto-generated)
              TextFormField(
                controller: _folderPathController,
                decoration: const InputDecoration(
                  labelText: '저장 경로',
                  hintText: '자동 생성됩니다',
                  border: OutlineInputBorder(),
                  helperText: '스토리지에서 폴더가 저장될 경로입니다',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '저장 경로가 필요합니다';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Thumbnail image selection
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.image, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            '썸네일 이미지 (선택사항)',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _pickThumbnailImage,
                            icon: const Icon(Icons.add_photo_alternate, size: 16),
                            label: const Text('선택'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selectedThumbnail != null) ...[
                      Container(
                        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: Image.file(
                                File(selectedThumbnail!.path),
                                width: double.infinity,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red.withOpacity(0.8),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    ref.read(createFolderThumbnailProvider.notifier).state = null;
                                    ref.read(createFolderThumbnailUrlProvider.notifier).state = null;
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        height: 80,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!, style: BorderStyle.solid),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 32,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '썸네일을 선택하지 않으면\n폴더 내 첫 번째 이미지가 자동으로 사용됩니다',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Info text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.parentFolderId != null
                            ? '현재 폴더 안에 새 하위 폴더가 생성됩니다.'
                            : '루트 폴더에 새 폴더가 생성됩니다.',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 12,
                        ),
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
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _createFolder,
          child: isLoading
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
}