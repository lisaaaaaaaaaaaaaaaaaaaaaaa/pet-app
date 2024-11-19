import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/pet_provider.dart';
import '../../models/pain_record.dart';
import '../../theme/app_theme.dart';

class PainTrackerScreen extends StatefulWidget {
  const PainTrackerScreen({Key? key}) : super(key: key);

  @override
  State<PainTrackerScreen> createState() => _PainTrackerScreenState();
}

class _PainTrackerScreenState extends State<PainTrackerScreen> {
  bool _isLoading = false;
  String _selectedTimeRange = '1W'; // 1W, 1M, 3M, 6M, 1Y
  int _selectedBodyPart = -1;

  final List<String> _timeRanges = ['1W', '1M', '3M', '6M', '1Y'];
  final Map<int, String> _bodyParts = {
    0: 'Head',
    1: 'Neck',
    2: 'Chest',
    3: 'Back',
    4: 'Legs',
    5: 'Tail',
  };

  @override
  void initState() {
    super.initState();
    _loadPainData();
  }

  Future<void> _loadPainData() async {
    setState(() => _isLoading = true);
    try {
      await context.read<PetProvider>().loadPainRecords(_selectedTimeRange);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading pain data: $e')),
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
        title: const Text('Pain Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/pain-history'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimeRangeSelector(),
                  _buildPainChart(),
                  _buildBodyPartSelector(),
                  _buildPainIntensityIndicator(),
                  _buildRecentRecords(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPainRecordDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Record Pain'),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _timeRanges.length,
        itemBuilder: (context, index) {
          final range = _timeRanges[index];
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
                    _loadPainData();
                  });
                }
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPainChart() {
    return Consumer<PetProvider>(
      builder: (context, provider, child) {
        final painData = provider.getPainData(_selectedTimeRange);
        
        return Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 2,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        DateFormat('MM/dd').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            value.toInt(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: painData.map((record) {
                    return FlSpot(
                      record.date.millisecondsSinceEpoch.toDouble(),
                      record.intensity.toDouble(),
                    );
                  }).toList(),
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBodyPartSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Body Part',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _bodyParts.entries.map((entry) {
              final isSelected = entry.key == _selectedBodyPart;
              return ChoiceChip(
                label: Text(entry.value),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedBodyPart = selected ? entry.key : -1;
                  });
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPainIntensityIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pain Intensity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(10, (index) {
              final intensity = index + 1;
              return Expanded(
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: _getPainColor(intensity),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      '$intensity',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mild'),
              Text('Moderate'),
              Text('Severe'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRecords() {
    return Consumer<PetProvider>(
      builder: (context, provider, child) {
        final records = provider.getRecentPainRecords();

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Records',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/pain-history'),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: records.length.clamp(0, 5),
                itemBuilder: (context, index) {
                  final record = records[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getPainColor(record.intensity),
                        child: Text(
                          '${record.intensity}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(_bodyParts[record.bodyPart] ?? 'Unknown'),
                      subtitle: Text(
                        DateFormat('MMM d, y - h:mm a').format(record.date),
                      ),
                      trailing: Text(
                        record.notes ?? '',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getPainColor(int intensity) {
    if (intensity <= 3) return Colors.green;
    if (intensity <= 6) return Colors.orange;
    return Colors.red;
  }

  void _showAddPainRecordDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildAddPainRecordForm(),
    );
  }

  Widget _buildAddPainRecordForm() {
    // Implement pain record form
    return Container();
  }
}