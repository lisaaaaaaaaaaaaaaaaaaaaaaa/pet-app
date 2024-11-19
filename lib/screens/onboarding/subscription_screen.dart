import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/common/primary_button.dart';
import '../../theme/app_theme.dart';

class SubscriptionScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onComplete;
  final Future<bool> Function() onBack;

  const SubscriptionScreen({
    Key? key,
    required this.onComplete,
    required this.onBack,
  }) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final bool _isSubscribed = false;
  bool _isLoading = false;

  Future<void> _handleComplete() async {
    setState(() => _isLoading = true);
    try {
      final subscriptionProvider = context.read<SubscriptionProvider>();
      await subscriptionProvider.startFreeTrial();
      
      widget.onComplete({
        'isSubscribed': true,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting trial: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSubscriptionCard(theme),
              const SizedBox(height: 32),
              PrimaryButton(
                onPressed: _isLoading ? null : _handleComplete,
                label: 'Start 7-Day Free Trial',
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => _showTermsDialog(context),
                  child: Text(
                    'View Terms & Conditions',
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildSubscriptionCard(ThemeData theme) {
    final features = [
      'Comprehensive health tracking',
      'Medication management & reminders',
      'Vaccination scheduling',
      'Health analytics & insights',
      'Unlimited pets',
      'Cloud backup',
      'Care sharing with family',
      'Priority support',
      'Custom health reports',
      'Vet consultation discounts',
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: AppTheme.primaryGreen,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Golden Years Complete',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ALL FEATURES INCLUDED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '\$10/month',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              '7-day free trial, cancel anytime',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              'Everything you need to care for your pet:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 20,
                    color: AppTheme.primaryGreen,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(feature),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscription Terms'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '• 7-day free trial for new subscribers\n'
                '• \$10 monthly subscription begins after trial\n'
                '• Cancel anytime during trial period\n'
                '• All features included with subscription\n'
                '• Automatic renewal unless cancelled\n'
                '• Data retained for 30 days after cancellation',
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
