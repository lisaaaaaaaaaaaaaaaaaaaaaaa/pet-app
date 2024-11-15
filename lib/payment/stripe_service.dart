import 'package:stripe_payment/stripe_payment.dart';
import '../constants/app_constants.dart';

class StripeService {
  static String apiKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';
  static String secretKey = 'YOUR_STRIPE_SECRET_KEY';

  static Future<void> initialize() async {
    StripePayment.setOptions(
      StripeOptions(
        publishableKey: apiKey,
        merchantId: 'YOUR_MERCHANT_ID', // For Apple Pay
        androidPayMode: 'test', // Change to 'production' for release
      ),
    );
  }

  static Future<PaymentMethod> createPaymentMethod({
    required String number,
    required int expMonth,
    required int expYear,
    required String cvc,
  }) async {
    final paymentMethod = await StripePayment.createPaymentMethod(
      PaymentMethodRequest(
        card: CreditCard(
          number: number,
          expMonth: expMonth,
          expYear: expYear,
          cvc: cvc,
        ),
      ),
    );
    return paymentMethod;
  }

  static Future<PaymentIntentResult> confirmPayment({
    required String paymentIntentClientSecret,
    required PaymentMethod paymentMethod,
  }) async {
    final paymentResult = await StripePayment.confirmPaymentIntent(
      PaymentIntent(
        clientSecret: paymentIntentClientSecret,
        paymentMethodId: paymentMethod.id,
      ),
    );
    return paymentResult;
  }

  static Future<void> handlePaymentError(String error) async {
    throw Exception(error);
  }
}
