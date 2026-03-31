import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/analytics_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../utils/constants.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsProvider>(context, listen: false).fetchAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AnalyticsProvider>(context);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Dashboard Analytics')),
      drawer: const AppDrawer(),
      body: provider.isLoading && provider.dashboard.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: () => provider.fetchAnalytics(),
              child: provider.dashboard.isEmpty && !provider.isLoading
                  ? _buildEmptyState(isDark)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Your Performance', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                          const SizedBox(height: 24),
                          _buildStatCard(Icons.star, 'Total Points', '${provider.dashboard['totalPoints'] ?? 0}', Colors.amber, isDark),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildSmallCard(Icons.local_fire_department, 'Streak', '${provider.dashboard['currentStreak'] ?? 0}', Colors.deepOrange, isDark)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildSmallCard(Icons.check_circle, 'Finished', '${provider.dashboard['completedTasks'] ?? 0}', AppColors.primary, isDark)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildSmallCard(Icons.task, 'Active', '${provider.dashboard['activeTasks'] ?? 0}', Colors.blueAccent, isDark)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildSmallCard(Icons.add_task, 'Ticks', '${provider.dashboard['totalCompletions'] ?? 0}', Colors.purple, isDark)),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Text('Completion Rate', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 5))]),
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      height: 120,
                                      width: 120,
                                      child: CircularProgressIndicator(
                                        value: ((provider.dashboard['completionRate'] ?? 0) as num).toDouble() / 100,
                                        strokeWidth: 12,
                                        backgroundColor: isDark ? Colors.black26 : AppColors.background,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Text('${provider.dashboard['completionRate'] ?? 0}%', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary))
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Text('Overall success rate across active habits.', style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary), textAlign: TextAlign.center,)
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
            ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bar_chart, size: 80, color: AppColors.secondary),
          const SizedBox(height: 20),
          Text('No analytics yet.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text('Start completing habits to see stats!', style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 40, color: color),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
              Text(title, style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : AppColors.textSecondary, fontWeight: FontWeight.w500)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSmallCard(IconData icon, String title, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 16),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
          Text(title, style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : AppColors.textSecondary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
