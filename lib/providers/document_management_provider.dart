// lib/providers/document_management_provider.dart

import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import '../services/pet_service.dart';
import '../models/pet.dart';

class DocumentManagementProvider with ChangeNotifier {
  final PetService _petService = PetService();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  Map<String, List<PetDocument>> _documents = {};
  Map<String, DateTime> _lastUpdated = {};
  Map<String, Map<String, dynamic>> _documentAnalytics = {};
  bool _isLoading = false;
  double _uploadProgress = 0.0;
  String? _error;
  Duration _cacheExpiration = const Duration(hours: 1);
  final int _maxFileSize = 20 * 1024 * 1024; // 20MB
  final List<String> _allowedMimeTypes = [
    'application/pdf',
    'image/jpeg',
    'image/png',
    'image/heic',
  ];

  // Enhanced Getters
  bool get isLoading => _isLoading;
  double get uploadProgress => _uploadProgress;
  String? get error => _error;
  Map<String, DateTime> get lastUpdated => _lastUpdated;

  // Check if data needs refresh
  bool _needsRefresh(String petId) {
    final lastUpdate = _lastUpdated[petId];
    if (lastUpdate == null) return true;
    return DateTime.now().difference(lastUpdate) > _cacheExpiration;
  }

  // Enhanced document retrieval
  Future<List<PetDocument>> getDocumentsForPet(
    String petId, {
    bool forceRefresh = false,
    String? type,
    List<String>? tags,
    bool includeExpired = false,
  }) async {
    if (forceRefresh || _needsRefresh(petId)) {
      await loadDocuments(petId, type: type);
    }

    var docs = _documents[petId] ?? [];

    // Apply filters
    if (type != null) {
      docs = docs.where((doc) => 
        doc.type.toLowerCase() == type.toLowerCase()
      ).toList();
    }

    if (tags != null && tags.isNotEmpty) {
      docs = docs.where((doc) => 
        tags.any((tag) => doc.tags.contains(tag.toLowerCase()))
      ).toList();
    }

    if (!includeExpired) {
      final now = DateTime.now();
      docs = docs.where((doc) => 
        doc.expiryDate == null || doc.expiryDate!.isAfter(now)
      ).toList();
    }

    return docs;
  }

  // Enhanced document upload
  Future<void> uploadAndAddDocument({
    required String petId,
    required File file,
    required String name,
    required String type,
    String? description,
    DateTime? expiryDate,
    List<String>? tags,
    bool isSharedWithVet = false,
    Map<String, dynamic>? metadata,
    String? category,
    List<String>? relatedDocuments,
    bool isConfidential = false,
  }) async {
    try {
      // Validate file
      await _validateFile(file);

      _isLoading = true;
      _uploadProgress = 0.0;
      notifyListeners();

      final String fileName = _generateSecureFileName(file);
      final String filePath = _generateStoragePath(petId, fileName);

      // Prepare metadata
      final SettableMetadata fileMetadata = SettableMetadata(
        contentType: lookupMimeType(file.path),
        customMetadata: {
          'name': name,
          'type': type,
          'uploadDate': DateTime.now().toIso8601String(),
          'category': category ?? 'uncategorized',
          'isConfidential': isConfidential.toString(),
        },
      );

      // Create upload task with metadata
      final uploadTask = _storage.ref(filePath).putFile(
        file,
        fileMetadata,
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
          notifyListeners();
        },
        onError: (error) {
          throw Exception('Upload failed: $error');
        },
      );

      // Wait for upload to complete
      final snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Add document to database
      final document = await _petService.addDocument(
        petId: petId,
        name: name,
        type: type,
        url: downloadUrl,
        description: description,
        expiryDate: expiryDate,
        tags: tags,
        isSharedWithVet: isSharedWithVet,
        metadata: {
          ...?metadata,
          'fileName': fileName,
          'fileSize': await file.length(),
          'mimeType': lookupMimeType(file.path),
          'category': category,
          'isConfidential': isConfidential,
          'relatedDocuments': relatedDocuments,
          'uploadDate': DateTime.now().toIso8601String(),
        },
      );

      // Update local cache
      final docs = _documents[petId] ?? [];
      docs.insert(0, PetDocument.fromJson(document));
      _documents[petId] = docs;

      await _updateDocumentAnalytics(petId);
      _error = null;
    } catch (e, stackTrace) {
      _error = _handleError('Upload failed', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      _uploadProgress = 0.0;
      notifyListeners();
    }
  }

