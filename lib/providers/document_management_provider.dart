import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:path/path.dart' as path;
import '../utils/logger.dart';
import 'dart:io';
import 'dart:async';

class DocumentManagementProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAnalytics _analytics;
  final Logger _logger;

  Map<String, List<PetDocument>> _documents = {};
  Map<String, DateTime> _lastUpdated = {};
  bool _isLoading = false;
  String? _error;
  Timer? _cleanupTimer;
  final Duration _cacheExpiration = const Duration(hours: 1);

  DocumentManagementProvider({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseAnalytics? analytics,
    Logger? logger,
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _storage = storage ?? FirebaseStorage.instance,
    _analytics = analytics ?? FirebaseAnalytics.instance,
    _logger = logger ?? Logger() {
    _initializeListeners();
    _setupCleanupTimer();
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, DateTime> get lastUpdated => _lastUpdated;

  void _initializeListeners() {
    _firestore.collection('pet_documents')
        .snapshots()
        .listen(_handleDocumentUpdates);
  }

  void _setupCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(
      const Duration(hours: 24),
      (_) => _cleanupExpiredCache(),
    );
  }

  Future<void> _handleDocumentUpdates(QuerySnapshot snapshot) async {
    for (var change in snapshot.docChanges) {
      final data = change.doc.data() as Map<String, dynamic>;
      final petId = data['petId'] as String;

      switch (change.type) {
        case DocumentChangeType.added:
        case DocumentChangeType.modified:
          await loadDocuments(petId, silent: true);
          break;
        case DocumentChangeType.removed:
          _removeDocument(petId, change.doc.id);
          break;
      }
    }
    notifyListeners();
  }

  Future<List<PetDocument>> getDocuments(
    String petId, {
    bool forceRefresh = false,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? tags,
  }) async {
    if (forceRefresh || _needsRefresh(petId)) {
      await loadDocuments(petId);
    }

    var docs = _documents[petId] ?? [];

    // Apply filters
    if (category != null) {
      docs = docs.where((doc) => doc.category == category).toList();
    }
    if (startDate != null) {
      docs = docs.where((doc) => doc.uploadDate.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      docs = docs.where((doc) => doc.uploadDate.isBefore(endDate)).toList();
    }
    if (tags != null && tags.isNotEmpty) {
      docs = docs.where(
        (doc) => tags.any((tag) => doc.tags.contains(tag))
      ).toList();
    }

    return docs;
  }

  Future<void> uploadDocument({
    required String petId,
    required File file,
    required String category,
    String? title,
    String? description,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Validate file
      await _validateFile(file);

      // Generate unique filename
      final filename = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final storagePath = 'pet_documents/$petId/$filename';

      // Upload to Firebase Storage
      final storageRef = _storage.ref().child(storagePath);
      final uploadTask = storageRef.putFile(
        file,
        SettableMetadata(
          contentType: _getContentType(file.path),
          customMetadata: {
            'category': category,
            'originalName': path.basename(file.path),
          },
        ),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        _logger.info('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      });

      // Wait for upload to complete
      await uploadTask.whenComplete(() => null);
      final downloadUrl = await storageRef.getDownloadURL();

      // Create document record in Firestore
      final document = PetDocument(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        petId: petId,
        title: title ?? path.basenameWithoutExtension(file.path),
        description: description,
        category: category,
        fileUrl: downloadUrl,
        filePath: storagePath,
        fileType: _getFileType(file.path),
        size: await file.length(),
        tags: tags ?? [],
        metadata: metadata ?? {},
        uploadDate: DateTime.now(),
      );

      await _firestore.collection('pet_documents').add(document.toJson());

      // Update local cache
      final docs = _documents[petId] ?? [];
      docs.add(document);
      _documents[petId] = docs;
      _lastUpdated[petId] = DateTime.now();

      // Track event
      await _analytics.logEvent(
        name: 'document_uploaded',
        parameters: {
          'pet_id': petId,
          'category': category,
          'file_type': document.fileType,
        },
      );

      _error = null;

    } catch (e, stackTrace) {
      _error = _handleError('Failed to upload document', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDocument({
    required String documentId,
    required String petId,
    String? title,
    String? description,
    String? category,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final updates = <String, dynamic>{
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (category != null) 'category': category,
        if (tags != null) 'tags': tags,
        if (metadata != null) 'metadata': metadata,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('pet_documents')
          .doc(documentId)
          .update(updates);

      // Update local cache
      final docs = _documents[petId] ?? [];
      final index = docs.indexWhere((doc) => doc.id == documentId);
      if (index != -1) {
        docs[index] = docs[index].copyWith(
          title: title,
          description: description,
          category: category,
          tags: tags,
          metadata: metadata,
        );
        _documents[petId] = docs;
      }

      _error = null;

    } catch (e, stackTrace) {
      _error = _handleError('Failed to update document', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDocument(String petId, String documentId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get document reference
      final doc = await _firestore
          .collection('pet_documents')
          .doc(documentId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final filePath = data['filePath'] as String;

        // Delete from Storage
        await _storage.ref().child(filePath).delete();

        // Delete from Firestore
        await doc.reference.delete();

        // Update local cache
        _removeDocument(petId, documentId);
      }

      _error = null;

    } catch (e, stackTrace) {
      _error = _handleError('Failed to delete document', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDocuments(String petId, {bool silent = false}) async {
    try {
      if (!silent) {
        _isLoading = true;
        notifyListeners();
      }

      final snapshot = await _firestore
          .collection('pet_documents')
          .where('petId', isEqualTo: petId)
          .get();

      _documents[petId] = snapshot.docs
          .map((doc) => PetDocument.fromJson(doc.data()))
          .toList();
      _lastUpdated[petId] = DateTime.now();

      if (!silent) _error = null;

    } catch (e, stackTrace) {
      _error = _handleError('Failed to load documents', e, stackTrace);
      if (!silent) rethrow;
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _validateFile(File file) async {
    final size = await file.length();
    final maxSize = 20 * 1024 * 1024; // 20MB

    if (size > maxSize) {
      throw DocumentException('File size exceeds 20MB limit');
    }

    final extension = path.extension(file.path).toLowerCase();
    final allowedExtensions = ['.pdf', '.jpg', '.jpeg', '.png', '.doc', '.docx'];

    if (!allowedExtensions.contains(extension)) {
      throw DocumentException('File type not supported');
    }
  }

  String _getContentType(String filepath) {
    final ext = path.extension(filepath).toLowerCase();
    switch (ext) {
      case '.pdf':
        return 'application/pdf';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  String _getFileType(String filepath) {
    return path.extension(filepath).toLowerCase().replaceAll('.', '');
  }

  void _removeDocument(String petId, String documentId) {
    final docs = _documents[petId] ?? [];
    docs.removeWhere((doc) => doc.id == documentId);
    _documents[petId] = docs;
    notifyListeners();
  }

  void _cleanupExpiredCache() {
    final now = DateTime.now();
    _lastUpdated.removeWhere(
      (petId, timestamp) => now.difference(timestamp) > _cacheExpiration
    );
    notifyListeners();
  }

  bool _needsRefresh(String petId) {
    final lastUpdate = _lastUpdated[petId];
    if (lastUpdate == null) return true;
    return DateTime.now().difference(lastUpdate) > _cacheExpiration;
  }

  String _handleError(String operation, dynamic error, StackTrace stackTrace) {
    _logger.error(operation, error, stackTrace);
    return 'Failed to $operation: ${error.toString()}';
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    super.dispose();
  }
}

class PetDocument {
  final String id;
  final String petId;
  final String title;
  final String? description;
  final String category;
  final String fileUrl;
  final String filePath;
  final String fileType;
  final int size;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final DateTime uploadDate;

  PetDocument({
    required this.id,
    required this.petId,
    required this.title,
    this.description,
    required this.category,
    required this.fileUrl,
    required this.filePath,
    required this.fileType,
    required this.size,
    required this.tags,
    required this.metadata,
    required this.uploadDate,
  });

  PetDocument copyWith({
    String? title,
    String? description,
    String? category,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return PetDocument(
      id: id,
      petId: petId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      fileUrl: fileUrl,
      filePath: filePath,
      fileType: fileType,
      size: size,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      uploadDate: uploadDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'petId': petId,
    'title': title,
    'description': description,
    'category': category,
    'fileUrl': fileUrl,
    'filePath': filePath,
    'fileType': fileType,
    'size': size,
    'tags': tags,
    'metadata': metadata,
    'uploadDate': uploadDate.toIso8601String(),
  };

  factory PetDocument.fromJson(Map<String, dynamic> json) => PetDocument(
    id: json['id'],
    petId: json['petId'],
    title: json['title'],
    description: json['description'],
    category: json['category'],
    fileUrl: json['fileUrl'],
    filePath: json['filePath'],
    fileType: json['fileType'],
    size: json['size'],
    tags: List<String>.from(json['tags'] ?? []),
    metadata: json['metadata'] ?? {},
    uploadDate: DateTime.parse(json['uploadDate']),
  );
}

class DocumentException implements Exception {
  final String message;
  DocumentException(this.message);

  @override
  String toString() => message;
}
