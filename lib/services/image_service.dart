import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'core/base_service.dart';
import '../utils/exceptions.dart';

class ImageService extends BaseService {
//   final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final _uuid = Uuid();
  
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  // Image Upload Methods
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      await checkConnectivity();
      
      return await withRetry(() async {
        final compressedFile = await _compressImage(imageFile);
        final fileName = 'profile_${_uuid.v4()}${path.extension(imageFile.path)}';
        final ref = _storage.ref().child('users/$userId/profile/$fileName');
        
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'userId': userId},
        );
        
        await ref.putFile(compressedFile, metadata);
        final url = await ref.getDownloadURL();
        
        logger.i('Uploaded profile image: $fileName');
        analytics.logEvent('profile_image_uploaded');
        return url;
      });
    } catch (e, stackTrace) {
      logger.e('Error uploading profile image', e, stackTrace);
      throw ImageServiceException('Error uploading profile image: $e');
    }
  }

  Future<String> uploadPetImage(String userId, String petId, File imageFile) async {
    try {
      await checkConnectivity();
      
      return await withRetry(() async {
        final compressedFile = await _compressImage(imageFile);
        final fileName = 'pet_${_uuid.v4()}${path.extension(imageFile.path)}';
        final ref = _storage.ref().child('users/$userId/pets/$petId/images/$fileName');
        
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId,
            'petId': petId,
          },
        );
        
        await ref.putFile(compressedFile, metadata);
        final url = await ref.getDownloadURL();
        
        logger.i('Uploaded pet image: $fileName');
        analytics.logEvent('pet_image_uploaded');
        return url;
      });
    } catch (e, stackTrace) {
      logger.e('Error uploading pet image', e, stackTrace);
      throw ImageServiceException('Error uploading pet image: $e');
    }
  }

  Future<String> uploadMedicalImage(
    String userId,
    String petId,
    File imageFile,
    String category,
  ) async {
    try {
      await checkConnectivity();
      
      return await withRetry(() async {
        final compressedFile = await _compressImage(imageFile);
        final fileName = 'medical_${_uuid.v4()}${path.extension(imageFile.path)}';
        final ref = _storage.ref().child('users/$userId/pets/$petId/medical/$category/$fileName');
        
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId,
            'petId': petId,
            'category': category,
          },
        );
        
        await ref.putFile(compressedFile, metadata);
        final url = await ref.getDownloadURL();
        
        logger.i('Uploaded medical image: $fileName');
        analytics.logEvent('medical_image_uploaded', parameters: {'category': category});
        return url;
      });
    } catch (e, stackTrace) {
      logger.e('Error uploading medical image', e, stackTrace);
      throw ImageServiceException('Error uploading medical image: $e');
    }
  }

  // Image Picker Methods
  Future<File?> pickImageFromGallery({
    double? maxWidth,
    double? maxHeight,
    int? quality,
  }) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: quality,
      );
      
      if (pickedFile != null) {
        analytics.logEvent('image_picked_gallery');
        return File(pickedFile.path);
      }
      return null;
    } catch (e, stackTrace) {
      logger.e('Error picking image from gallery', e, stackTrace);
      throw ImageServiceException('Error picking image from gallery: $e');
    }
  }

  Future<File?> pickImageFromCamera({
    double? maxWidth,
    double? maxHeight,
    int? quality,
  }) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: quality,
      );
      
      if (pickedFile != null) {
        analytics.logEvent('image_picked_camera');
        return File(pickedFile.path);
      }
      return null;
    } catch (e, stackTrace) {
      logger.e('Error picking image from camera', e, stackTrace);
      throw ImageServiceException('Error picking image from camera: $e');
    }
  }

  // Image Management Methods
  Future<void> deleteImage(String imageUrl) async {
    try {
      await checkConnectivity();
      
      await withRetry(() async {
        final ref = _storage.refFromURL(imageUrl);
        await ref.delete();
        
        logger.i('Deleted image: ${ref.name}');
        analytics.logEvent('image_deleted');
      });
    } catch (e, stackTrace) {
      logger.e('Error deleting image', e, stackTrace);
      throw ImageServiceException('Error deleting image: $e');
    }
  }

  Future<List<String>> getPetImages(String userId, String petId) async {
    try {
      await checkConnectivity();
      
      return await withCache(
        key: 'pet_images_${userId}_$petId',
        duration: const Duration(minutes: 30),
        fetchData: () async {
          final ref = _storage.ref().child('users/$userId/pets/$petId/images');
          final result = await ref.listAll();
          
          final urls = await Future.wait(
            result.items.map((item) => item.getDownloadURL()),
          );
          
          return urls;
        },
      );
    } catch (e, stackTrace) {
      logger.e('Error getting pet images', e, stackTrace);
      throw ImageServiceException('Error getting pet images: $e');
    }
  }

  // Helper Methods
  Future<File> _compressImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) throw ImageServiceException('Failed to decode image');
      
      // Resize if image is too large
      var processedImage = image;
      if (image.width > 1920 || image.height > 1920) {
        processedImage = img.copyResize(
          image,
          width: image.width > image.height ? 1920 : null,
          height: image.height >= image.width ? 1920 : null,
        );
      }
      
      // Compress
      final compressedBytes = img.encodeJpg(processedImage, quality: 85);
      
      // Save to temporary file
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/${_uuid.v4()}.jpg');
      await tempFile.writeAsBytes(compressedBytes);
      
      return tempFile;
    } catch (e, stackTrace) {
      logger.e('Error compressing image', e, stackTrace);
      throw ImageServiceException('Error compressing image: $e');
    }
  }

  Future<Map<String, dynamic>> getImageMetadata(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      final metadata = await ref.getMetadata();
      
      return {
        'name': metadata.name,
        'size': metadata.size,
        'contentType': metadata.contentType,
        'created': metadata.timeCreated,
        'updated': metadata.updated,
        'customMetadata': metadata.customMetadata,
      };
    } catch (e, stackTrace) {
      logger.e('Error getting image metadata', e, stackTrace);
      throw ImageServiceException('Error getting image metadata: $e');
    }
  }
}

class ImageServiceException implements Exception {
  final String message;
  ImageServiceException(this.message);

  @override
  String toString() => message;
}
