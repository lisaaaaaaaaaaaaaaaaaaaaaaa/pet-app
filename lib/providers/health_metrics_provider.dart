import 'package:flutter/foundation.dart';

class HealthMetric {
  final String id;
  final String petId;
  final String type;
  final double value;
  final DateTime timestamp;

  HealthMetric({
    required this.id,
    required this.petId,
    required this.type,
    required this.value,
    required this.timestamp,
  });
}

class HealthMetricsProvider with ChangeNotifier {
  final Map<String, List<HealthMetric>> _metrics = {};

  List<HealthMetric> getMetricsForPet(String petId) {
    return _metrics[petId] ?? [];
  }

  Future<void> loadHealthMetrics(String petId) async {
    // TODO: Implement loading from backend
    _metrics[petId] = [
      HealthMetric(
        id: '1',
        petId: petId,
        type: 'activity',
        value: 0.8,
        timestamp: DateTime.now(),
      ),
      HealthMetric(
        id: '2',
        petId: petId,
        type: 'health',
        value: 0.9,
        timestamp: DateTime.now(),
      ),
    ];
    notifyListeners();
  }

  Future<void> addMetric(String petId, HealthMetric metric) async {
    // TODO: Implement backend integration
    if (!_metrics.containsKey(petId)) {
      _metrics[petId] = [];
    }
    _metrics[petId]!.add(metric);
    notifyListeners();
  }

  Future<void> updateMetric(String petId, HealthMetric metric) async {
    // TODO: Implement backend integration
    if (_metrics.containsKey(petId)) {
      final index = _metrics[petId]!.indexWhere((m) => m.id == metric.id);
      if (index != -1) {
        _metrics[petId]![index] = metric;
        notifyListeners();
      }
    }
  }

  Future<void> deleteMetric(String petId, String metricId) async {
    // TODO: Implement backend integration
    if (_metrics.containsKey(petId)) {
      _metrics[petId]!.removeWhere((m) => m.id == metricId);
      notifyListeners();
    }
  }
}
