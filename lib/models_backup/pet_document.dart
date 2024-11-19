// lib/models/pet_document.dart


class PetDocument {
  final String id;
  final String petId;
  final String name;
  final String type;
  final String url;
  final String? description;
  final DateTime dateAdded;
  final DateTime? expiryDate;
  final List<String> tags;
  final bool isSharedWithVet;
  final String uploadedBy;
  final int fileSize;
  final String fileType;
  final bool isActive;
  final Map<String, dynamic>? metadata;
  final List<String> sharedWith;
  // New premium features
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final bool isConfidential;
  final List<String> accessHistory;
  final Map<String, dynamic> permissions;
  final String documentStatus;
  final String? relatedRecordId;
  final List<String> categories;
  final Map<String, dynamic> customFields;
  final String version;
  final String? previousVersionId;
  final bool requiresSignature;
  final Map<String, dynamic>? signatures;
  final bool isEncrypted;
  final String? encryptionDetails;
  final DateTime? lastAccessed;
  final int accessCount;
  final List<String> comments;
  final bool isTemplate;
  final List<String> relatedDocuments;
  final Map<String, dynamic> auditTrail;
  final bool requiresReview;
  final DateTime? reviewDate;
  final String? reviewedBy;
  final List<String> keywords;
  final Map<String, dynamic> documentMetrics;

  PetDocument({
    required this.id,
    required this.petId,
    required this.name,
    required this.type,
    required this.url,
    this.description,
    required this.dateAdded,
    this.expiryDate,
    this.tags = const [],
    this.isSharedWithVet = false,
    required this.uploadedBy,
    required this.fileSize,
    required this.fileType,
    this.isActive = true,
    this.metadata,
    this.sharedWith = const [],
    // New premium features
    this.verifiedBy,
    this.verifiedAt,
    this.isConfidential = false,
    this.accessHistory = const [],
    this.permissions = const {},
    this.documentStatus = 'active',
    this.relatedRecordId,
    this.categories = const [],
    this.customFields = const {},
    this.version = '1.0',
    this.previousVersionId,
    this.requiresSignature = false,
    this.signatures,
    this.isEncrypted = false,
    this.encryptionDetails,
    this.lastAccessed,
    this.accessCount = 0,
    this.comments = const [],
    this.isTemplate = false,
    this.relatedDocuments = const [],
    this.auditTrail = const {},
    this.requiresReview = false,
    this.reviewDate,
    this.reviewedBy,
    this.keywords = const [],
    this.documentMetrics = const {},
  });

  // Existing methods remain the same...

  Map<String, dynamic> toJson() {
    return {
      // Existing fields...
      'verifiedBy': verifiedBy,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'isConfidential': isConfidential,
      'accessHistory': accessHistory,
      'permissions': permissions,
      'documentStatus': documentStatus,
      'relatedRecordId': relatedRecordId,
      'categories': categories,
      'customFields': customFields,
      'version': version,
      'previousVersionId': previousVersionId,
      'requiresSignature': requiresSignature,
      'signatures': signatures,
      'isEncrypted': isEncrypted,
      'encryptionDetails': encryptionDetails,
      'lastAccessed': lastAccessed?.toIso8601String(),
      'accessCount': accessCount,
      'comments': comments,
      'isTemplate': isTemplate,
      'relatedDocuments': relatedDocuments,
      'auditTrail': auditTrail,
      'requiresReview': requiresReview,
      'reviewDate': reviewDate?.toIso8601String(),
      'reviewedBy': reviewedBy,
      'keywords': keywords,
      'documentMetrics': documentMetrics,
    };
  }

  factory PetDocument.fromJson(Map<String, dynamic> json) {
    return PetDocument(
      // Existing fields...
      verifiedBy: json['verifiedBy'],
      verifiedAt: json['verifiedAt'] != null 
          ? DateTime.parse(json['verifiedAt']) 
          : null,
      isConfidential: json['isConfidential'] ?? false,
      accessHistory: List<String>.from(json['accessHistory'] ?? []),
      permissions: Map<String, dynamic>.from(json['permissions'] ?? {}),
      documentStatus: json['documentStatus'] ?? 'active',
      relatedRecordId: json['relatedRecordId'],
      categories: List<String>.from(json['categories'] ?? []),
      customFields: Map<String, dynamic>.from(json['customFields'] ?? {}),
      version: json['version'] ?? '1.0',
      previousVersionId: json['previousVersionId'],
      requiresSignature: json['requiresSignature'] ?? false,
      signatures: json['signatures'],
      isEncrypted: json['isEncrypted'] ?? false,
      encryptionDetails: json['encryptionDetails'],
      lastAccessed: json['lastAccessed'] != null 
          ? DateTime.parse(json['lastAccessed']) 
          : null,
      accessCount: json['accessCount'] ?? 0,
      comments: List<String>.from(json['comments'] ?? []),
      isTemplate: json['isTemplate'] ?? false,
      relatedDocuments: List<String>.from(json['relatedDocuments'] ?? []),
      auditTrail: Map<String, dynamic>.from(json['auditTrail'] ?? {}),
      requiresReview: json['requiresReview'] ?? false,
      reviewDate: json['reviewDate'] != null 
          ? DateTime.parse(json['reviewDate']) 
          : null,
      reviewedBy: json['reviewedBy'],
      keywords: List<String>.from(json['keywords'] ?? []),
      documentMetrics: Map<String, dynamic>.from(json['documentMetrics'] ?? {}),
    );
  }

  // Additional helper methods
  bool isVerified() {
    return verifiedBy != null && verifiedAt != null;
  }

  bool needsReview() {
    return requiresReview && 
           (reviewDate == null || DateTime.now().isAfter(reviewDate!));
  }

  bool hasValidSignatures() {
    return !requiresSignature || 
           (signatures != null && signatures!.isNotEmpty);
  }

  bool canAccess(String userId) {
    if (!isConfidential) return true;
    return permissions[userId]?['canAccess'] ?? false;
  }

  bool canEdit(String userId) {
    return permissions[userId]?['canEdit'] ?? false;
  }

  bool isLatestVersion() {
    return !relatedDocuments.any((docId) => 
        docId.startsWith('${id}_v') && 
        docId.compareTo('${id}_v$version') > 0);
  }

  List<String> getAccessibleUsers() {
    return permissions.entries
        .where((entry) => entry.value['canAccess'] == true)
        .map((entry) => entry.key)
        .toList();
  }

  void logAccess(String userId) {
    accessHistory.add('$userId:${DateTime.now().toIso8601String()}');
  }

  bool requiresAction() {
    return requiresSignature && !hasValidSignatures() ||
           requiresReview && needsReview();
  }
}

// Existing enums remain the same...

enum DocumentStatus {
  draft,
  active,
  archived,
  expired,
  pending_review,
  pending_signature,
  deleted
}

enum DocumentPermission {
  view,
  edit,
  share,
  delete,
  sign,
  review,
  download
}