import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/weight_record.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';

class WeightChart extends StatelessWidget {
  final List<WeightRecord> records;
  final int days;
  final bool showGrid;
  final bool showLabels;
  final bool showTooltip;
  final double height;
  final Color? lineColor;
  final Color? gradientStartColor;
  final Color? gradientEndColor;
  final bool animate;
  final String? targetWeight;
  final bool showMinMax;
  final EdgeInsets padding;

  const WeightChart({
    Key? key,
    required this.records,
    this.days = 30,
    this.showGrid = true,
    this.showLabels = true,
    this.showTooltip = true,
    this.height = 200,
    this.lineColor,
    this.gradientStartColor,
    this.gradientEndColor,
    this.animate = true,
    this.targetWeight,
    this.showMinMax = true,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return _buildEmptyState();
    }

    final sortedRecords = List<WeightRecord>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    return Column(
      children: [
        if (showMinMax) _buildMinMaxLabels(sortedRecords),
        SizedBox(
          height: height,
          child: Padding(
            padding: padding,
            child: LineChart(
              animate ? LineChartData(
                lineTouchData: _getTooltipData(),
                gridData: _getGridData(),
                titlesData: _getTitlesData(),
                borderData: _getBorderData(),
                lineBarsData: [_getLineData(sortedRecords)],
                minX: _getMinX(sortedRecords),
                maxX: _getMaxX(sortedRecords),
                minY: _getMinY(sortedRecords),
                maxY: _getMaxY(sortedRecords),
                extraLinesData: _getTargetLine(),
              ) : LineChartData(
                lineTouchData: _getTooltipData(),
                gridData: _getGridData(),
                titlesData: _getTitlesData(),
                borderData: _getBorderData(),
                lineBarsData: [_getLineData(sortedRecords)],
                minX: _getMinX(sortedRecords),
                maxX: _getMaxX(sortedRecords),
                minY: _getMinY(sortedRecords),
                maxY: _getMaxY(sortedRecords),
                extraLinesData: _getTargetLine(),
              ),
              duration: animate ? const Duration(milliseconds: 500) : Duration.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: height,
      child: const Center(
        child: Text(
          'No weight records available',
          style: TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildMinMaxLabels(List<WeightRecord> sortedRecords) {
    final minWeight = sortedRecords.map((r) => r.weight).reduce(
      (value, element) => value < element ? value : element,
    );
    final maxWeight = sortedRecords.map((r) => r.weight).reduce(
      (value, element) => value > element ? value : element,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildWeightLabel('Min', minWeight, Colors.blue),
          if (targetWeight != null)
            _buildWeightLabel('Target', double.parse(targetWeight!), Colors.green),
          _buildWeightLabel('Max', maxWeight, Colors.red),
        ],
      ),
    );
  }

  Widget _buildWeightLabel(String label, double weight, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${weight.toStringAsFixed(1)} kg',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  LineTouchData _getTooltipData() {
    return LineTouchData(
      enabled: showTooltip,
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: AppTheme.cardColor,
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            return LineTooltipItem(
              '${spot.y.toStringAsFixed(1)} kg\n',
              const TextStyle(
                color: AppTheme.textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: DateFormatter.formatDate(
                    DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()),
                  ),
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ],
            );
          }).toList();
        },
      ),
    );
  }

  FlGridData _getGridData() {
    return FlGridData(show: showGrid);
  }

  FlTitlesData _getTitlesData() {
    return FlTitlesData(
      show: showLabels,
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: showLabels,
          getTitlesWidget: (value, meta) => _bottomTitleWidgets(value, meta),
          reservedSize: 22,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: showLabels,
          getTitlesWidget: (value, meta) => _leftTitleWidgets(value, meta),
          reservedSize: 40,
        ),
      ),
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        DateFormatter.formatShortDate(date),
        style: const TextStyle(
          fontSize: 10,
          color: AppTheme.textSecondaryColor,
        ),
      ),
    );
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        value.toStringAsFixed(1),
        style: const TextStyle(
          fontSize: 10,
          color: AppTheme.textSecondaryColor,
        ),
      ),
    );
  }

  FlBorderData _getBorderData() {
    return FlBorderData(show: false);
  }

  LineChartBarData _getLineData(List<WeightRecord> sortedRecords) {
    final spots = sortedRecords.map((record) {
      return FlSpot(
        record.date.millisecondsSinceEpoch.toDouble(),
        record.weight,
      );
    }).toList();

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: lineColor ?? AppTheme.primaryColor,
      barWidth: 3,
      dotData: FlDotData(show: true),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            (gradientStartColor ?? AppTheme.primaryColor).withOpacity(0.3),
            (gradientEndColor ?? AppTheme.primaryColor).withOpacity(0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  ExtraLinesData _getTargetLine() {
    if (targetWeight == null) return ExtraLinesData();

    return ExtraLinesData(
      horizontalLines: [
        HorizontalLine(
          y: double.parse(targetWeight!),
          color: Colors.green.withOpacity(0.5),
          strokeWidth: 1,
          dashArray: [5, 5],
        ),
      ],
    );
  }

  double _getMinX(List<WeightRecord> records) {
    return records.first.date.millisecondsSinceEpoch.toDouble();
  }

  double _getMaxX(List<WeightRecord> records) {
    return records.last.date.millisecondsSinceEpoch.toDouble();
  }

  double _getMinY(List<WeightRecord> records) {
    final minWeight = records.map((r) => r.weight).reduce(min);
    return (minWeight - 1).floorToDouble();
  }

  double _getMaxY(List<WeightRecord> records) {
    final maxWeight = records.map((r) => r.weight).reduce(max);
    return (maxWeight + 1).ceilToDouble();
  }
}