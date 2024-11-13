// lib/services/image_service.dart

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../theme/app_theme.dart';

class ImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final uuid = const Uuid();

  // Singleton pattern
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  // Pick image from gallery or camera
  Future<File?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? quality,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: quality,
      );

      if (pickedFile == null) return null;

      return File(pickedFile.path);
    } catch (e) {
      throw ImageServiceException('Error picking image: $e');
    }
  }

  // Crop image
  Future<File?> cropImage({
    required File imageFile,
    CropAspectRatio? aspectRatio,
    List<CropAspectRatioPreset>? aspectRatioPresets,
  }) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: aspectRatio,
        aspectRatioPresets: aspectRatioPresets ?? [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: false,
          ),
        ],
      );

      if (croppedFile == null) return null;

      return File(croppedFile.path);
    } catch (e) {
      throw ImageServiceException('Error cropping image: $e');
    }
  }

  // Upload image to Firebase Storage
  Future<String> uploadImage({
    required File imageFile,
    required String userId,
    String? petId,
    String? folder,
  }) async {
    try {
      final String fileName = '${uuid.v4()}${path.extension(imageFile.path)}';
      String storagePath = 'users/$userId';
      
      if (folder != null) {
        storagePath += '/$folder';
      }
      if (petId != null) {
        storagePath += '/pets/$petId';
      }
      
      storagePath += '/$fileName';

      final Reference ref = _storage.ref().child(storagePath);
      final UploadTask uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/${path.extension(imageFile.path).substring(1)}',
          customMetadata: {
            'uploadedBy': userId,
            'timestamp': DateTime.now().toIso8601String(),
          },
        ),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw ImageServiceException('Error uploading image: $e');
    }
  }

  // Delete image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) return;
      
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw ImageServiceException('Error deleting image: $e');
    }
  }

  // Get image metadata
  Future<Map<String, dynamic>> getImageMetadata(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      final FullMetadata metadata = await ref.getMetadata();

      return {
        'name': metadata.name,
        'size': metadata.size,
        'contentType': metadata.contentType,
        'timeCreated': metadata.timeCreated,
        'updated': metadata.updated,
        'customMetadata': metadata.customMetadata,
      };
    } catch (e) {
      throw ImageServiceException('Error getting image metadata: $e');
    }
  }

  // Update image metadata
  Future<void> updateImageMetadata({
    required String imageUrl,
    required Map<String, String> metadata,
  }) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.updateMetadata(
        SettableMetadata(customMetadata: metadata),
      );
    } catch (e) {
      throw ImageServiceException('Error updating image metadata: $e');
    }
  }

  // Batch upload images
  Future<List<String>> uploadMultipleImages({
    required List<File> imageFiles,
    required String userId,
    String? petId,
    String? folder,
  }) async {
    try {
      final List<String> uploadedUrls = [];

      for (final file in imageFiles) {
        final url = await uploadImage(
          imageFile: file,
          userId: userId,
          petId: petId,
          folder: folder,
        );
        uploadedUrls.add(url);
      }

      return uploadedUrls;
    } catch (e) {
      throw ImageServiceException('Error uploading multiple images: $e');
    }
  }

  // Get temporary download URL
  Future<String> getTemporaryDownloadUrl(String imageUrl, {
    Duration duration = const Duration(hours: 1),
  }) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      return await ref.getDownloadURL();
    } catch (e) {
      throw ImageServiceException('Error getting temporary download URL: $e');
    }
  }

  // Compress image before upload
  Future<File> compressImage(File imageFile) async {
    try {
      // Implement image compression logic here
      // You might want to use packages like flutter_image_compress
      return imageFile;
    } catch (e) {
      throw ImageServiceException('Error compressing image: $e');
    }
  }

  // Generate thumbnail
  Future<File?> generateThumbnail(File imageFile) async {
    try {
      final XFile? thumbnail = await _picker.pickImage(
        source: ImageSource.file,
        maxWidth: 200,
        maxHeight: 200,
        imageQuality: 70,
      );

      if (thumbnail == null) return null;

      return File(thumbnail.path);
    } catch (e) {
      throw ImageServiceException('Error generating thumbnail: $e');
    }
  }
}

class ImageServiceException implements Exception {
  final String message;
  ImageServiceException(this.message);

  @override
  String toString() => message;
}