  // Validate file before upload
  Future<void> _validateFile(File file) async {
    final size = await file.length();
    if (size > _maxFileSize) {
      throw DocumentException('File size exceeds 20MB limit');
    }

    final mimeType = lookupMimeType(file.path);
    if (mimeType == null || !_allowedMimeTypes.contains(mimeType)) {
      throw DocumentException('Invalid file type. Allowed types: PDF, JPEG, PNG, HEIC');
    }
  }

  String _generateSecureFileName(File file) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    final extension = path.extension(file.path);
    return '$timestamp$random$extension';
  }

  String _generateStoragePath(String petId, String fileName) {
    return 'pets/$petId/documents/${DateTime.now().year}/${DateTime.now().month}/$fileName';
  }

  // ... (continued in next part)
  // Continuing lib/providers/document_management_provider.dart

  // Enhanced document deletion with backup
  Future<void> deleteDocument({
    required String petId,
    required String documentId,
    required String storageUrl,
    bool softDelete = true,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (softDelete) {
        // Move to archive instead of deleting
        await _archiveDocument(petId, documentId, storageUrl);
      } else {
        // Permanent deletion
        if (storageUrl.isNotEmpty) {
          await _storage.refFromURL(storageUrl).delete();
        }
        await _petService.deleteDocument(petId, documentId);
      }

      // Update local cache
      _documents[petId]?.removeWhere((doc) => doc.id == documentId);
      await _updateDocumentAnalytics(petId);
      _error = null;
    } catch (e, stackTrace) {
      _error = _handleError('Delete failed', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _archiveDocument(
    String petId,
    String documentId,
    String storageUrl,
  ) async {
    final document = _documents[petId]?.firstWhere((doc) => doc.id == documentId);
    if (document == null) throw DocumentException('Document not found');

    // Create archive copy
    await _petService.updateDocument(
      petId: petId,
      documentId: documentId,
      isArchived: true,
      archivedAt: DateTime.now(),
      isActive: false,
    );
  }

  // Enhanced metadata update with version control
  Future<void> updateDocumentMetadata({
    required String petId,
    required String documentId,
    String? name,
    String? description,
    DateTime? expiryDate,
    List<String>? tags,
    bool? isSharedWithVet,
    Map<String, dynamic>? metadata,
    String? category,
    List<String>? relatedDocuments,
    bool? isConfidential,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get current document
      final currentDoc = _documents[petId]?.firstWhere(
        (doc) => doc.id == documentId,
        orElse: () => throw DocumentException('Document not found'),
      );

      // Create version history
      final versionHistory = {
        'timestamp': DateTime.now().toIso8601String(),
        'previousValues': {
          'name': currentDoc?.name,
          'description': currentDoc?.description,
          'expiryDate': currentDoc?.expiryDate?.toIso8601String(),
          'tags': currentDoc?.tags,
          'isSharedWithVet': currentDoc?.isSharedWithVet,
          'category': currentDoc?.metadata?['category'],
        },
      };

      // Update document with version history
      await _petService.updateDocument(
        petId: petId,
        documentId: documentId,
        name: name,
        description: description,
        expiryDate: expiryDate,
        tags: tags,
        isSharedWithVet: isSharedWithVet,
        metadata: {
          ...?metadata,
          'lastModified': DateTime.now().toIso8601String(),
          'category': category,
          'isConfidential': isConfidential,
          'relatedDocuments': relatedDocuments,
          'versionHistory': [...?currentDoc?.metadata?['versionHistory'], versionHistory],
        },
      );

      await loadDocuments(petId);
      _error = null;
    } catch (e, stackTrace) {
      _error = _handleError('Update failed', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Document analytics
  Future<void> _updateDocumentAnalytics(String petId) async {
    final docs = _documents[petId] ?? [];
    
    _documentAnalytics[petId] = {
      'totalDocuments': docs.length,
      'byType': _analyzeDocumentsByType(docs),
      'byCategory': _analyzeDocumentsByCategory(docs),
      'expiryAnalysis': _analyzeDocumentExpiry(docs),
      'storageUsage': _calculateStorageUsage(docs),
      'sharingAnalysis': _analyzeSharingStatus(docs),
      'ageDistribution': _analyzeDocumentAge(docs),
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> _analyzeDocumentsByType(List<PetDocument> docs) {
    final typeMap = <String, int>{};
    for (var doc in docs) {
      typeMap[doc.type] = (typeMap[doc.type] ?? 0) + 1;
    }
    return {
      'distribution': typeMap,
      'mostCommon': typeMap.entries.isEmpty ? null :
        typeMap.entries.reduce((a, b) => a.value > b.value ? a : b).key,
    };
  }

  Map<String, dynamic> _analyzeDocumentExpiry(List<PetDocument> docs) {
    final now = DateTime.now();
    final expired = docs.where((doc) => 
      doc.expiryDate != null && doc.expiryDate!.isBefore(now)
    ).length;
    final expiringSoon = docs.where((doc) => 
      doc.expiryDate != null && 
      doc.expiryDate!.isAfter(now) && 
      doc.expiryDate!.isBefore(now.add(const Duration(days: 30)))
    ).length;

    return {
      'expired': expired,
      'expiringSoon': expiringSoon,
      'validDocuments': docs.length - expired,
      'documentsWithoutExpiry': docs.where((doc) => doc.expiryDate == null).length,
    };
  }

  Map<String, dynamic> generateDocumentReport(String petId) {
    final analytics = _documentAnalytics[petId];
    if (analytics == null) return {};

    return {
      'summary': {
        'totalDocuments': analytics['totalDocuments'],
        'storageUsage': analytics['storageUsage'],
        'lastUpdated': analytics['lastUpdated'],
      },
      'documentTypes': analytics['byType'],
      'categories': analytics['byCategory'],
      'expiry': analytics['expiryAnalysis'],
      'sharing': analytics['sharingAnalysis'],
      'ageDistribution': analytics['ageDistribution'],
      'recommendations': generateDocumentRecommendations(petId),
    };
  }

  List<String> generateDocumentRecommendations(String petId) {
    final analytics = _documentAnalytics[petId];
    if (analytics == null) return [];

    final recommendations = <String>[];
    final expiryAnalysis = analytics['expiryAnalysis'] as Map<String, dynamic>;

    if (expiryAnalysis['expired'] > 0) {
      recommendations.add(
        'Update ${expiryAnalysis['expired']} expired document(s)'
      );
    }

    if (expiryAnalysis['expiringSoon'] > 0) {
      recommendations.add(
        'Review ${expiryAnalysis['expiringSoon']} document(s) expiring soon'
      );
    }

    // Add more specific recommendations based on analytics

    return recommendations;
  }

  String _handleError(String operation, dynamic error, StackTrace stackTrace) {
    debugPrint('Document Management Error: $operation');
    debugPrint('Error: $error');
    debugPrint('StackTrace: $stackTrace');
    return 'Failed to $operation: ${error.toString()}';
  }
}

class DocumentException implements Exception {
  final String message;
  DocumentException(this.message);

  @override
  String toString() => message;
}