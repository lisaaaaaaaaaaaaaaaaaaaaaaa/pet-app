import 'package:flutter/material.dart';
import '../models/symptom.dart';
import '../theme/app_theme.dart';

class SymptomSelector extends StatefulWidget {
  final List<Symptom> symptoms;
  final List<Symptom> selectedSymptoms;
  final ValueChanged<List<Symptom>> onChanged;
  final int? maxSelections;
  final bool showSeverity;
  final bool showDuration;
  final bool grouped;
  final String? title;
  final String? subtitle;

  const SymptomSelector({
    Key? key,
    required this.symptoms,
    required this.selectedSymptoms,
    required this.onChanged,
    this.maxSelections,
    this.showSeverity = true,
    this.showDuration = true,
    this.grouped = true,
    this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  State<SymptomSelector> createState() => _SymptomSelectorState();
}

class _SymptomSelectorState extends State<SymptomSelector> {
  final Map<String, double> _severityLevels = {};
  final Map<String, Duration> _durations = {};

  @override
  void initState() {
    super.initState();
    // Initialize severity and duration for selected symptoms
    for (var symptom in widget.selectedSymptoms) {
      _severityLevels[symptom.id] = symptom.severity ?? 1.0;
      _durations[symptom.id] = symptom.duration ?? const Duration(hours: 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (widget.subtitle != null) ...[
          Text(
            widget.subtitle!,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 16),
        ],
        widget.grouped
            ? _buildGroupedSymptoms()
            : _buildSymptomGrid(),
      ],
    );
  }

  Widget _buildGroupedSymptoms() {
    final groupedSymptoms = <String, List<Symptom>>{};
    for (var symptom in widget.symptoms) {
      groupedSymptoms.putIfAbsent(symptom.category, () => []).add(symptom);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedSymptoms.length,
      itemBuilder: (context, index) {
        final category = groupedSymptoms.keys.elementAt(index);
        final symptoms = groupedSymptoms[category]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                category,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: symptoms.map((symptom) => _buildSymptomChip(symptom)).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSymptomGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.symptoms.map((symptom) => _buildSymptomChip(symptom)).toList(),
    );
  }

  Widget _buildSymptomChip(Symptom symptom) {
    final isSelected = widget.selectedSymptoms.contains(symptom);
    final canSelect = !isSelected && 
        (widget.maxSelections == null || 
         widget.selectedSymptoms.length < widget.maxSelections!);

    return FilterChip(
      label: Text(symptom.name),
      selected: isSelected,
      onSelected: canSelect || isSelected ? (selected) {
        final updatedSymptoms = List<Symptom>.from(widget.selectedSymptoms);
        if (selected) {
          updatedSymptoms.add(symptom);
          _severityLevels[symptom.id] = 1.0;
          _durations[symptom.id] = const Duration(hours: 1);
        } else {
          updatedSymptoms.removeWhere((s) => s.id == symptom.id);
          _severityLevels.remove(symptom.id);
          _durations.remove(symptom.id);
        }
        widget.onChanged(updatedSymptoms);
        if (selected) {
          _showSymptomDetailsDialog(symptom);
        }
      } : null,
      backgroundColor: Colors.transparent,
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
      ),
    );
  }

  Future<void> _showSymptomDetailsDialog(Symptom symptom) async {
    if (!widget.showSeverity && !widget.showDuration) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(symptom.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showSeverity)
              _buildSeveritySlider(symptom),
            if (widget.showDuration)
              _buildDurationSelector(symptom),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    final updatedSymptoms = widget.selectedSymptoms.map((s) {
      if (s.id == symptom.id) {
        return s.copyWith(
          severity: _severityLevels[s.id],
          duration: _durations[s.id],
        );
      }
      return s;
    }).toList();

    widget.onChanged(updatedSymptoms);
  }

  Widget _buildSeveritySlider(Symptom symptom) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Severity',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Slider(
          value: _severityLevels[symptom.id] ?? 1.0,
          min: 1.0,
          max: 10.0,
          divisions: 9,
          label: (_severityLevels[symptom.id] ?? 1.0).toInt().toString(),
          onChanged: (value) {
            setState(() {
              _severityLevels[symptom.id] = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDurationSelector(Symptom symptom) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Duration',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButton<Duration>(
          value: _durations[symptom.id] ?? const Duration(hours: 1),
          items: [
            DropdownMenuItem(
              value: const Duration(hours: 1),
              child: const Text('1 hour'),
            ),
            DropdownMenuItem(
              value: const Duration(hours: 6),
              child: const Text('6 hours'),
            ),
            DropdownMenuItem(
              value: const Duration(days: 1),
              child: const Text('1 day'),
            ),
            DropdownMenuItem(
              value: const Duration(days: 3),
              child: const Text('3 days'),
            ),
            DropdownMenuItem(
              value: const Duration(days: 7),
              child: const Text('1 week'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _durations[symptom.id] = value!;
            });
          },
        ),
      ],
    );
  }
}