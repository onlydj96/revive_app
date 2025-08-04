import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../common/base_dialog.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/image_picker_utils.dart';
import '../../utils/form_validators.dart';
import '../../providers/dialog_state_provider.dart';

class CreateMediaFolderDialogOptimized extends ConsumerStatefulWidget {
  final String? parentFolderId;
  final Function(String name, String? description, String folderPath, String? thumbnailUrl) onCreateFolder;

  const CreateMediaFolderDialogOptimized({
    super.key,
    this.parentFolderId,
    required this.onCreateFolder,
  });

  @override
  ConsumerState<CreateMediaFolderDialogOptimized> createState() => _CreateMediaFolderDialogOptimizedState();
}

class _CreateMediaFolderDialogOptimizedState extends ConsumerState<CreateMediaFolderDialogOptimized> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _folderPathController = TextEditingController();
  
  static const String _dialogId = 'create_media_folder';

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateFolderPath);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _folderPathController.dispose();
    // Reset dialog state
    ref.read(dialogStateProvider(_dialogId).notifier).reset();
    super.dispose();
  }

  void _updateFolderPath() {
    final name = _nameController.text;
    if (name.isNotEmpty) {
      final basePath = widget.parentFolderId != null ? 'subfolder' : 'root';
      final safePath = FormValidators.generateSafeFolderPath(name, basePath);
      _folderPathController.text = safePath;
    }
  }

  Future<void> _pickThumbnailImage() async {
    final image = await ImagePickerUtils.pickSingleImage(context);
    if (image != null) {
      ref.read(dialogStateProvider(_dialogId).notifier).setData('thumbnail', image);
      ref.read(dialogStateProvider(_dialogId).notifier).setData('thumbnailUrl', image.path);
    }
  }

  void _removeThumbnail() {
    ref.read(dialogStateProvider(_dialogId).notifier).setData('thumbnail', null);
    ref.read(dialogStateProvider(_dialogId).notifier).setData('thumbnailUrl', null);
  }

  Future<void> _createFolder() async {
    if (!_formKey.currentState!.validate()) return;

    final dialogNotifier = ref.read(dialogStateProvider(_dialogId).notifier);
    dialogNotifier.setLoading(true);

    try {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim();
      final folderPath = _folderPathController.text.trim();
      final thumbnailUrl = ref.read(dialogStateProvider(_dialogId)).data['thumbnailUrl'] as String?;

      await widget.onCreateFolder(name, description, folderPath, thumbnailUrl);
      
      if (mounted) {
        DialogUtils.showSuccessSnackBar(context, '폴더가 성공적으로 생성되었습니다');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        DialogUtils.showErrorSnackBar(context, '폴더 생성 중 오류가 발생했습니다: $e');
      }
    } finally {
      if (mounted) {
        dialogNotifier.setLoading(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dialogState = ref.watch(dialogStateProvider(_dialogId));
    final selectedThumbnail = dialogState.data['thumbnail'] as XFile?;
    
    return BaseDialog(
      title: '새 폴더 만들기',
      content: Form(
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
              validator: (value) => FormValidators.validateMinLength(value, 2, '폴더 이름'),
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
              validator: FormValidators.validateFolderPath,
            ),
            const SizedBox(height: 16),

            // Thumbnail image selection
            _buildThumbnailSection(selectedThumbnail),
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
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.parentFolderId != null
                          ? '현재 폴더 안에 새 하위 폴더가 생성됩니다.'
                          : '루트 폴더에 새 폴더가 생성됩니다.',
                      style: TextStyle(color: Colors.blue[700], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        BaseDialogActions(
          isLoading: dialogState.isLoading,
          onCancel: () => Navigator.of(context).pop(),
          onConfirm: _createFolder,
          confirmText: '만들기',
        ),
      ],
    );
  }

  Widget _buildThumbnailSection(XFile? selectedThumbnail) {
    return Container(
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
                const Text('썸네일 이미지 (선택사항)', style: TextStyle(fontWeight: FontWeight.w500)),
                const Spacer(),
                TextButton.icon(
                  onPressed: _pickThumbnailImage,
                  icon: const Icon(Icons.add_photo_alternate, size: 16),
                  label: const Text('선택'),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                ),
              ],
            ),
          ),
          if (selectedThumbnail != null)
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
                      File(selectedThumbnail.path),
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.error, color: Colors.grey),
                      ),
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
                        onPressed: _removeThumbnail,
                        icon: const Icon(Icons.close, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, size: 32, color: Colors.grey[400]),
                  const SizedBox(height: 4),
                  Text(
                    '썸네일을 선택하지 않으면\n폴더 내 첫 번째 이미지가 자동으로 사용됩니다',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}