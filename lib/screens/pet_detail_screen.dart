import 'package:flutter/material.dart';
import '../models/pet.dart';

class PetDetailScreen extends StatelessWidget {
  final Pet pet;

  const PetDetailScreen({
    Key? key,
    required this.pet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pet.imageUrl != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    pet.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Breed', pet.breed),
            _buildDetailRow('Age', '${pet.age} years'),
            _buildDetailRow('Weight', '${pet.weight} lbs'),
            const SizedBox(height: 24),
            Text(
              'Health Records',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            // Add health records list here
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
