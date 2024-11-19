import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/confirmation_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: 'Logout',
        content: 'Are you sure you want to logout?',
        confirmText: 'Logout',
        cancelText: 'Cancel',
      ),
    );

    if (shouldLogout ?? false) {
      setState(() => _isLoading = true);
      try {
        await context.read<AuthProvider>().signOut();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryGreen,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(user),
                  const SizedBox(height: 32),
                  _buildSettingsSection(),
                  const SizedBox(height: 32),
                  _buildAccountSection(),
                  const SizedBox(height: 32),
                  _buildLogoutButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
              child: user?.photoURL != null
                  ? ClipOval(
                      child: Image.network(
                        user!.photoURL!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 50,
                      color: AppTheme.primaryGreen,
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? 'Pet Parent',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Settings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildSettingTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () => Navigator.pushNamed(context, '/notifications-settings'),
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.lock_outline,
                title: 'Privacy',
                onTap: () => Navigator.pushNamed(context, '/privacy-settings'),
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.language_outlined,
                title: 'Language',
                onTap: () => Navigator.pushNamed(context, '/language-settings'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Account',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildSettingTile(
                icon: Icons.security_outlined,
                title: 'Security',
                onTap: () => Navigator.pushNamed(context, '/security-settings'),
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () => Navigator.pushNamed(context, '/help-support'),
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.info_outline,
                title: 'About',
                onTap: () => Navigator.pushNamed(context, '/about'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGreen),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      endIndent: 16,
      color: Colors.grey[200],
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handleLogout,
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
