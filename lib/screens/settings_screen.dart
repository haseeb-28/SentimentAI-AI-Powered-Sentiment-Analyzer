import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../state/theme_provider.dart';
import '../services/storage_service.dart';
import 'history_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();
  int _historyCount = 0;

  @override
  void initState() {
    super.initState();
    _loadHistoryCount();
  }

  Future<void> _loadHistoryCount() async {
    final count = await _storageService.getHistoryCount();
    setState(() => _historyCount = count);
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to delete all analysis history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(AppConstants.errorColor),
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storageService.clearHistory();
      await _loadHistoryCount();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All history cleared'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        children: [
          // App Info
          _buildSection(
            'App Information',
            [
              _buildInfoTile(
                icon: Icons.info_outline_rounded,
                title: 'App Name',
                subtitle: AppConstants.appName,
              ),
              _buildInfoTile(
                icon: Icons.description_outlined,
                title: 'Description',
                subtitle: AppConstants.appDescription,
              ),
              _buildInfoTile(
                icon: Icons.code_rounded,
                title: 'Version',
                subtitle: '1.0.0',
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Appearance
          _buildSection(
            'Appearance',
            [
              SwitchListTile(
                secondary: Icon(
                  themeProvider.isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color: const Color(AppConstants.primaryColor),
                ),
                title: const Text('Dark Mode'),
                subtitle: Text(
                  themeProvider.isDarkMode
                      ? 'Dark theme enabled'
                      : 'Light theme enabled',
                ),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Data
          _buildSection(
            'Data',
            [
              ListTile(
                leading: const Icon(
                  Icons.history_rounded,
                  color: Color(AppConstants.primaryColor),
                ),
                title: const Text('Analysis History'),
                subtitle: Text('$_historyCount analyses saved'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(AppConstants.errorColor),
                ),
                title: const Text('Clear History'),
                subtitle: const Text('Delete all saved analyses'),
                onTap: _clearHistory,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // About
          _buildSection(
            'About',
            [
              _buildInfoTile(
                icon: Icons.psychology_rounded,
                title: 'Models',
                subtitle: 'Logistic Regression & Naive Bayes',
              ),
              _buildInfoTile(
                icon: Icons.dataset_outlined,
                title: 'Dataset',
                subtitle: 'IMDB Movie Reviews (50k)',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(AppConstants.primaryColor)),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
