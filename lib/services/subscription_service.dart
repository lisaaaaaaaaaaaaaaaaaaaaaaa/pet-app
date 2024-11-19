import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createSubscription() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('subscriptions').doc(user.uid).set({
      'userId': user.uid,
      'productId': 'prod_REom1syfyqRAwx',
      'status': 'active',
      'startDate': FieldValue.serverTimestamp(),
      'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
      'features': [
        'Full access to all pet care features',
        'Unlimited pet profiles',
        'Appointment scheduling',
        'Health record tracking',
        'Medication reminders',
        '24/7 customer support'
      ]
    });
  }
}
