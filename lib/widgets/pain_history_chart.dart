import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/pain_record.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';

class PainHistoryChart extends StatelessWidget {
  final List<PainRecord> records;
  final int days;
  final bool showGrid;
  final bool showLabels;
  final bool showTooltip;
  final double height;
  final Color? lineColor;
  final Color? gradientStartColor;
  final Color? gradientEndColor;
  final bool animate;

  const PainHistoryChart({
    Key? key,
    required this.records,
    this.days = 7,
    this.showGrid = true,
    this.showLabels = true,
    this.showTooltip = true,
    this.height = 200,
    this.lineColor,
    this.gradientStartColor,
    this.gradientEndColor,
    this.animate = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'No pain records available',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: showGrid),
          titlesData: FlTitlesData(
            show: showLabels,
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: showLabels,
                getTitlesWidget: _bottomTitleWidgets,
                reservedSize: 22,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: showLabels,
                getTitlesWidget: _leftTitleWidgets,
                reservedSize: 32,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [_createLineData()],
          minX: 0,
          maxX: days.toDouble() - 1,
          minY: 0,
          maxY: 10,
          lineTouchData: LineTouchData(
            enabled: showTooltip,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: AppTheme.cardBackgroundColor,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final record = records[spot.x.toInt()];
                  return LineTooltipItem(
                    '${record.painLevel.toInt()}/10\n${DateFormatter.formatDate(record.timestamp)}',
                    const TextStyle(
                      color: AppTheme.textPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
        swapAnimationDuration: animate
            ? const Duration(milliseconds: 500)
            : const Duration(milliseconds: 0),
        swapAnimationCurve: Curves.easeInOut,
      ),
    );
  }

  LineChartBarData _createLineData() {
    final spots = records.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.painLevel.toDouble(),
      );
    }).toList();

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: lineColor ?? AppTheme.primaryColor,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: lineColor ?? AppTheme.primaryColor,
            strokeWidth: 2,
            strokeColor: AppTheme.cardBackgroundColor,
          );
        },
      ),
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

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    if (!showLabels || value.toInt() >= records.length) {
      return const SizedBox.shrink();
    }

    final record = records[value.toInt()];
    final text = DateFormatter.formatShortDate(record.timestamp);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.textSecondaryColor,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    if (!showLabels || value % 2 != 0) {
      return const SizedBox.shrink();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        value.toInt().toString(),
        style: const TextStyle(
          color: AppTheme.textSecondaryColor,
          fontSize: 12,
        ),
      ),
    );
  }
}

class PainLevelLegend extends StatelessWidget {
  const PainLevelLegend({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('0-3', Colors.green, 'Mild'),
        const SizedBox(width: 16),
        _buildLegendItem('4-6', Colors.orange, 'Moderate'),
        const SizedBox(width: 16),
        _buildLegendItem('7-10', Colors.red, 'Severe'),
      ],
    );
  }

  Widget _buildLegendItem(String range, Color color, String label) {
    return Row(
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
          '$range ($label)',
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}