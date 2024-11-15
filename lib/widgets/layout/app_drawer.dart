import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  final String? userName;
  final String? userEmail;
  final String? userImage;
  final List<DrawerItem> items;
  final VoidCallback? onLogout;

  const AppDrawer({
    Key? key,
    this.userName,
    this.userEmail,
    this.userImage,
    required this.items,
    this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ...items.map((item) => _buildDrawerItem(context, item)),
                if (onLogout != null) ...[
                  const Divider(),
                  _buildLogoutButton(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return UserAccountsDrawerHeader(
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: userImage != null ? NetworkImage(userImage!) : null,
        child: userImage == null
            ? const Icon(Icons.person, size: 40, color: AppTheme.primaryColor)
            : null,
      ),
      accountName: Text(
        userName ?? 'Guest User',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      accountEmail: Text(
        userEmail ?? '',
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, DrawerItem item) {
    return ListTile(
      leading: Icon(
        item.icon,
        color: AppTheme.primaryColor,
      ),
      title: Text(
        item.title,
        style: const TextStyle(
          fontSize: 16,
          color: AppTheme.textPrimaryColor,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        item.onTap();
      },
    );
  }

  Widget _buildLogoutButton() {
    return ListTile(
      leading: const Icon(
        Icons.logout,
        color: AppTheme.errorColor,
      ),
      title: const Text(
        'Logout',
        style: TextStyle(
          fontSize: 16,
          color: AppTheme.errorColor,
        ),
      ),
      onTap: onLogout,
    );
  }
}

class DrawerItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
