import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/media_item.dart';

class UploadMediaDialog extends StatefulWidget {
  final String? folderId;
  final String folderPath;
  final Function(List<UploadMediaItem> mediaItems) onUploadMedia;

  const UploadMediaDialog({
    super.key,
    this.folderId,
    required this.folderPath,
    required this.onUploadMedia,
  });

  @override
  State<UploadMediaDialog> createState() => _UploadMediaDialogState();
}

class _UploadMediaDialogState extends State<UploadMediaDialog> {
  final ImagePicker _picker = ImagePicker();
  final List<UploadMediaItem> _selectedMedia = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('미디어 업로드'),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Upload progress indicator
            if (_isUploading) ...[
              LinearProgressIndicator(value: _uploadProgress),
              const SizedBox(height: 16),
              Text('업로드 중... ${(_uploadProgress * 100).toInt()}%'),
              const SizedBox(height: 16),
            ],
            
            // Media selection buttons
            if (!_isUploading) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('사진 선택'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickVideo,
                      icon: const Icon(Icons.videocam),
                      label: const Text('동영상 선택'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Camera buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('사진 촬영'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _recordVideo,
                      icon: const Icon(Icons.videocam),
                      label: const Text('동영상 촬영'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            // Selected media preview
            if (_selectedMedia.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                '선택된 파일 (${_selectedMedia.length}개)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _selectedMedia.length,
                  itemBuilder: (context, index) {
                    final media = _selectedMedia[index];
                    return _buildMediaPreview(media, index);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _selectedMedia.isNotEmpty && !_isUploading
              ? _uploadMedia
              : null,
          child: Text(_isUploading ? '업로드 중...' : '업로드'),
        ),
      ],
    );
  }

  Widget _buildMediaPreview(UploadMediaItem media, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        leading: _buildThumbnail(media),
        title: Text(
          media.name,
          style: const TextStyle(fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${_formatFileSize(media.size)} • ${media.type.name}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: () {
            setState(() {
              _selectedMedia.removeAt(index);
            });
          },
        ),
      ),
    );
  }

  Widget _buildThumbnail(UploadMediaItem media) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: media.type == MediaType.photo
            ? Image.file(
                File(media.path),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.photo),
              )
            : const Icon(Icons.videocam),
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      
      for (final image in images) {
        final file = File(image.path);
        final stats = await file.stat();
        
        _selectedMedia.add(UploadMediaItem(
          name: image.name,
          path: image.path,
          size: stats.size,
          type: MediaType.photo,
        ));
      }
      
      setState(() {});
    } catch (e) {
      _showError('사진 선택 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      
      if (video != null) {
        final file = File(video.path);
        final stats = await file.stat();
        
        _selectedMedia.add(UploadMediaItem(
          name: video.name,
          path: video.path,
          size: stats.size,
          type: MediaType.video,
        ));
        
        setState(() {});
      }
    } catch (e) {
      _showError('동영상 선택 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      
      if (photo != null) {
        final file = File(photo.path);
        final stats = await file.stat();
        
        _selectedMedia.add(UploadMediaItem(
          name: photo.name,
          path: photo.path,
          size: stats.size,
          type: MediaType.photo,
        ));
        
        setState(() {});
      }
    } catch (e) {
      _showError('사진 촬영 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
      
      if (video != null) {
        final file = File(video.path);
        final stats = await file.stat();
        
        _selectedMedia.add(UploadMediaItem(
          name: video.name,
          path: video.path,
          size: stats.size,
          type: MediaType.video,
        ));
        
        setState(() {});
      }
    } catch (e) {
      _showError('동영상 촬영 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _uploadMedia() async {
    if (_selectedMedia.isEmpty) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      await widget.onUploadMedia(_selectedMedia);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedMedia.length}개 파일이 성공적으로 업로드되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('업로드 중 오류가 발생했습니다: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class UploadMediaItem {
  final String name;
  final String path;
  final int size;
  final MediaType type;

  UploadMediaItem({
    required this.name,
    required this.path,
    required this.size,
    required this.type,
  });
}