import 'package:flutter/material.dart';
import '../models/pet.dart';

class PetSummaryCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback? onTap;

  const PetSummaryCard({
    Key? key,
    required this.pet,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: pet.imageUrl != null 
                    ? NetworkImage(pet.imageUrl!) 
                    : null,
                child: pet.imageUrl == null 
                    ? const Icon(Icons.pets) 
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pet.breed} • ${pet.age} years old',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
