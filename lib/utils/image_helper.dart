import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage({
    required ImageSource source,
    int maxWidth = 1920,
    int maxHeight = 1080,
    int quality = 85,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
      );

      if (pickedFile == null) return null;

      final File file = File(pickedFile.path);
      final String fileName = path.basename(file.path);
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String storagePath = path.join(appDir.path, fileName);
      
      return await file.copy(storagePath);
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  static Future<String?> saveImageToLocal(File imageFile) async {
    try {
      final String fileName = path.basename(imageFile.path);
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String storagePath = path.join(appDir.path, fileName);
      
      await imageFile.copy(storagePath);
      return storagePath;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }

  static Future<bool> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }
}
