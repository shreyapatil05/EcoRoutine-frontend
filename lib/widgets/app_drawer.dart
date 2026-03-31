import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/task/active_tasks_screen.dart';
import '../../screens/analytics/analytics_screen.dart';
import '../../screens/analytics/impact_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/support/support_screen.dart';
import '../../utils/constants.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final user = Provider.of<AuthProvider>(context).user;

    return Drawer(
      backgroundColor: Theme.of(context).cardColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Text(user != null ? user['name'][0].toUpperCase() : 'E', style: TextStyle(color: AppColors.primary, fontSize: 30, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 12),
                Text(
                  user != null ? user['name'] : 'Eco Routine',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _buildItem(context, Icons.home, 'Home', const HomeScreen(), isDark),
          _buildItem(context, Icons.check_box, 'My Tasks', const ActiveTasksScreen(), isDark),
          _buildItem(context, Icons.bar_chart, 'Analytics', const AnalyticsScreen(), isDark),
          _buildItem(context, Icons.public, 'Impact', const ImpactScreen(), isDark),
          _buildItem(context, Icons.person, 'Profile', const ProfileScreen(), isDark),
          const Divider(),
          _buildItem(context, Icons.settings, 'Settings', const SettingsScreen(), isDark),
          _buildItem(context, Icons.help, 'Help & Support', const SupportScreen(), isDark),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String title, Widget target, bool isDark) {
    return ListTile(
      leading: Icon(icon, color: isDark ? Colors.white70 : AppColors.textPrimary),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textPrimary)),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => target));
      },
    );
  }
}
