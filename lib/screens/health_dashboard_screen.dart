import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pet_provider.dart';

class HealthDashboardScreen extends StatelessWidget {
  const HealthDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PetProvider>(
      builder: (context, petProvider, child) {
        final selectedPet = petProvider.selectedPet;

        if (selectedPet == null) {
          return const Center(
            child: Text('Please select a pet'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Health Dashboard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              // Vital Signs
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vital Signs',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildVitalSign(
                            context,
                            icon: Icons.monitor_weight,
                            label: 'Weight',
                            value: '23.5 kg',
                          ),
                          _buildVitalSign(
                            context,
                            icon: Icons.favorite,
                            label: 'Heart Rate',
                            value: '80 bpm',
                          ),
                          _buildVitalSign(
                            context,
                            icon: Icons.thermostat,
                            label: 'Temperature',
                            value: '38.5°C',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Health Records
              Text(
                'Health Records',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildHealthRecordCard(
                context,
                icon: Icons.medical_services,
                title: 'Annual Checkup',
                date: 'March 15, 2024',
                status: 'Completed',
              ),
              const SizedBox(height: 8),
              _buildHealthRecordCard(
                context,
                icon: Icons.vaccines,
                title: 'Vaccination',
                date: 'April 1, 2024',
                status: 'Upcoming',
              ),
              const SizedBox(height: 24),
              // Medications
              Text(
                'Current Medications',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildMedicationCard(
                context,
                name: 'Heartworm Prevention',
                dosage: '1 tablet',
                frequency: 'Monthly',
                nextDue: 'April 15, 2024',
              ),
              const SizedBox(height: 8),
              _buildMedicationCard(
                context,
                name: 'Joint Supplement',
                dosage: '2 tablets',
                frequency: 'Daily',
                nextDue: 'Today',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVitalSign(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildHealthRecordCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String date,
    required String status,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(date),
        trailing: Chip(
          label: Text(
            status,
            style: TextStyle(
              color: status == 'Completed' ? Colors.green : Colors.orange,
            ),
          ),
        ),
        onTap: () {
          // Navigate to health record details
        },
      ),
    );
  }

  Widget _buildMedicationCard(
    BuildContext context, {
    required String name,
    required String dosage,
    required String frequency,
    required String nextDue,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dosage: $dosage'),
                      Text('Frequency: $frequency'),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Next Due:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      nextDue,
                      style: TextStyle(
                        color: nextDue == 'Today' ? Colors.red : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}