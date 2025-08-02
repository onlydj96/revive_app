import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class StorageService {
  static const String mediaBucket = 'media';
  static const String thumbsBucket = 'media-thumbnails';
  
  // Initialize storage buckets
  static Future<void> initializeBuckets() async {
    try {
      // Check if user is authenticated first
      final user = SupabaseService.currentUser;
      if (user == null) {
        print('User not authenticated, skipping bucket initialization');
        return;
      }

      // Check if media bucket exists, create if not
      final buckets = await SupabaseService.storage.listBuckets();
      final mediaBucketExists = buckets.any((b) => b.name == mediaBucket);
      
      if (!mediaBucketExists) {
        print('Creating media bucket...');
        await SupabaseService.storage.createBucket(
          mediaBucket,
          const BucketOptions(public: true),
        );
        print('Media bucket created successfully');
      } else {
        print('Media bucket already exists');
      }
      
      final thumbsBucketExists = buckets.any((b) => b.name == thumbsBucket);
      if (!thumbsBucketExists) {
        print('Creating thumbnails bucket...');
        await SupabaseService.storage.createBucket(
          thumbsBucket,
          const BucketOptions(public: true),
        );
        print('Thumbnails bucket created successfully');
      } else {
        print('Thumbnails bucket already exists');
      }
    } catch (e) {
      print('Error initializing storage buckets: $e');
      // Don't throw error, just log it
      // The buckets might already exist or user might not have permissions
    }
  }
  
  // Upload file to storage with folder structure support
  static Future<String> uploadFile({
    required String bucketName,
    required String folderPath, // e.g., "Sunday Worship/July Week 4"
    required String fileName,
    required dynamic file, // Can be File, Uint8List, or String (path)
  }) async {
    try {
      // Construct full path with folder structure
      final fullPath = '$folderPath/$fileName'.replaceAll('//', '/');
      
      // Upload based on file type with upsert to handle duplicates
      if (file is File) {
        final bytes = await file.readAsBytes();
        await SupabaseService.storage
            .from(bucketName)
            .uploadBinary(
              fullPath, 
              bytes,
              fileOptions: const FileOptions(upsert: true),
            );
      } else if (file is Uint8List) {
        await SupabaseService.storage
            .from(bucketName)
            .uploadBinary(
              fullPath, 
              file,
              fileOptions: const FileOptions(upsert: true),
            );
      } else if (file is String) {
        // Assume it's a file path
        final fileObj = File(file);
        final bytes = await fileObj.readAsBytes();
        await SupabaseService.storage
            .from(bucketName)
            .uploadBinary(
              fullPath, 
              bytes,
              fileOptions: const FileOptions(upsert: true),
            );
      }
      
      // Return the public URL
      final url = SupabaseService.storage
          .from(bucketName)
          .getPublicUrl(fullPath);
      
      return url;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }
  
  // List files in a folder
  static Future<List<FileObject>> listFiles({
    required String bucketName,
    required String folderPath,
  }) async {
    try {
      final files = await SupabaseService.storage
          .from(bucketName)
          .list(path: folderPath);
      
      return files;
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }
  
  // List folders (directories) in a path
  static Future<List<String>> listFolders({
    required String bucketName,
    String path = '',
  }) async {
    try {
      final files = await SupabaseService.storage
          .from(bucketName)
          .list(path: path);
      
      // Filter for folders (items without file extensions or that end with /)
      final folders = files
          .where((f) => f.name.endsWith('/') || !f.name.contains('.'))
          .map((f) => f.name.replaceAll('/', ''))
          .toList();
      
      return folders;
    } catch (e) {
      throw Exception('Failed to list folders: $e');
    }
  }
  
  // Create a folder structure
  static Future<void> createFolderStructure({
    required String bucketName,
    required String folderPath,
  }) async {
    try {
      // Supabase Storage creates folders automatically when you upload a file
      // We can create a placeholder file to ensure the folder exists
      final placeholderPath = '$folderPath/.keep';
      await SupabaseService.storage
          .from(bucketName)
          .uploadBinary(placeholderPath, Uint8List(0));
    } catch (e) {
      // Folder might already exist, which is fine
      print('Folder creation note: $e');
    }
  }

  // Alias for createFolderStructure
  static Future<void> createFolder({
    required String bucketName,
    required String folderPath,
  }) async {
    await createFolderStructure(
      bucketName: bucketName,
      folderPath: folderPath,
    );
  }
  
  // Delete file
  static Future<void> deleteFile({
    required String bucketName,
    required String filePath,
  }) async {
    try {
      await SupabaseService.storage
          .from(bucketName)
          .remove([filePath]);
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }
  
  // Delete entire folder
  static Future<void> deleteFolder({
    required String bucketName,
    required String folderPath,
  }) async {
    try {
      // List all files in the folder
      final files = await listFiles(
        bucketName: bucketName,
        folderPath: folderPath,
      );
      
      // Delete all files
      if (files.isNotEmpty) {
        final filePaths = files.map((f) => '$folderPath/${f.name}').toList();
        await SupabaseService.storage
            .from(bucketName)
            .remove(filePaths);
      }
    } catch (e) {
      throw Exception('Failed to delete folder: $e');
    }
  }
  
  // Move/rename file or folder
  static Future<void> moveFile({
    required String bucketName,
    required String fromPath,
    required String toPath,
  }) async {
    try {
      await SupabaseService.storage
          .from(bucketName)
          .move(fromPath, toPath);
    } catch (e) {
      throw Exception('Failed to move file: $e');
    }
  }
  
  // Get public URL for a file
  static String getPublicUrl({
    required String bucketName,
    required String filePath,
  }) {
    return SupabaseService.storage
        .from(bucketName)
        .getPublicUrl(filePath);
  }
  
  // Download file
  static Future<Uint8List> downloadFile({
    required String bucketName,
    required String filePath,
  }) async {
    try {
      final data = await SupabaseService.storage
          .from(bucketName)
          .download(filePath);
      
      return data;
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }
  
  // Generate thumbnail URL (if using a transformation service)
  static String getThumbnailUrl({
    required String originalUrl,
    int width = 400,
    int height = 300,
  }) {
    // For now, return the original URL
    // In production, you might use Supabase's image transformation or a CDN service
    return originalUrl;
  }
  
  // Upload multiple files to a folder
  static Future<List<String>> uploadMultipleFiles({
    required String bucketName,
    required String folderPath,
    required List<dynamic> files, // List of File, Uint8List, or String
    List<String>? fileNames,
  }) async {
    final urls = <String>[];
    
    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final fileName = fileNames?[i] ?? 'photo_${i + 1}.jpg';
      
      try {
        final url = await uploadFile(
          bucketName: bucketName,
          folderPath: folderPath,
          fileName: fileName,
          file: file,
        );
        urls.add(url);
      } catch (e) {
        print('Failed to upload file $fileName: $e');
      }
    }
    
    return urls;
  }
}