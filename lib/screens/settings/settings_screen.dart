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
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  late PackageInfo _packageInfo = PackageInfo(
    appName: 'Golden Years',
    packageName: '',
    version: '1.0.0',
    buildNumber: '1',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  void _setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: 'Logout',
        content: 'Are you sure you want to logout?',
        confirmText: 'Logout',
        cancelText: 'Cancel',
      ),
    );

    if (confirm == true) {
      _setLoading(true);
      try {
        await Provider.of<AuthProvider>(context, listen: false).logout();
        Navigator.of(context).pushReplacementNamed('/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to logout: ${e.toString()}')),
        );
      } finally {
        _setLoading(false);
      }
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: 'Delete Account',
        content: 'Are you sure you want to permanently delete your account? This action cannot be undone.',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        isDestructive: true,
      ),
    );

    if (confirm == true) {
      _setLoading(true);
      try {
        await Provider.of<AuthProvider>(context, listen: false).deleteAccount();
        Navigator.of(context).pushReplacementNamed('/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: ${e.toString()}')),
        );
      } finally {
        _setLoading(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final userPreferences = settingsProvider.userPreferences;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            elevation: 0,
          ),
          body: ListView(
            children: [
              // Appearance Section
              SettingsSection(
                title: 'Appearance',
                children: [
                  SettingsTile(
                    title: 'Dark Mode',
                    subtitle: 'Toggle dark theme',
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                    ),
                  ),
                  SettingsTile(
                    title: 'Text Size',
                    subtitle: 'Adjust the text size',
                    trailing: DropdownButton<double>(
                      value: userPreferences.textScaleFactor,
                      items: const [
                        DropdownMenuItem(value: 0.8, child: Text('Small')),
                        DropdownMenuItem(value: 1.0, child: Text('Normal')),
                        DropdownMenuItem(value: 1.2, child: Text('Large')),
                        DropdownMenuItem(value: 1.4, child: Text('Extra Large')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          settingsProvider.updateTextSize(value);
                        }
                      },
                    ),
                  ),
                ],
              ),

              // Notifications Section
              SettingsSection(
                title: 'Notifications',
                children: [
                  SettingsTile(
                    title: 'Push Notifications',
                    subtitle: 'Receive push notifications',
                    trailing: Switch(
                      value: userPreferences.pushNotificationsEnabled,
                      onChanged: (value) {
                        settingsProvider.updatePushNotifications(value);
                      },
                    ),
                  ),
                  SettingsTile(
                    title: 'Email Notifications',
                    subtitle: 'Receive email updates',
                    trailing: Switch(
                      value: userPreferences.emailNotificationsEnabled,
                      onChanged: (value) {
                        settingsProvider.updateEmailNotifications(value);
                      },
                    ),
                  ),
                ],
              ),

              // Account Section
              SettingsSection(
                title: 'Account',
                children: [
                  SettingsTile(
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    onTap: () => _handleLogout(context),
                  ),
                  SettingsTile(
                    title: 'Delete Account',
                    subtitle: 'Permanently delete your account',
                    onTap: () => _handleDeleteAccount(context),
                    titleColor: Colors.red,
                  ),
                ],
              ),

              // About Section
              SettingsSection(
                title: 'About',
                children: [
                  SettingsTile(
                    title: 'Version',
                    subtitle: _packageInfo.version,
                  ),
                  SettingsTile(
                    title: 'Terms of Service',
                    onTap: () => launchURL('https://goldenyears.com/terms'),
                  ),
                  SettingsTile(
                    title: 'Privacy Policy',
                    onTap: () => launchURL('https://goldenyears.com/privacy'),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_isLoading) const LoadingOverlay(),
      ],
    );
  }
}