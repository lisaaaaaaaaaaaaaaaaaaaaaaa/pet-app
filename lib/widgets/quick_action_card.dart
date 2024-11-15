import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'common/custom_card.dart';

class QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final Color? backgroundColor;
  final bool showBadge;
  final String? badgeText;
  final bool isDisabled;
  final String? subtitle;
  final double iconSize;
  final EdgeInsets padding;
  final double? width;
  final double? height;

  const QuickActionCard({
    Key? key,
    required this.title,
    required this.icon,
    this.onTap,
    this.color,
    this.backgroundColor,
    this.showBadge = false,
    this.badgeText,
    this.isDisabled = false,
    this.subtitle,
    this.iconSize = 32,
    this.padding = const EdgeInsets.all(16),
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.primaryColor;
    final effectiveBackgroundColor = backgroundColor ?? 
        effectiveColor.withOpacity(0.1);

    return CustomCard(
      onTap: isDisabled ? null : onTap,
      width: width,
      height: height,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: isDisabled 
              ? AppTheme.disabledColor.withOpacity(0.1)
              : effectiveBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(effectiveColor),
                const SizedBox(height: 12),
                _buildTitle(effectiveColor),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  _buildSubtitle(),
                ],
              ],
            ),
            if (showBadge)
              _buildBadge(effectiveColor),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(Color effectiveColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDisabled 
            ? AppTheme.disabledColor.withOpacity(0.2)
            : effectiveColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: isDisabled 
            ? AppTheme.disabledColor
            : effectiveColor,
      ),
    );
  }

  Widget _buildTitle(Color effectiveColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDisabled 
            ? AppTheme.disabledColor
            : AppTheme.textPrimaryColor,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitle() {
    return Text(
      subtitle!,
      style: TextStyle(
        fontSize: 12,
        color: isDisabled 
            ? AppTheme.disabledColor
            : AppTheme.textSecondaryColor,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildBadge(Color effectiveColor) {
    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: isDisabled 
              ? AppTheme.disabledColor
              : effectiveColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          badgeText ?? '',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class QuickActionGrid extends StatelessWidget {
  final List<QuickActionCard> actions;
  final int crossAxisCount;
  final double spacing;
  final EdgeInsets padding;

  const QuickActionGrid({
    Key? key,
    required this.actions,
    this.crossAxisCount = 2,
    this.spacing = 16,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GridView.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: actions,
      ),
    );
  }
}