import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/pet_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/upcoming_reminders.dart';
import '../widgets/health_stats_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Golden Years',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.notifications_outlined, color: AppTheme.primaryColor),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.settings_outlined, color: AppTheme.primaryColor),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Pet Cards
              SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    PetCard(
                      name: 'Max',
                      onTap: () {},
                    ),
                    PetCard(
                      name: 'Add Pet',
                      isAddCard: true,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        QuickActionCard(
                          icon: Icons.medical_services_outlined,
                          title: 'Schedule\nVet Visit',
                          onTap: () {},
                          backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                        ),
                        QuickActionCard(
                          icon: Icons.medication_outlined,
                          title: 'Medications',
                          onTap: () {},
                          backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                        ),
                        QuickActionCard(
                          icon: Icons.content_cut,
                          title: 'Grooming',
                          onTap: () {},
                          backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                        ),
                        QuickActionCard(
                          icon: Icons.restaurant_outlined,
                          title: 'Food & Diet',
                          onTap: () {},
                          backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Upcoming Reminders
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Upcoming Reminders',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'See All',
                            style: TextStyle(color: AppTheme.primaryColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ReminderCard(
                      title: 'Vet Appointment',
                      description: 'Annual checkup with Dr. Smith',
                      date: 'Tomorrow',
                      icon: Icons.medical_services_outlined,
                      backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                    ),
                    const SizedBox(height: 12),
                    ReminderCard(
                      title: 'Medication Due',
                      description: 'Heartworm Prevention',
                      date: 'Today',
                      icon: Icons.medication_outlined,
                      backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                    ),
                    const SizedBox(height: 12),
                    ReminderCard(
                      title: 'Grooming Session',
                      description: 'Professional grooming',
                      date: 'In 4 days',
                      icon: Icons.content_cut,
                      backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: AppTheme.primaryColor),
            selectedIcon: Icon(Icons.home, color: AppTheme.accentColor),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline, color: AppTheme.primaryColor),
            selectedIcon: Icon(Icons.favorite, color: AppTheme.accentColor),
            label: 'Health',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined, color: AppTheme.primaryColor),
            selectedIcon: Icon(Icons.pets, color: AppTheme.accentColor),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: AppTheme.primaryColor),
            selectedIcon: Icon(Icons.person, color: AppTheme.accentColor),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class ReminderCard extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final IconData icon;
  final Color backgroundColor;

  const ReminderCard({
    Key? key,
    required this.title,
    required this.description,
    required this.date,
    required this.icon,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.neutralGrey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              date,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}