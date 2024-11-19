import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sub_screens/health_tracking_screen.dart';
import 'sub_screens/exercise_screen.dart';
import 'sub_screens/medication_screen.dart';
import 'sub_screens/vet_appointments_screen.dart';
import 'sub_screens/weight_tracking_screen.dart';
import 'sub_screens/diet_tracking_screen.dart';
import 'components/wellness_card.dart';
import '../../providers/pet_provider.dart';

class WellnessScreen extends StatelessWidget {
  static const routeName = '/wellness';

  const WellnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pet = Provider.of<PetProvider>(context).selectedPet;
    
    if (pet == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please select a pet first'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${pet.name}\'s Wellness'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wellness Dashboard',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildWellnessSummary(context, pet),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                WellnessCard(
                  title: 'Health Records',
                  icon: Icons.favorite,
                  color: Colors.red.shade100,
                  onTap: () => Navigator.pushNamed(
                    context,
                    HealthTrackingScreen.routeName,
                  ),
                ),
                WellnessCard(
                  title: 'Exercise',
                  icon: Icons.directions_run,
                  color: Colors.green.shade100,
                  onTap: () => Navigator.pushNamed(
                    context,
                    ExerciseScreen.routeName,
                  ),
                ),
                WellnessCard(
                  title: 'Medications',
                  icon: Icons.medical_services,
                  color: Colors.blue.shade100,
                  onTap: () => Navigator.pushNamed(
                    context,
                    MedicationScreen.routeName,
                  ),
                ),
                WellnessCard(
                  title: 'Vet Visits',
                  icon: Icons.local_hospital,
                  color: Colors.purple.shade100,
                  onTap: () => Navigator.pushNamed(
                    context,
                    VetAppointmentsScreen.routeName,
                  ),
                ),
                WellnessCard(
                  title: 'Weight',
                  icon: Icons.monitor_weight,
                  color: Colors.orange.shade100,
                  onTap: () => Navigator.pushNamed(
                    context,
                    WeightTrackingScreen.routeName,
                  ),
                ),
                WellnessCard(
                  title: 'Diet',
                  icon: Icons.restaurant,
                  color: Colors.teal.shade100,
                  onTap: () => Navigator.pushNamed(
                    context,
                    DietTrackingScreen.routeName,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWellnessRecord(context),
        tooltip: 'Add Wellness Record',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildWellnessSummary(BuildContext context, Pet pet) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Updates',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildSummaryItem(
              context,
              'Last Vet Visit',
              pet.lastVetVisit?.toString() ?? 'No records',
              Icons.calendar_today,
            ),
            _buildSummaryItem(
              context,
              'Current Weight',
              '${pet.currentWeight?.toString() ?? 'No records'} kg',
              Icons.monitor_weight,
            ),
            _buildSummaryItem(
              context,
              'Next Medication',
              pet.nextMedication ?? 'None scheduled',
              Icons.medical_services,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddWellnessRecord(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Wellness Record',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Add Health Record'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, HealthTrackingScreen.routeName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.medical_services),
              title: const Text('Add Medication'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, MedicationScreen.routeName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.monitor_weight),
              title: const Text('Add Weight Record'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, WeightTrackingScreen.routeName);
              },
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }
}
