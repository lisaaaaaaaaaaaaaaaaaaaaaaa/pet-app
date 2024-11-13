import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'common/custom_card.dart';

class DietTrackerCard extends StatelessWidget {
  final String petName;
  final String foodType;
  final double dailyAmount;
  final String unit;
  final int mealsPerDay;
  final double progress;
  final List<MealLog>? recentMeals;
  final VoidCallback? onAddMeal;
  final VoidCallback? onViewDetails;
  final bool isLoading;
  final String? nextMealTime;
  final Map<String, dynamic>? nutritionInfo;

  const DietTrackerCard({
    Key? key,
    required this.petName,
    required this.foodType,
    required this.dailyAmount,
    required this.unit,
    required this.mealsPerDay,
    required this.progress,
    this.recentMeals,
    this.onAddMeal,
    this.onViewDetails,
    this.isLoading = false,
    this.nextMealTime,
    this.nutritionInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onViewDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diet Tracker',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    petName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.secondaryGreen,
                        ),
                  ),
                ],
              ),
              if (onAddMeal != null)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppTheme.primaryGreen,
                  onPressed: isLoading ? null : onAddMeal,
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            Row(
              children: [
                Expanded(
                  child: _buildInfoColumn(
                    context,
                    'Food Type',
                    foodType,
                    Icons.restaurant,
                  ),
                ),
                Expanded(
                  child: _buildInfoColumn(
                    context,
                    'Daily Amount',
                    '$dailyAmount $unit',
                    Icons.scale,
                  ),
                ),
                Expanded(
                  child: _buildInfoColumn(
                    context,
                    'Meals/Day',
                    mealsPerDay.toString(),
                    Icons.access_time,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (nextMealTime != null) ...[
              Text(
                'Next Meal: $nextMealTime',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
            ],
            _buildProgressBar(context),
            if (nutritionInfo != null) ...[
              const SizedBox(height: 16),
              _buildNutritionInfo(context),
            ],
            if (recentMeals != null && recentMeals!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Recent Meals',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.secondaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              _buildRecentMeals(context),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildInfoColumn(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.neutralGrey,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.neutralGrey,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Progress',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.lightBlue.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionInfo(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: nutritionInfo!.entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.lightBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${entry.key}: ${entry.value}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryGreen,
                ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentMeals(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentMeals!.length.clamp(0, 3),
      itemBuilder: (context, index) {
        final meal = recentMeals![index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 8,
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  meal.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Text(
                meal.timeAgo,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.neutralGrey,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MealLog {
  final String description;
  final String timeAgo;
  final DateTime timestamp;
  final double amount;
  final String? notes;

  MealLog({
    required this.description,
    required this.timeAgo,
    required this.timestamp,
    required this.amount,
    this.notes,
  });
}