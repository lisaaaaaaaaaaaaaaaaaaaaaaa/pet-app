// lib/screens/wellness/wellness_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WellnessDashboardScreen extends StatefulWidget {
  const WellnessDashboardScreen({Key? key}) : super(key: key);

  @override
  State<WellnessDashboardScreen> createState() => _WellnessDashboardScreenState();
}

class _WellnessDashboardScreenState extends State<WellnessDashboardScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load your wellness data here
      await Future.delayed(const Duration(seconds: 1)); // Simulated delay
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading wellness data: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverallHealthCard(),
                    const SizedBox(height: 16),
                    _buildUpcomingEventsCard(),
                    const SizedBox(height: 16),
                    _buildHealthMetricsGrid(),
                    const SizedBox(height: 16),
                    _buildRecentActivitiesCard(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverallHealthCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overall Health',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildHealthIndicator(
                    icon: Icons.favorite,
                    label: 'Health Score',
                    value: '92%',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildHealthIndicator(
                    icon: Icons.directions_run,
                    label: 'Activity Level',
                    value: 'High',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEventsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Events',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to events list
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildEventItem(
              icon: Icons.medical_services,
              title: 'Vet Check-up',
              date: DateTime.now().add(const Duration(days: 5)),
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            _buildEventItem(
              icon: Icons.vaccines,
              title: 'Vaccination Due',
              date: DateTime.now().add(const Duration(days: 12)),
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildMetricCard(
          icon: Icons.monitor_weight,
          title: 'Weight',
          value: '12.5 kg',
          trend: '+0.5 kg',
          trendUp: true,
        ),
        _buildMetricCard(
          icon: Icons.restaurant,
          title: 'Diet',
          value: '2 meals/day',
          subtitle: 'Regular',
        ),
        _buildMetricCard(
          icon: Icons.fitness_center,
          title: 'Exercise',
          value: '45 min/day',
          trend: '+5 min',
          trendUp: true,
        ),
        _buildMetricCard(
          icon: Icons.nightlight,
          title: 'Sleep',
          value: '12 hours',
          trend: '-30 min',
          trendUp: false,
        ),
      ],
    );
  }

  Widget _buildRecentActivitiesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              icon: Icons.medical_services,
              title: 'Vet Visit',
              description: 'Regular check-up',
              time: DateTime.now().subtract(const Duration(days: 2)),
            ),
            const SizedBox(height: 12),
            _buildActivityItem(
              icon: Icons.medication,
              title: 'Medication',
              description: 'Heartworm prevention',
              time: DateTime.now().subtract(const Duration(days: 5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIndicator({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEventItem({
    required IconData icon,
    required String title,
    required DateTime date,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                DateFormat('MMM d, y').format(date),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    String? trend,
    bool? trendUp,
    String? subtitle,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            if (trend != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    trendUp! ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 16,
                    color: trendUp ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    trend,
                    style: TextStyle(
                      color: trendUp ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String description,
    required DateTime time,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Text(
          DateFormat('MMM d').format(time),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}