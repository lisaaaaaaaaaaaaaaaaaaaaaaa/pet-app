import '../models/subscription.dart';

typedef PaymentHandler = Future<bool> Function(Subscription subscription);
