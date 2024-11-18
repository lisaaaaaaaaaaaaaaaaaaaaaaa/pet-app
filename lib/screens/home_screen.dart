import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_state_provider.dart';  // Updated import
import '../providers/pet_provider.dart';
import '../models/pet.dart'; 
import '../theme/app_theme.dart';
import '../widgets/pet_profile_card.dart';
import '../widgets/stats_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<StatItem> _buildStatsForPet(Pet pet) {
    return [
      StatItem(
        label: 'Weight',
        value: '${pet.weight} kg',
        icon: Icons.monitor_weight_outlined,
        color: AppTheme.primaryGreen,
      ),
      StatItem(
        label: 'Age',
        value: '${pet.age} yrs',
        icon: Icons.cake_outlined,
        color: AppTheme.secondaryGreen,
      ),
      StatItem(
        label: 'Medications',
        value: '${pet.medications?.length ?? 0}',
        icon: Icons.medication_outlined,
        color: Colors.orange,
      ),
      StatItem(
        label: 'Appointments',
        value: '${pet.appointments?.length ?? 0}',
        icon: Icons.calendar_today_outlined,
        color: Colors.blue,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Consumer<PetProvider>(
        builder: (context, petProvider, child) {
          final pet = petProvider.selectedPet;
          
          if (pet == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No pet selected. Add a pet to get started!'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/add-pet'),
                    child: const Text('Add Pet'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              PetProfileCard(
                pet: pet,
                onEdit: () => Navigator.pushNamed(context, '/edit-pet'),
                onViewMedical: () => Navigator.pushNamed(context, '/medical-records'),
                onViewAppointments: () => Navigator.pushNamed(context, '/appointments'),
                onViewVaccinations: () => Navigator.pushNamed(context, '/vaccinations'),
              ),
              const SizedBox(height: 16.0),
              StatsGrid(
                items: _buildStatsForPet(pet),
                crossAxisCount: 2,
                spacing: 16,
              ),
            ],
          );
        },
      ),
    );
  }
}