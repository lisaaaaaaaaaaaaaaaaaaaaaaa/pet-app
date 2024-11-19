import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/subscription.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGrey,
      body: SafeArea(
        child: Column(
          children: [
            // Top Section with Logo/Image
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.pets,
                        size: 80,
                        color: AppColors.accentGreen,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Golden Years',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppColors.primaryGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pet Healthcare Management',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.secondaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Subscription Plan Section
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Subscription Plan',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildFeatureRow(Icons.pets, 'Unlimited Pet Profiles'),
                    _buildFeatureRow(Icons.monitor_heart, 'Health Tracking & Analytics'),
                    _buildFeatureRow(Icons.calendar_month, 'Vet Appointment Scheduling'),
                    _buildFeatureRow(Icons.notifications_active, 'Medication Reminders'),
                    _buildFeatureRow(Icons.support_agent, '24/7 Vet Support'),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/auth'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGreen,
                          foregroundColor: AppColors.textLight,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Subscribe Now - \$9.99/month',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/auth'),
                      child: Text(
                        'Already have an account? Sign in',
                        style: TextStyle(
                          color: AppColors.textLight.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.accentGreen,
            size: 24,
          ),
          const SizedBox(width: 16),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
