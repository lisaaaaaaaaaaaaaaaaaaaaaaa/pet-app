import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class PetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final uuid = const Uuid();

  // Singleton pattern
  static final PetService _instance = PetService._internal();
  factory PetService() => _instance;
  PetService._internal();

  // Create a new pet
  Future<String> createPet({
    required String userId,
    required String name,
    required String species,
    required String breed,
    required DateTime dateOfBirth,
    required String gender,
    double? weight,
    String? color,
    String? microchipNumber,
    String? profileImage,
    List<String>? allergies,
    List<String>? conditions,
    Map<String, dynamic>? dietaryNeeds,
    String? veterinarianId,
    Map<String, dynamic>? insurance,
    List<String>? medications,
    Map<String, dynamic>? emergencyContact,
  }) async {
    try {
      final String petId = uuid.v4();
      final documentRef = _firestore.collection('pets').doc(petId);

      final petData = {
        'id': petId,
        'userId': userId,
        'name': name,
        'species': species,
        'breed': breed,
        'dateOfBirth': Timestamp.fromDate(dateOfBirth),
        'gender': gender,
        'weight': weight,
        'color': color,
        'microchipNumber': microchipNumber,
        'profileImage': profileImage,
        'allergies': allergies ?? [],
        'conditions': conditions ?? [],
        'dietaryNeeds': dietaryNeeds ?? {},
        'veterinarianId': veterinarianId,
        'insurance': insurance ?? {},
        'medications': medications ?? [],
        'emergencyContact': emergencyContact ?? {},
        'isActive': true,
        'lastCheckup': null,
        'nextCheckupDue': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        // Premium Features
        'wellnessScore': null,
        'subscriptionLevel': 'basic', // or 'premium'
        'lastAssessment': null,
      };

      await documentRef.set(petData);

      // Add pet reference to user's pets collection
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('pets')
          .doc(petId)
          .set({
        'petId': petId,
        'role': 'owner',
        'addedAt': FieldValue.serverTimestamp(),
      });

      return petId;
    } catch (e) {
      throw PetServiceException('Error creating pet: $e');
    }
  }
    // Update an existing pet
  Future<void> updatePet({
    required String petId,
    String? name,
    String? species,
    String? breed,
    DateTime? dateOfBirth,
    String? gender,
    double? weight,
    String? color,
    String? microchipNumber,
    String? profileImage,
    List<String>? allergies,
    List<String>? conditions,
    Map<String, dynamic>? dietaryNeeds,
    String? veterinarianId,
    Map<String, dynamic>? insurance,
    List<String>? medications,
    Map<String, dynamic>? emergencyContact,
    DateTime? lastCheckup,
    DateTime? nextCheckupDue,
    double? wellnessScore,
    String? subscriptionLevel,
  }) async {
    try {
      final documentRef = _firestore.collection('pets').doc(petId);

      final Map<String, dynamic> updateData = {};

      if (name != null) updateData['name'] = name;
      if (species != null) updateData['species'] = species;
      if (breed != null) updateData['breed'] = breed;
      if (dateOfBirth != null) updateData['dateOfBirth'] = Timestamp.fromDate(dateOfBirth);
      if (gender != null) updateData['gender'] = gender;
      if (weight != null) updateData['weight'] = weight;
      if (color != null) updateData['color'] = color;
      if (microchipNumber != null) updateData['microchipNumber'] = microchipNumber;
      if (profileImage != null) updateData['profileImage'] = profileImage;
      if (allergies != null) updateData['allergies'] = allergies;
      if (conditions != null) updateData['conditions'] = conditions;
      if (dietaryNeeds != null) updateData['dietaryNeeds'] = dietaryNeeds;
      if (veterinarianId != null) updateData['veterinarianId'] = veterinarianId;
      if (insurance != null) updateData['insurance'] = insurance;
      if (medications != null) updateData['medications'] = medications;
      if (emergencyContact != null) updateData['emergencyContact'] = emergencyContact;
      if (lastCheckup != null) updateData['lastCheckup'] = Timestamp.fromDate(lastCheckup);
      if (nextCheckupDue != null) updateData['nextCheckupDue'] = Timestamp.fromDate(nextCheckupDue);
      if (wellnessScore != null) updateData['wellnessScore'] = wellnessScore;
      if (subscriptionLevel != null) updateData['subscriptionLevel'] = subscriptionLevel;

      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await documentRef.update(updateData);
    } catch (e) {
      throw PetServiceException('Error updating pet: $e');
    }
  }

  // Premium Feature: Health Metrics
  Future<String> addHealthMetric({
    required String petId,
    required String name,
    required dynamic value,
    required DateTime recordedAt,
    String? notes,
    String? unit,
    List<String>? tags,
  }) async {
    try {
      final String metricId = uuid.v4();
      await _firestore
          .collection('pets')
          .doc(petId)
          .collection('healthMetrics')
          .doc(metricId)
          .set({
        'id': metricId,
        'name': name,
        'value': value,
        'recordedAt': Timestamp.fromDate(recordedAt),
        'notes': notes,
        'unit': unit,
        'tags': tags ?? [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      return metricId;
    } catch (e) {
      throw PetServiceException('Error adding health metric: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getHealthMetrics({
    required String petId,
    DateTime? startDate,
    DateTime? endDate,
    String? metricName,
  }) async {
    try {
      Query query = _firestore
          .collection('pets')
          .doc(petId)
          .collection('healthMetrics')
          .orderBy('recordedAt', descending: true);

      if (startDate != null) {
        query = query.where('recordedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('recordedAt',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      if (metricName != null) {
        query = query.where('name', isEqualTo: metricName);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw PetServiceException('Error fetching health metrics: $e');
    }
  }

  // Premium Feature: Pain Assessments
  Future<String> addPainAssessment({
    required String petId,
    required int painLevel,
    required String location,
    required String description,
    required DateTime date,
    List<String>? symptoms,
    String? medication,
    String? veterinaryConsult,
  }) async {
    try {
      final String assessmentId = uuid.v4();
      await _firestore
          .collection('pets')
          .doc(petId)
          .collection('painAssessments')
          .doc(assessmentId)
          .set({
        'id': assessmentId,
        'painLevel': painLevel,
        'location': location,
        'description': description,
        'date': Timestamp.fromDate(date),
        'symptoms': symptoms ?? [],
        'medication': medication,
        'veterinaryConsult': veterinaryConsult,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return assessmentId;
    } catch (e) {
      throw PetServiceException('Error adding pain assessment: $e');
    }
  }
    Future<List<Map<String, dynamic>>> getPainAssessments({
    required String petId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection('pets')
          .doc(petId)
          .collection('painAssessments')
          .orderBy('date', descending: true);

      if (startDate != null) {
        query = query.where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('date',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw PetServiceException('Error fetching pain assessments: $e');
    }
  }

  // Premium Feature: Behavior Tracking
  Future<String> addBehaviorLog({
    required String petId,
    required String behavior,
    required String context,
    required DateTime date,
    String? trigger,
    String? resolution,
    List<String>? interventions,
    bool wasSuccessful = false,
  }) async {
    try {
      final String logId = uuid.v4();
      await _firestore
          .collection('pets')
          .doc(petId)
          .collection('behaviorLogs')
          .doc(logId)
          .set({
        'id': logId,
        'behavior': behavior,
        'context': context,
        'date': Timestamp.fromDate(date),
        'trigger': trigger,
        'resolution': resolution,
        'interventions': interventions ?? [],
        'wasSuccessful': wasSuccessful,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return logId;
    } catch (e) {
      throw PetServiceException('Error adding behavior log: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getBehaviorLogs({
    required String petId,
    DateTime? startDate,
    DateTime? endDate,
    String? behaviorType,
  }) async {
    try {
      Query query = _firestore
          .collection('pets')
          .doc(petId)
          .collection('behaviorLogs')
          .orderBy('date', descending: true);

      if (startDate != null) {
        query = query.where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('date',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      if (behaviorType != null) {
        query = query.where('behavior', isEqualTo: behaviorType);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw PetServiceException('Error fetching behavior logs: $e');
    }
  }

  // Premium Feature: Care Team Management
  Future<String> addCareTeamMember({
    required String petId,
    required String name,
    required String role,
    required List<String> permissions,
    String? email,
    String? phone,
    Map<String, bool>? accessLevels,
  }) async {
    try {
      final String memberId = uuid.v4();
      await _firestore
          .collection('pets')
          .doc(petId)
          .collection('careTeam')
          .doc(memberId)
          .set({
        'id': memberId,
        'name': name,
        'role': role,
        'permissions': permissions,
        'email': email,
        'phone': phone,
        'accessLevels': accessLevels ?? {},
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return memberId;
    } catch (e) {
      throw PetServiceException('Error adding care team member: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCareTeamMembers(String petId) async {
    try {
      final querySnapshot = await _firestore
          .collection('pets')
          .doc(petId)
          .collection('careTeam')
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw PetServiceException('Error fetching care team members: $e');
    }
  }

  Future<void> updateCareTeamMember({
    required String petId,
    required String memberId,
    String? name,
    String? role,
    List<String>? permissions,
    String? email,
    String? phone,
    Map<String, bool>? accessLevels,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};

      if (name != null) updateData['name'] = name;
      if (role != null) updateData['role'] = role;
      if (permissions != null) updateData['permissions'] = permissions;
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['phone'] = phone;
      if (accessLevels != null) updateData['accessLevels'] = accessLevels;
      if (isActive != null) updateData['isActive'] = isActive;

      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('pets')
          .doc(petId)
          .collection('careTeam')
          .doc(memberId)
          .update(updateData);
    } catch (e) {
      throw PetServiceException('Error updating care team member: $e');
    }
  }
    // Premium Feature: Document Management
  Future<String> addDocument({
    required String petId,
    required String name,
    required String type,
    required String url,
    String? description,
    DateTime? expiryDate,
    List<String>? tags,
    bool isSharedWithVet = false,
    String? uploadedBy,
  }) async {
    try {
      final String documentId = uuid.v4();
      await _firestore
          .collection('pets')
          .doc(petId)
          .collection('documents')
          .doc(documentId)
          .set({
        'id': documentId,
        'name': name,
        'type': type,
        'url': url,
        'description': description,
        'uploadedAt': FieldValue.serverTimestamp(),
        'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate) : null,
        'tags': tags ?? [],
        'isSharedWithVet': isSharedWithVet,
        'uploadedBy': uploadedBy,
        'isActive': true,
      });

      return documentId;
    } catch (e) {
      throw PetServiceException('Error adding document: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getDocuments({
    required String petId,
    String? type,
    bool? isSharedWithVet,
    bool includeExpired = false,
  }) async {
    try {
      Query query = _firestore
          .collection('pets')
          .doc(petId)
          .collection('documents')
          .where('isActive', isEqualTo: true);

      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }

      if (isSharedWithVet != null) {
        query = query.where('isSharedWithVet', isEqualTo: isSharedWithVet);
      }

      if (!includeExpired) {
        query = query.where('expiryDate',
            isGreaterThan: Timestamp.fromDate(DateTime.now()));
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw PetServiceException('Error fetching documents: $e');
    }
  }

  // Premium Feature: Wellness Score Calculation
  Future<void> updateWellnessScore(String petId) async {
    try {
      // Fetch required data
      final pet = await getPet(petId);
      final healthMetrics = await getHealthMetrics(petId: petId);
      final painAssessments = await getPainAssessments(petId: petId);
      final behaviorLogs = await getBehaviorLogs(petId: petId);

      // Calculate wellness score components
      double healthScore = _calculateHealthScore(healthMetrics);
      double painScore = _calculatePainScore(painAssessments);
      double behaviorScore = _calculateBehaviorScore(behaviorLogs);
      double ageScore = _calculateAgeScore(pet);

      // Calculate overall wellness score (0-100)
      double wellnessScore = (healthScore + painScore + behaviorScore + ageScore) / 4;

      // Update pet document with new wellness score
      await _firestore.collection('pets').doc(petId).update({
        'wellnessScore': wellnessScore,
        'lastAssessment': FieldValue.serverTimestamp(),
        'scoreComponents': {
          'health': healthScore,
          'pain': painScore,
          'behavior': behaviorScore,
          'age': ageScore,
        },
      });
    } catch (e) {
      throw PetServiceException('Error updating wellness score: $e');
    }
  }

  // Helper methods for wellness score calculation
  double _calculateHealthScore(List<Map<String, dynamic>> healthMetrics) {
    // Implement health score calculation logic
    // Consider factors like weight, activity level, vital signs, etc.
    return 0.0; // Placeholder
  }

  double _calculatePainScore(List<Map<String, dynamic>> painAssessments) {
    // Implement pain score calculation logic
    // Consider pain levels, frequency, and trends
    return 0.0; // Placeholder
  }

  double _calculateBehaviorScore(List<Map<String, dynamic>> behaviorLogs) {
    // Implement behavior score calculation logic
    // Consider positive vs negative behaviors, improvements, etc.
    return 0.0; // Placeholder
  }

  double _calculateAgeScore(Map<String, dynamic> pet) {
    // Implement age score calculation logic
    // Consider species-specific age factors
    return 0.0; // Placeholder
  }

  // Premium Feature: Analytics
  Future<Map<String, dynamic>> getAnalytics({
    required String petId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Fetch all relevant data
      final healthMetrics = await getHealthMetrics(
        petId: petId,
        startDate: startDate,
        endDate: endDate,
      );

      final painAssessments = await getPainAssessments(
        petId: petId,
        startDate: startDate,
        endDate: endDate,
      );

      final behaviorLogs = await getBehaviorLogs(
        petId: petId,
        startDate: startDate,
        endDate: endDate,
      );

      // Calculate analytics
      return {
        'healthTrends': _calculateHealthTrends(healthMetrics),
        'painTrends': _calculatePainTrends(painAssessments),
        'behaviorTrends': _calculateBehaviorTrends(behaviorLogs),
        'recommendations': _generateRecommendations(
          healthMetrics,
          painAssessments,
          behaviorLogs,
        ),
      };
    } catch (e) {
      throw PetServiceException('Error generating analytics: $e');
    }
  }
    // Analytics Helper Methods
  Map<String, dynamic> _calculateHealthTrends(
      List<Map<String, dynamic>> healthMetrics) {
    try {
      return {
        'weightTrend': _calculateMetricTrend(healthMetrics, 'weight'),
        'activityTrend': _calculateMetricTrend(healthMetrics, 'activity'),
        'vitalsTrend': _calculateVitalsTrends(healthMetrics),
        'abnormalReadings': _identifyAbnormalReadings(healthMetrics),
      };
    } catch (e) {
      throw PetServiceException('Error calculating health trends: $e');
    }
  }

  Map<String, dynamic> _calculatePainTrends(
      List<Map<String, dynamic>> painAssessments) {
    try {
      return {
        'averagePainLevel': _calculateAveragePain(painAssessments),
        'commonLocations': _identifyCommonPainLocations(painAssessments),
        'painFrequency': _calculatePainFrequency(painAssessments),
        'treatmentEffectiveness': _analyzeTreatmentEffectiveness(painAssessments),
      };
    } catch (e) {
      throw PetServiceException('Error calculating pain trends: $e');
    }
  }

  Map<String, dynamic> _calculateBehaviorTrends(
      List<Map<String, dynamic>> behaviorLogs) {
    try {
      return {
        'commonBehaviors': _identifyCommonBehaviors(behaviorLogs),
        'behaviorChanges': _analyzeBehaviorChanges(behaviorLogs),
        'successRate': _calculateInterventionSuccessRate(behaviorLogs),
        'triggers': _identifyCommonTriggers(behaviorLogs),
      };
    } catch (e) {
      throw PetServiceException('Error calculating behavior trends: $e');
    }
  }

  List<String> _generateRecommendations(
    List<Map<String, dynamic>> healthMetrics,
    List<Map<String, dynamic>> painAssessments,
    List<Map<String, dynamic>> behaviorLogs,
  ) {
    try {
      List<String> recommendations = [];

      // Health-based recommendations
      if (_hasAbnormalReadings(healthMetrics)) {
        recommendations.add('Consider scheduling a vet check-up for abnormal health readings');
      }

      // Pain-based recommendations
      if (_hasPainIncrease(painAssessments)) {
        recommendations.add('Discuss pain management options with your veterinarian');
      }

      // Behavior-based recommendations
      if (_hasNegativeBehaviorTrend(behaviorLogs)) {
        recommendations.add('Consider consulting with a pet behaviorist');
      }

      return recommendations;
    } catch (e) {
      throw PetServiceException('Error generating recommendations: $e');
    }
  }

  // Utility Methods for Analytics
  double _calculateMetricTrend(List<Map<String, dynamic>> metrics, String metricName) {
    // Implement trend calculation logic
    return 0.0; // Placeholder
  }

  Map<String, dynamic> _calculateVitalsTrends(List<Map<String, dynamic>> metrics) {
    // Implement vitals trend calculation
    return {}; // Placeholder
  }

  List<Map<String, dynamic>> _identifyAbnormalReadings(
      List<Map<String, dynamic>> metrics) {
    // Implement abnormal reading identification
    return []; // Placeholder
  }

  double _calculateAveragePain(List<Map<String, dynamic>> painAssessments) {
    if (painAssessments.isEmpty) return 0.0;
    
    int total = painAssessments.fold(0, 
        (sum, assessment) => sum + (assessment['painLevel'] as int));
    return total / painAssessments.length;
  }

  List<String> _identifyCommonPainLocations(
      List<Map<String, dynamic>> painAssessments) {
    // Implement common pain locations logic
    return []; // Placeholder
  }

  Map<String, int> _calculatePainFrequency(
      List<Map<String, dynamic>> painAssessments) {
    // Implement pain frequency calculation
    return {}; // Placeholder
  }

  Map<String, double> _analyzeTreatmentEffectiveness(
      List<Map<String, dynamic>> painAssessments) {
    // Implement treatment effectiveness analysis
    return {}; // Placeholder
  }

  bool _hasAbnormalReadings(List<Map<String, dynamic>> healthMetrics) {
    // Implement abnormal readings check
    return false; // Placeholder
  }

  bool _hasPainIncrease(List<Map<String, dynamic>> painAssessments) {
    // Implement pain increase check
    return false; // Placeholder
  }

  bool _hasNegativeBehaviorTrend(List<Map<String, dynamic>> behaviorLogs) {
    // Implement negative behavior trend check
    return false; // Placeholder
  }

  // Premium Feature: Subscription Management
  Future<void> updateSubscriptionStatus({
    required String petId,
    required String subscriptionLevel,
    required DateTime expiryDate,
  }) async {
    try {
      await _firestore.collection('pets').doc(petId).update({
        'subscriptionLevel': subscriptionLevel,
        'subscriptionExpiry': Timestamp.fromDate(expiryDate),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw PetServiceException('Error updating subscription status: $e');
    }
  }

  Future<bool> isPremiumSubscriber(String petId) async {
    try {
      final pet = await getPet(petId);
      return pet['subscriptionLevel'] == 'premium' &&
          (pet['subscriptionExpiry'] as Timestamp)
              .toDate()
              .isAfter(DateTime.now());
    } catch (e) {
      throw PetServiceException('Error checking subscription status: $e');
    }
  }
}

class PetServiceException implements Exception {
  final String message;
  PetServiceException(this.message);

  @override
  String toString() => message;
}