import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pet_provider.dart';
import '../services/auth_provider.dart';
import '../services/subscription_manager.dart';
import '../widgets/pet_summary_card.dart';
import '../constants/subscription_plans.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final subscriptionManager = Provider.of<SubscriptionManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Golden Years'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (subscriptionManager.currentSubscription == null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/payment',
                    arguments: {
                      'subscription': SubscriptionPlans.premium,
                    },
                  );
                },
                child: const Text('Upgrade to Premium - \$10/month'),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: petProvider.pets.length,
              itemBuilder: (context, index) {
                final pet = petProvider.pets[index];
                return PetSummaryCard(
                  pet: pet,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/pet-detail',
                    arguments: pet,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new pet functionality
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
