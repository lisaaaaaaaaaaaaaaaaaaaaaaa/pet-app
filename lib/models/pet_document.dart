import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PetDocument {
  final String id;
  final String petId;
  final String name;
  final String type;
  final String category;
  final DateTime date;
  final String? fileUrl;
  final String? thumbnailUrl;
  final String? notes;
  final bool isArchived;
  final List<String> tags;
  // Enhanced fields
  final String? createdBy;
  final DateTime createdAt;
  final bool isPremium;
  final Map<String, dynamic>? metadata;
  final String? provider;
  final DateTime? expirationDate;
  final bool requiresRenewal;
  final String? documentNumber;
  final Map<String, dynamic>? verificationDetails;
  final List<String>? sharedWith;
  final DocumentStatus status;
  final String? location;
  final Map<String, dynamic>? customFields;
  final bool isConfidential;

  PetDocument({
    required this.id,
    required this.petId,
    required this.name,
    required this.type,
    required this.category,
    required this.date,
    this.fileUrl,
    this.thumbnailUrl,
    this.notes,
    this.isArchived = false,
    this.tags = const [],
    this.createdBy,
    DateTime? createdAt,
    this.isPremium = false,
    this.metadata,
    this.provider,
    this.expirationDate,
    this.requiresRenewal = false,
    this.documentNumber,
    this.verificationDetails,
    this.sharedWith,
    this.status = DocumentStatus.active,
    this.location,
    this.customFields,
    this.isConfidential = false,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'name': name,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
      'fileUrl': fileUrl,
      'thumbnailUrl': thumbnailUrl,
      'notes': notes,
      'isArchived': isArchived,
      'tags': tags,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'isPremium': isPremium,
      'metadata': metadata,
      'provider': provider,
      'expirationDate': expirationDate?.toIso8601String(),
      'requiresRenewal': requiresRenewal,
      'documentNumber': documentNumber,
      'verificationDetails': verificationDetails,
      'sharedWith': sharedWith,
      'status': status.toString(),
      'location': location,
      'customFields': customFields,
      'isConfidential': isConfidential,
    };
  }

  factory PetDocument.fromJson(Map<String, dynamic> json) {
    return PetDocument(
      id: json['id'],
      petId: json['petId'],
      name: json['name'],
      type: json['type'],
      category: json['category'],
      date: DateTime.parse(json['date']),
      fileUrl: json['fileUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      notes: json['notes'],
      isArchived: json['isArchived'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      isPremium: json['isPremium'] ?? false,
      metadata: json['metadata'],
      provider: json['provider'],
      expirationDate: json['expirationDate'] != null 
          ? DateTime.parse(json['expirationDate'])
          : null,
      requiresRenewal: json['requiresRenewal'] ?? false,
      documentNumber: json['documentNumber'],
      verificationDetails: json['verificationDetails'],
      sharedWith: json['sharedWith'] != null 
          ? List<String>.from(json['sharedWith'])
          : null,
      status: DocumentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => DocumentStatus.active,
      ),
      location: json['location'],
      customFields: json['customFields'],
      isConfidential: json['isConfidential'] ?? false,
    );
  }

  bool isExpired() => 
      expirationDate != null && expirationDate!.isBefore(DateTime.now());

  bool needsRenewalSoon() {
    if (expirationDate == null) return false;
    final daysUntilExpiration = expirationDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiration <= 30;
  }

  bool hasTag(String tag) => tags.contains(tag.toLowerCase());

  bool isSharedWith(String userId) => 
      sharedWith?.contains(userId) ?? false;

  bool canView(String userId) {
    if (!isConfidential) return true;
    return createdBy == userId || isSharedWith(userId);
  }

  bool canEdit(String userId) => 
      createdBy == userId || !isPremium;

  bool get isRecent => 
      date.isAfter(DateTime.now().subtract(const Duration(days: 7)));

  String getFormattedDate() => 
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> getVerificationStatus() {
    if (verificationDetails == null) return {};
    
    return {
      'isVerified': verificationDetails!['isVerified'] ?? false,
      'verifiedBy': verificationDetails!['verifiedBy'],
      'verificationDate': verificationDetails!['verificationDate'],
      'verificationMethod': verificationDetails!['verificationMethod'],
    };
  }

  bool requiresAttention() =>
      status == DocumentStatus.pending || 
      status == DocumentStatus.needsUpdate || 
      isExpired() || 
      needsRenewalSoon();

  String getDocumentPath() {
    if (fileUrl == null) return '';
    final parts = fileUrl!.split('/');
    return parts.length > 1 ? parts.sublist(1).join('/') : fileUrl!;
  }
}

enum DocumentStatus {
  active,
  pending,
  expired,
  archived,
  needsUpdate,
  verified
}

extension DocumentStatusExtension on DocumentStatus {
  String get displayName {
    switch (this) {
      case DocumentStatus.active: return 'Active';
      case DocumentStatus.pending: return 'Pending';
      case DocumentStatus.expired: return 'Expired';
      case DocumentStatus.archived: return 'Archived';
      case DocumentStatus.needsUpdate: return 'Needs Update';
      case DocumentStatus.verified: return 'Verified';
    }
  }

  bool get requiresAction =>
      this == DocumentStatus.pending || 
      this == DocumentStatus.needsUpdate || 
      this == DocumentStatus.expired;
}
