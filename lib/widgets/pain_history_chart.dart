import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import 'common/custom_card.dart';

class PainHistoryChart extends StatelessWidget {
  final String petName;
  final List<PainRecord> painHistory;
  final int daysToShow;
  final bool showLegend;
  final VoidCallback? onAddRecord;
  final Function(PainRecord)? onRecordTap;
  final bool isLoading;
  final String? notes;

  const PainHistoryChart({
    Key? key,
    required this.petName,
    required this.painHistory,
    this.daysToShow = 7,
    this.showLegend = true,
    this.onAddRecord,
    this.onRecordTap,
    this.isLoading = false,
    this.notes,
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
                    'Pain History',
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
              if (onAddRecord != null)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppTheme.primaryGreen,
                  onPressed: isLoading ? null : onAddRecord,
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
            SizedBox(
              height: 200,
              child: _buildChart(context),
            ),
            if (showLegend) ...[
              const SizedBox(height: 16),
              _buildLegend(context),
            ],
            if (notes != null) ...[
              const SizedBox(height: 16),
              _buildNotes(context),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    if (painHistory.isEmpty) {
      return Center(
        child: Text(
          'No pain records available',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.neutralGrey,
              ),
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 30,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.neutralGrey,
                    ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final date = DateTime.now().subtract(
                  Duration(days: (daysToShow - value.toInt() - 1)),
                );
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${date.day}/${date.month}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.neutralGrey,
                        ),
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: daysToShow.toDouble() - 1,
        minY: 0,
        maxY: 10,
        lineBarsData: [
          LineChartBarData(
            spots: _createSpots(),
            isCurved: true,
            color: AppTheme.primaryGreen,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: AppTheme.primaryGreen,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryGreen.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: AppTheme.primaryGreen.withOpacity(0.8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final record = painHistory[spot.x.toInt()];
                return LineTooltipItem(
                  'Pain Level: ${spot.y.toInt()}\n${record.location}',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
          touchCallback: (event, response) {
            if (event is FlTapUpEvent && response?.lineBarSpots != null) {
              final index = response!.lineBarSpots!.first.x.toInt();
              onRecordTap?.call(painHistory[index]);
            }
          },
        ),
      ),
    );
  }

  List<FlSpot> _createSpots() {
    final spots = <FlSpot>[];
    for (var i = 0; i < painHistory.length; i++) {
      spots.add(FlSpot(i.toDouble(), painHistory[i].painLevel.toDouble()));
    }
    return spots;
  }

  Widget _buildLegend(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem(
          context,
          'Mild (1-3)',
          AppTheme.success,
        ),
        _buildLegendItem(
          context,
          'Moderate (4-6)',
          AppTheme.warning,
        ),
        _buildLegendItem(
          context,
          'Severe (7-10)',
          AppTheme.error,
        ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.neutralGrey,
              ),
        ),
      ],
    );
  }

  Widget _buildNotes(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.note,
            size: 20,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              notes!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondaryGreen,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class PainRecord {
  final DateTime date;
  final int painLevel;
  final String location;
  final String? notes;
  final List<String>? symptoms;

  const PainRecord({
    required this.date,
    required this.painLevel,
    required this.location,
    this.notes,
    this.symptoms,
  });
}