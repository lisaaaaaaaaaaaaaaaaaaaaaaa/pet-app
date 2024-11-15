import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool showDivider;
  final EdgeInsets? padding;
  final Widget? trailing;
  final VoidCallback? onTitleTap;

  const SettingsSection({
    Key? key,
    required this.title,
    required this.children,
    this.showDivider = true,
    this.padding,
    this.trailing,
    this.onTitleTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTitleTap,
          child: Padding(
            padding: padding ??
                const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
        ...children,
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}

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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          enabled: enabled,
          onTap: onTap,
          contentPadding: padding ??
              const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
          leading: leading ??
              (icon != null
                  ? Icon(
                      icon,
                      color: iconColor ?? AppTheme.primaryColor,
                    )
                  : null),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: enabled
                  ? AppTheme.textPrimaryColor
                  : AppTheme.textSecondaryColor,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                )
              : null,
          trailing: trailing,
        ),
        if (showDivider)
          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
      ],
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
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: activeColor ?? AppTheme.primaryColor,
      ),
    );
  }
}

class SettingsRadioTile<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final T value;
  final T groupValue;
  final ValueChanged<T?>? onChanged;
  final bool showDivider;
  final bool enabled;
  final EdgeInsets? padding;

  const SettingsRadioTile({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.showDivider = true,
    this.enabled = true,
    this.padding,
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
      trailing: Radio<T>(
        value: value,
        groupValue: groupValue,
        onChanged: enabled ? onChanged : null,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }
}