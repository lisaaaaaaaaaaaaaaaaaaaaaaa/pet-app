import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final bool enabled;
  final Color? iconColor;
  final EdgeInsets? padding;
  final bool showChevron;
  final bool isDestructive;
  final bool dense;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const SettingsTile({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.enabled = true,
    this.iconColor,
    this.padding,
    this.showChevron = true,
    this.isDestructive = false,
    this.dense = false,
    this.titleStyle,
    this.subtitleStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = isDestructive
        ? AppTheme.errorColor
        : iconColor ?? AppTheme.primaryColor;

    final effectiveTitleStyle = titleStyle ??
        TextStyle(
          fontSize: dense ? 14 : 16,
          color: isDestructive
              ? AppTheme.errorColor
              : (enabled
                  ? AppTheme.textPrimaryColor
                  : AppTheme.textSecondaryColor),
          fontWeight: isDestructive ? FontWeight.w500 : null,
        );

    final effectiveSubtitleStyle = subtitleStyle ??
        TextStyle(
          fontSize: dense ? 12 : 14,
          color: AppTheme.textSecondaryColor.withOpacity(enabled ? 1.0 : 0.5),
        );

    return Column(
      children: [
        ListTile(
          enabled: enabled,
          onTap: enabled ? onTap : null,
          dense: dense,
          contentPadding: padding ??
              const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
          leading: leading ??
              (icon != null
                  ? Icon(
                      icon,
                      color: enabled
                          ? effectiveIconColor
                          : effectiveIconColor.withOpacity(0.5),
                      size: dense ? 20 : 24,
                    )
                  : null),
          title: Text(
            title,
            style: effectiveTitleStyle,
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: effectiveSubtitleStyle,
                )
              : null,
          trailing: trailing ??
              (showChevron && onTap != null
                  ? Icon(
                      Icons.chevron_right,
                      color: AppTheme.textSecondaryColor.withOpacity(0.5),
                      size: dense ? 20 : 24,
                    )
                  : null),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: leading != null || icon != null ? 56 : 16,
            endIndent: 16,
          ),
      ],
    );
  }

  // Factory constructors for common settings tiles
  factory SettingsTile.navigation({
    required String title,
    String? subtitle,
    IconData? icon,
    required VoidCallback onTap,
    bool enabled = true,
    bool showDivider = true,
    bool dense = false,
  }) {
    return SettingsTile(
      title: title,
      subtitle: subtitle,
      icon: icon,
      onTap: onTap,
      enabled: enabled,
      showDivider: showDivider,
      showChevron: true,
      dense: dense,
    );
  }

  factory SettingsTile.destructive({
    required String title,
    String? subtitle,
    IconData? icon,
    required VoidCallback onTap,
    bool showDivider = true,
    bool dense = false,
  }) {
    return SettingsTile(
      title: title,
      subtitle: subtitle,
      icon: icon,
      onTap: onTap,
      isDestructive: true,
      showDivider: showDivider,
      showChevron: false,
      dense: dense,
    );
  }
}

class SettingsSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool showDivider;
  final bool enabled;
  final Color? activeColor;
  final EdgeInsets? padding;
  final bool dense;

  const SettingsSwitchTile({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.value,
    this.onChanged,
    this.showDivider = true,
    this.enabled = true,
    this.activeColor,
    this.padding,
    this.dense = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: title,
      subtitle: subtitle,
      icon: icon,
      showDivider: showDivider,
      enabled: enabled,
      padding: padding,
      showChevron: false,
      dense: dense,
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: activeColor ?? AppTheme.primaryColor,
      ),
    );
  }
}

class SettingsValueTile extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool showDivider;
  final bool enabled;
  final bool dense;

  const SettingsValueTile({
    Key? key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.onTap,
    this.showDivider = true,
    this.enabled = true,
    this.dense = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: title,
      subtitle: subtitle,
      icon: icon,
      showDivider: showDivider,
      enabled: enabled,
      onTap: onTap,
      dense: dense,
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: dense ? 14 : 16,
          color: AppTheme.textSecondaryColor,
        ),
      ),
    );
  }
}