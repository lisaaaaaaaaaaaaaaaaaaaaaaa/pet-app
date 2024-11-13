import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import 'common/custom_card.dart';

class WeightChart extends StatelessWidget {
  final String petName;
  final List<WeightRecord> weightHistory;
  final double? targetWeight;
  final double? idealRangeMin;
  final double? idealRangeMax;
  final VoidCallback? onAddWeight;
  final Function(WeightRecord)? onRecordTap;
  final bool showDetails;
  final bool isLoading;
  final String weightUnit;
  final int daysToShow;

  const WeightChart({
    Key? key,
    required this.petName,
    required this.weightHistory,
    this.targetWeight,
    this.idealRangeMin,
    this.idealRangeMax,
    this.onAddWeight,
    this.onRecordTap,
    this.showDetails = true,
    this.isLoading = false,
    this.weightUnit = 'kg',
    this.daysToShow = 30,
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
                    'Weight History',
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
              if (onAddWeight != null)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppTheme.primaryGreen,
                  onPressed: isLoading ? null : onAddWeight,
                ),
            ],
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            const SizedBox(height: 20),
            if (weightHistory.isEmpty)
              Center(
                child: Text(
                  'No weight records available',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.neutralGrey,
                      ),
                ),
              )
            else ...[
              SizedBox(
                height: 200,
                child: _buildChart(context),
              ),
              if (showDetails) ...[
                const SizedBox(height: 16),
                _buildWeightSummary(context),
                const SizedBox(height: 16),
                _buildRecentRecords(context),
              ],
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    final records = weightHistory
        .where((record) => record.date
            .isAfter(DateTime.now().subtract(Duration(days: daysToShow))))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (records.isEmpty) return Container();

    final minY = (records.map((e) => e.weight).reduce(min) * 0.9)
        .clamp(0, double.infinity);
    final maxY = (records.map((e) => e.weight).reduce(max) * 1.1)
        .clamp(0, double.infinity);

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: ((maxY - minY) / 4).roundToDouble(),
              reservedSize: 40,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (records.length / 4).roundToDouble(),
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= records.length) return const Text('');
                final date = records[value.toInt()].date;
                return Text(
                  '${date.day}/${date.month}',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(records.length, (index) {
              return FlSpot(index.toDouble(), records[index].weight);
            }),
            isCurved: true,
            color: AppTheme.primaryGreen,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryGreen.withOpacity(0.1),
            ),
          ),
          if (targetWeight != null)
            LineChartBarData(
              spots: List.generate(records.length, (index) {
                return FlSpot(index.toDouble(), targetWeight!);
              }),
              isCurved: false,
              color: AppTheme.neutralGrey.withOpacity(0.5),
              barWidth: 1,
              dashArray: [5, 5],
              dotData: FlDotData(show: false),
            ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: AppTheme.primaryGreen.withOpacity(0.8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final record = records[spot.x.toInt()];
                return LineTooltipItem(
                  '${record.weight} $weightUnit\n${_formatDate(record.date)}',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
          touchCallback: (event, response) {
            if (event is FlTapUpEvent && response?.lineBarSpots != null) {
              final index = response!.lineBarSpots!.first.x.toInt();
              onRecordTap?.call(records[index]);
            }
          },
        ),
      ),
    );
  }

  Widget _buildWeightSummary(BuildContext context) {
    final currentWeight = weightHistory.isNotEmpty
        ? weightHistory.reduce((a, b) => a.date.isAfter(b.date) ? a : b)
        : null;
    final previousWeight = weightHistory.length > 1
        ? weightHistory
            .where((record) => record != currentWeight)
            .reduce((a, b) => a.date.isAfter(b.date) ? a : b)
        : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSummaryItem(
          context,
          'Current',
          currentWeight?.weight ?? 0,
          previousWeight != null
              ? currentWeight!.weight - previousWeight.weight
              : null,
        ),
        if (targetWeight != null)
          _buildSummaryItem(
            context,
            'Target',
            targetWeight!,
            currentWeight != null ? targetWeight! - currentWeight.weight : null,
          ),
      ],
    );
  }

  Widget _buildSummaryItem(
      BuildContext context, String label, double weight, double? difference) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.neutralGrey,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '$weight $weightUnit',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
        ),
        if (difference != null) ...[
          const SizedBox(height: 4),
          Text(
            '${difference >= 0 ? '+' : ''}${difference.toStringAsFixed(1)} $weightUnit',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: difference >= 0 ? AppTheme.success : AppTheme.error,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildRecentRecords(BuildContext context) {
    final recentRecords = weightHistory.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Records',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppTheme.secondaryGreen,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        ...recentRecords.take(3).map((record) => _buildRecordItem(context, record)),
      ],
    );
  }

  Widget _buildRecordItem(BuildContext context, WeightRecord record) {
    return InkWell(
      onTap: onRecordTap != null ? () => onRecordTap!(record) : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.lightBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.monitor_weight_outlined,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${record.weight} $weightUnit',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (record.notes != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      record.notes!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.neutralGrey,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              _formatDate(record.date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.neutralGrey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class WeightRecord {
  final DateTime date;
  final double weight;
  final String? notes;

  const WeightRecord({
    required this.date,
    required this.weight,
    this.notes,
  });
}