import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/payment_config.dart';

class TaxCalculationService {
  Future<Map<String, dynamic>> calculateTax({
    required String country,
    required String postalCode,
    required String state,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${PaymentConfig.apiUrl}/calculate-tax'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'country': country,
          'postalCode': postalCode,
          'state': state,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to calculate tax');
      }

      return json.decode(response.body);
    } catch (e) {
      throw Exception('Tax calculation failed: $e');
    }
  }
}
