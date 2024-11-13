// lib/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/user_preferences.dart';
import '../../theme/app_theme.dart';
import '../../utils/url_launcher.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/settings/settings_tile.dart';
import '../../widgets/settings/settings_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  String _appVersion = '';
  late UserPreferences _preferences;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadAppVersion(),
        _loadUserPreferences(),
      ]);
    } catch (e) {
      _showErrorSnackBar('Failed to load settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() => _appVersion = packageInfo.version);
    } catch (e) {
      debugPrint('Error loading app version: $e');
    }
  }

  Future<void> _loadUserPreferences() async {
    try {
      _preferences = await context.read<SettingsProvider>().loadPreferences();
      setState(() {});
    } catch (e) {
      throw Exception('Failed to load preferences: $e');
    }
  }

  Future<void> _updatePreference(Future<void> Function() update) async {
    setState(() => _isLoading = true);
    try {
      await update();
      _showSuccessSnackBar('Settings updated successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to update settings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'RETRY',
          textColor: Colors.white,
          onPressed: _initializeSettings,
        ),
      ),
    );
  }

  // ... (continued in next part)
  // Continuing lib/screens/settings/settings_screen.dart

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: 'Sign Out',
        content: 'Are you sure you want to sign out?',
        confirmText: 'Sign Out',
        cancelText: 'Cancel',
        isDestructive: true,
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await context.read<AuthProvider>().signOut();
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
      } catch (e) {
        _showErrorSnackBar('Failed to sign out: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: 'Delete Account',
        content: 'This action cannot be undone. All your data will be permanently deleted. '
                'Are you sure you want to continue?',
        confirmText: 'Delete Account',
        cancelText: 'Cancel',
        isDestructive: true,
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await context.read<AuthProvider>().deleteAccount();
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
      } catch (e) {
        _showErrorSnackBar('Failed to delete account: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleThemeChange(String theme) async {
    await _updatePreference(() async {
      await context.read<ThemeProvider>().setTheme(theme);
      setState(() => _preferences.theme = theme);
    });
  }

  Future<void> _handleLanguageChange(String language) async {
    await _updatePreference(() async {
      await context.read<SettingsProvider>().updateLanguage(language);
      setState(() => _preferences.language = language);
    });
  }

  Future<void> _handleNotificationToggle(bool enabled) async {
    await _updatePreference(() async {
      await context.read<SettingsProvider>().updateNotifications(enabled);
      setState(() => _preferences.notificationsEnabled = enabled);
    });
  }

  Future<void> _handleLocationToggle(bool enabled) async {
    await _updatePreference(() async {
      await context.read<SettingsProvider>().updateLocation(enabled);
      setState(() => _preferences.locationEnabled = enabled);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const LoadingOverlay()
          else
            RefreshIndicator(
              onRefresh: _initializeSettings,
              child: ListView(
                children: [
                  _buildAccountSection(),
                  _buildNotificationsSection(),
                  _buildPreferencesSection(),
                  _buildSupportSection(),
                  _buildAboutSection(),
                  _buildSignOutSection(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return SettingsSection(
      title: 'Account',
      children: [
        SettingsTile(
          icon: Icons.person_outline,
          title: 'Edit Profile',
          onTap: () => Navigator.pushNamed(context, '/profile/edit'),
        ),
        SettingsTile(
          icon: Icons.security,
          title: 'Security',
          onTap: () => Navigator.pushNamed(context, '/settings/security'),
        ),
        SettingsTile(
          icon: Icons.delete_outline,
          title: 'Delete Account',
          textColor: Colors.red,
          onTap: _handleDeleteAccount,
        ),
      ],
    );
  }

  // ... (continued in next part)
  // Continuing lib/screens/settings/settings_screen.dart

  Widget _buildNotificationsSection() {
    return SettingsSection(
      title: 'Notifications',
      children: [
        SwitchSettingsTile(
          icon: Icons.notifications_outlined,
          title: 'Push Notifications',
          subtitle: 'Receive updates about your pets',
          value: _preferences.notificationsEnabled,
          onChanged: _handleNotificationToggle,
        ),
        SwitchSettingsTile(
          icon: Icons.location_on_outlined,
          title: 'Location Services',
          subtitle: 'Enable location-based features',
          value: _preferences.locationEnabled,
          onChanged: _handleLocationToggle,
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return SettingsSection(
      title: 'Preferences',
      children: [
        DropdownSettingsTile(
          icon: Icons.language,
          title: 'Language',
          value: _preferences.language,
          items: const {
            'en': 'English',
            'es': 'Español',
            'fr': 'Français',
          },
          onChanged: _handleLanguageChange,
        ),
        DropdownSettingsTile(
          icon: Icons.palette_outlined,
          title: 'Theme',
          value: _preferences.theme,
          items: const {
            'light': 'Light',
            'dark': 'Dark',
            'system': 'System Default',
          },
          onChanged: _handleThemeChange,
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return SettingsSection(
      title: 'Support',
      children: [
        SettingsTile(
          icon: Icons.help_outline,
          title: 'Help Center',
          onTap: () => UrlLauncher.openUrl(
            context,
            'https://your-app-help-center.com',
          ),
        ),
        SettingsTile(
          icon: Icons.mail_outline,
          title: 'Contact Support',
          onTap: () => UrlLauncher.sendEmail(
            context,
            'support@your-app.com',
            subject: 'Support Request',
          ),
        ),
        SettingsTile(
          icon: Icons.bug_report_outlined,
          title: 'Report an Issue',
          onTap: () => Navigator.pushNamed(context, '/support/report-issue'),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return SettingsSection(
      title: 'About',
      children: [
        SettingsTile(
          icon: Icons.info_outline,
          title: 'About App',
          subtitle: 'Version $_appVersion',
          onTap: _showAboutDialog,
        ),
        SettingsTile(
          icon: Icons.description_outlined,
          title: 'Terms of Service',
          onTap: () => UrlLauncher.openUrl(
            context,
            'https://your-app-terms.com',
          ),
        ),
        SettingsTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          onTap: () => UrlLauncher.openUrl(
            context,
            'https://your-app-privacy.com',
          ),
        ),
      ],
    );
  }

  Widget _buildSignOutSection() {
    return SettingsSection(
      children: [
        SettingsTile(
          icon: Icons.logout,
          title: 'Sign Out',
          textColor: Colors.red,
          onTap: _handleSignOut,
        ),
      ],
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'Your App Name',
        applicationVersion: 'Version $_appVersion',
        applicationIcon: Image.asset(
          'assets/images/app_icon.png',
          width: 50,
          height: 50,
        ),
        children: [
          const SizedBox(height: 16),
          const Text(
            'Your app description goes here. This can be a brief overview '
            'of what your app does and its main features.',
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => UrlLauncher.openUrl(
              context,
              'https://your-app-website.com',
            ),
            child: const Text('Visit Website'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Clean up any controllers or listeners here
    super.dispose();
  }
}

// Custom widgets (can be moved to separate files)
class SwitchSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SwitchSettingsTile({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      value: value,
      onChanged: onChanged,
    );
  }
}

class DropdownSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;

  const DropdownSettingsTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: (newValue) {
          if (newValue != null) onChanged(newValue);
        },
        items: items.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList(),
      ),
    );
  }
}