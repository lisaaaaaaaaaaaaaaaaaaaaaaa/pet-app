import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
//   final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadFile({
    required File file,
    required String folder,
    String? customFileName,
  }) async {
    try {
      final fileName = customFileName ?? path.basename(file.path);
      final ref = _storage.ref().child('$folder/$fileName');
      
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<bool> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  Future<String?> uploadPetImage({
    required File imageFile,
    required String petId,
  }) async {
    final extension = path.extension(imageFile.path);
    final fileName = 'pet_$petId$extension';
    
    return await uploadFile(
      file: imageFile,
      folder: 'pet_images',
      customFileName: fileName,
    );
  }

  Future<String?> uploadMedicalRecord({
    required File file,
    required String petId,
    required String recordType,
  }) async {
    final extension = path.extension(file.path);
    final fileName = '${recordType}_${DateTime.now().millisecondsSinceEpoch}$extension';
    
    return await uploadFile(
      file: file,
      folder: 'medical_records/$petId',
      customFileName: fileName,
    );
  }
}
