import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:mime/mime.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final uuid = const Uuid();

  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Upload a single file
  Future<String> uploadFile({
    required File file,
    required String userId,
    String? petId,
    String? folder,
    String? customFileName,
    Map<String, String>? metadata,
  }) async {
    try {
      final String fileName = customFileName ?? '${uuid.v4()}${path.extension(file.path)}';
      String storagePath = 'users/$userId';
      
      if (folder != null) {
        storagePath += '/$folder';
      }
      if (petId != null) {
        storagePath += '/pets/$petId';
      }
      
      storagePath += '/$fileName';

      final Reference ref = _storage.ref().child(storagePath);
      
      // Detect content type
      final String? mimeType = lookupMimeType(file.path);
      
      final UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: mimeType,
          customMetadata: {
            'uploadedBy': userId,
            'timestamp': DateTime.now().toIso8601String(),
            ...?metadata,
          },
        ),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw StorageException('Error uploading file: $e');
    }
  }

  // Upload multiple files
  Future<List<String>> uploadMultipleFiles({
    required List<File> files,
    required String userId,
    String? petId,
    String? folder,
    Map<String, String>? metadata,
  }) async {
    try {
      final List<String> uploadedUrls = [];

      for (final file in files) {
        final url = await uploadFile(
          file: file,
          userId: userId,
          petId: petId,
          folder: folder,
          metadata: metadata,
        );
        uploadedUrls.add(url);
      }

      return uploadedUrls;
    } catch (e) {
      throw StorageException('Error uploading multiple files: $e');
    }
  }

  // Delete a file
  Future<void> deleteFile(String fileUrl) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw StorageException('Error deleting file: $e');
    }
  }

  // Delete multiple files
  Future<void> deleteMultipleFiles(List<String> fileUrls) async {
    try {
      await Future.wait(
        fileUrls.map((url) => deleteFile(url)),
      );
    } catch (e) {
      throw StorageException('Error deleting multiple files: $e');
    }
  }

  // Get file metadata
  Future<Map<String, dynamic>> getFileMetadata(String fileUrl) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      final FullMetadata metadata = await ref.getMetadata();

      return {
        'name': metadata.name,
        'path': metadata.fullPath,
        'size': metadata.size,
        'contentType': metadata.contentType,
        'timeCreated': metadata.timeCreated,
        'updated': metadata.updated,
        'md5Hash': metadata.md5Hash,
        'customMetadata': metadata.customMetadata,
      };
    } catch (e) {
      throw StorageException('Error getting file metadata: $e');
    }
  }

  // Update file metadata
  Future<void> updateFileMetadata({
    required String fileUrl,
    required Map<String, String> metadata,
  }) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      await ref.updateMetadata(
        SettableMetadata(customMetadata: metadata),
      );
    } catch (e) {
      throw StorageException('Error updating file metadata: $e');
    }
  }

  // Get temporary download URL
  Future<String> getTemporaryDownloadUrl(String fileUrl, {
    Duration duration = const Duration(hours: 1),
  }) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      return await ref.getDownloadURL();
    } catch (e) {
      throw StorageException('Error getting temporary download URL: $e');
    }
  }

  // List files in a directory
  Future<List<Map<String, dynamic>>> listFiles({
    required String userId,
    String? petId,
    String? folder,
    int? maxResults,
  }) async {
    try {
      String storagePath = 'users/$userId';
      
      if (folder != null) {
        storagePath += '/$folder';
      }
      if (petId != null) {
        storagePath += '/pets/$petId';
      }

      final Reference ref = _storage.ref().child(storagePath);
      final ListResult result = await ref.list(
        ListOptions(maxResults: maxResults),
      );

      final List<Map<String, dynamic>> files = [];
      
      for (final item in result.items) {
        final metadata = await item.getMetadata();
        final downloadUrl = await item.getDownloadURL();
        
        files.add({
          'name': item.name,
          'path': item.fullPath,
          'downloadUrl': downloadUrl,
          'metadata': {
            'size': metadata.size,
            'contentType': metadata.contentType,
            'timeCreated': metadata.timeCreated,
            'updated': metadata.updated,
            'customMetadata': metadata.customMetadata,
          },
        });
      }

      return files;
    } catch (e) {
      throw StorageException('Error listing files: $e');
    }
  }

  // Copy file to another location
  Future<String> copyFile({
    required String sourceUrl,
    required String destinationPath,
  }) async {
    try {
      final Reference sourceRef = _storage.refFromURL(sourceUrl);
      final Reference destinationRef = _storage.ref().child(destinationPath);
      
      final metadata = await sourceRef.getMetadata();
      final bytes = await sourceRef.getData();
      
      if (bytes == null) {
        throw StorageException('Source file is empty');
      }

      final UploadTask uploadTask = destinationRef.putData(
        bytes,
        SettableMetadata(
          contentType: metadata.contentType,
          customMetadata: metadata.customMetadata,
        ),
      );

      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw StorageException('Error copying file: $e');
    }
  }

  // Move file to another location
  Future<String> moveFile({
    required String sourceUrl,
    required String destinationPath,
  }) async {
    try {
      final newUrl = await copyFile(
        sourceUrl: sourceUrl,
        destinationPath: destinationPath,
      );
      
      await deleteFile(sourceUrl);
      return newUrl;
    } catch (e) {
      throw StorageException('Error moving file: $e');
    }
  }

  // Get storage usage statistics
  Future<Map<String, dynamic>> getStorageStats({
    required String userId,
    String? petId,
  }) async {
    try {
      String storagePath = 'users/$userId';
      if (petId != null) {
        storagePath += '/pets/$petId';
      }

      final Reference ref = _storage.ref().child(storagePath);
      final ListResult result = await ref.listAll();
      
      int totalSize = 0;
      Map<String, int> fileTypes = {};
      int totalFiles = 0;

      for (final item in result.items) {
        final metadata = await item.getMetadata();
        totalSize += metadata.size ?? 0;
        totalFiles++;

        final contentType = metadata.contentType ?? 'unknown';
        fileTypes[contentType] = (fileTypes[contentType] ?? 0) + 1;
      }

      return {
        'totalSize': totalSize,
        'totalFiles': totalFiles,
        'fileTypes': fileTypes,
        'path': storagePath,
      };
    } catch (e) {
      throw StorageException('Error getting storage statistics: $e');
    }
  }
}

class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => message;
}