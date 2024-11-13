import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/pet_provider.dart';
import '../../models/health_record.dart';
import '../../theme/app_theme.dart';

class HealthAnalyticsScreen extends StatefulWidget {
  const HealthAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<HealthAnalyticsScreen> createState() => _HealthAnalyticsScreenState();
}

class _HealthAnalyticsScreenState extends State<HealthAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeRange = '1M'; // 1W, 1M, 3M, 6M, 1Y
  bool _isLoading = false;

  final List<String> _timeRanges = ['1W', '1M', '3M', '6M', '1Y'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load health analytics data
      await context.read<PetProvider>().loadHealthAnalytics(_selectedTimeRange);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
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
        title: const Text('Health Analytics'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Weight'),
            Tab(text: 'Activity'),
            Tab(text: 'Vitals'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildTimeRangeSelector(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildWeightTab(),
                      _buildActivityTab(),
                      _buildVitalsTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _timeRanges.map((range) {
            final isSelected = range == _selectedTimeRange;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(range),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedTimeRange = range;
                    });
                    _loadData();
                  }
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHealthScoreCard(),
          const SizedBox(height: 24),
          _buildTrendsSection(),
          const SizedBox(height: 24),
          _buildRecentActivitiesSection(),
        ],
      ),
    );
  }

  Widget _buildWeightTab() {
    return Consumer<PetProvider>(
      builder: (context, provider, child) {
        final weightData = provider.getWeightData(_selectedTimeRange);
        
        if (weightData.isEmpty) {
          return _buildEmptyState(
            'No Weight Data',
            'Start tracking your pet\'s weight to see analytics',
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildWeightChart(weightData),
              const SizedBox(height: 24),
              _buildWeightStats(weightData),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityTab() {
    return Consumer<PetProvider>(
      builder: (context, provider, child) {
        final activityData = provider.getActivityData(_selectedTimeRange);

        if (activityData.isEmpty) {
          return _buildEmptyState(
            'No Activity Data',
            'Start tracking your pet\'s activities to see analytics',
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildActivityChart(activityData),
              const SizedBox(height: 24),
              _buildActivityStats(activityData),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVitalsTab() {
    return Consumer<PetProvider>(
      builder: (context, provider, child) {
        final vitalsData = provider.getVitalsData(_selectedTimeRange);

        if (vitalsData.isEmpty) {
          return _buildEmptyState(
            'No Vitals Data',
            'Record your pet\'s vital signs to see analytics',
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildVitalsChart(vitalsData),
              const SizedBox(height: 24),
              _buildVitalsStats(vitalsData),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHealthScoreCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health Score',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildScoreIndicator(85, 'Overall'),
                _buildScoreIndicator(90, 'Activity'),
                _buildScoreIndicator(82, 'Diet'),
                _buildScoreIndicator(88, 'Wellness'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreIndicator(int score, String label) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 60,
              width: 60,
              child: CircularProgressIndicator(
                value: score / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getScoreColor(score),
                ),
                strokeWidth: 8,
              ),
            ),
            Text(
              '$score',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.lightGreen;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  Widget _buildTrendsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trends',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildTrendCard(
          icon: Icons.trending_up,
          title: 'Weight',
          value: '12.5 kg',
          trend: '+0.5 kg',
          isPositive: false,
        ),
        const SizedBox(height: 8),
        _buildTrendCard(
          icon: Icons.directions_run,
          title: 'Daily Activity',
          value: '45 min',
          trend: '+10 min',
          isPositive: true,
        ),
        const SizedBox(height: 8),
        _buildTrendCard(
          icon: Icons.restaurant,
          title: 'Food Intake',
          value: '400g',
          trend: 'Stable',
          isPositive: true,
        ),
      ],
    );
  }

  Widget _buildTrendCard({
    required IconData icon,
    required String title,
    required String value,
    required String trend,
    required bool isPositive,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              trend,
              style: TextStyle(
                color: trend == 'Stable'
                    ? Colors.grey
                    : isPositive
                        ? Colors.green
                        : Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightChart(List<HealthRecord> data) {
    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          // Implement chart data configuration
        ),
      ),
    );
  }

  Widget _buildActivityChart(List<HealthRecord> data) {
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          // Implement chart data configuration
        ),
      ),
    );
  }

  Widget _buildVitalsChart(List<HealthRecord> data) {
    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          // Implement chart data configuration
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}