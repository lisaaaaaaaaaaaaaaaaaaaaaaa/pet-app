import 'package:flutter/material.dart';
import '../../services/stripe_service.dart';
import '../../services/tax_calculation_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stripeService = StripeService();
  final _taxService = TaxCalculationService();
  String? _country;
  String? _postalCode;
  String? _state;
  bool _isLoading = false;
  Map<String, dynamic>? _taxCalculation;

  Future<void> _calculateTax() async {
    if (_country != null && _postalCode != null && _state != null) {
      try {
        final calculation = await _taxService.calculateTax(
          country: _country!,
          postalCode: _postalCode!,
          state: _state!,
        );
        setState(() => _taxCalculation = calculation);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error calculating tax: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildPriceDisplay() {
    if (_taxCalculation == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('Enter location for tax calculation'),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price Breakdown',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subscription:'),
                Text('\$10.00'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tax:'),
                Text('\$${(_taxCalculation!['tax_amount'] / 100).toStringAsFixed(2)}'),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total:',
                    style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '\$${(_taxCalculation!['total_amount'] / 100).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscribe to Golden Years')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tax Information',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _country,
                        decoration: const InputDecoration(
                          labelText: 'Country',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'US', child: Text('United States')),
                          DropdownMenuItem(value: 'CA', child: Text('Canada')),
                        ],
                        onChanged: (value) {
                          setState(() => _country = value);
                          _calculateTax();
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Postal Code',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() => _postalCode = value);
                          _calculateTax();
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'State/Province',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() => _state = value);
                          _calculateTax();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildPriceDisplay(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading || _taxCalculation == null
                    ? null
                    : () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          setState(() => _isLoading = true);
                          try {
                            await _stripeService.initPayment(
                              country: _country!,
                              postalCode: _postalCode!,
                              state: _state!,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Subscription successful!')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Subscribe Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
