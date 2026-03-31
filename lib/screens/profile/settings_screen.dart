import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Text(
          'Settings Configurations', 
          style: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold, 
            color: isDark ? Colors.white : AppColors.textPrimary
          )
        ),
      ),
    );
  }
}
