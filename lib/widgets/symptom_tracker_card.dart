import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'common/custom_card.dart';

class SymptomTrackerCard extends StatelessWidget {
  final String petName;
  final List<SymptomRecord> symptoms;
  final DateTime? lastUpdated;
  final VoidCallback? onAddSymptom;
  final Function(SymptomRecord)? onSymptomTap;
  final bool isLoading;
  final List<String>? activeTreatments;
  final String? veterinaryNotes;

  const SymptomTrackerCard({
    Key? key,
    required this.petName,
    required this.symptoms,
    this.lastUpdated,
    this.onAddSymptom,
    this.onSymptomTap,
    this.isLoading = false,
    this.activeTreatments,
    this.veterinaryNotes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
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
                    'Symptom Tracker',
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
              if (onAddSymptom != null)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppTheme.primaryGreen,
                  onPressed: isLoading ? null : onAddSymptom,
                ),
            ],
          ),
          if (lastUpdated != null) ...[
            const SizedBox(height: 8),
            Text(
              'Last updated: ${_formatDate(lastUpdated!)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.neutralGrey,
                  ),
            ),
          ],
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            if (symptoms.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No symptoms recorded',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.neutralGrey,
                        ),
                  ),
                ),
              )
            else ...[
              const SizedBox(height: 16),
              _buildSymptomsList(context),
            ],
            if (activeTreatments != null && activeTreatments!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildTreatmentsList(context),
            ],
            if (veterinaryNotes != null) ...[
              const SizedBox(height: 16),
              _buildVeterinaryNotes(context),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSymptomsList(BuildContext context) {
    final activeSymptoms = symptoms.where((s) => s.isActive).toList();
    final resolvedSymptoms = symptoms.where((s) => !s.isActive).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activeSymptoms.isNotEmpty) ...[
          Text(
            'Active Symptoms',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.secondaryGreen,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          ...activeSymptoms.map((symptom) => _buildSymptomItem(context, symptom)),
        ],
        if (resolvedSymptoms.isNotEmpty) ...[
          if (activeSymptoms.isNotEmpty) const SizedBox(height: 16),
          Text(
            'Resolved Symptoms',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.secondaryGreen,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          ...resolvedSymptoms.map((symptom) => _buildSymptomItem(context, symptom)),
        ],
      ],
    );
  }

  Widget _buildSymptomItem(BuildContext context, SymptomRecord symptom) {
    return InkWell(
      onTap: onSymptomTap != null ? () => onSymptomTap!(symptom) : null,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (symptom.isActive ? AppTheme.warning : AppTheme.success)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                symptom.icon ?? (symptom.isActive ? Icons.warning : Icons.check_circle),
                color: symptom.isActive ? AppTheme.warning : AppTheme.success,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symptom.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (symptom.notes != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      symptom.notes!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.neutralGrey,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              _formatDate(symptom.dateRecorded),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.neutralGrey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Treatments',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppTheme.secondaryGreen,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: activeTreatments!.map((treatment) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                treatment,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryGreen,
                    ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVeterinaryNotes(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Veterinary Notes',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.secondaryGreen,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            veterinaryNotes!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class SymptomRecord {
  final String name;
  final DateTime dateRecorded;
  final bool isActive;
  final String? notes;
  final IconData? icon;
  final String? severity;
  final List<String>? relatedSymptoms;

  const SymptomRecord({
    required this.name,
    required this.dateRecorded,
    this.isActive = true,
    this.notes,
    this.icon,
    this.severity,
    this.relatedSymptoms,
  });
}