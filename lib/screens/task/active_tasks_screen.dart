import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/impact_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../utils/constants.dart';

class ActiveTasksScreen extends StatefulWidget {
  const ActiveTasksScreen({Key? key}) : super(key: key);

  @override
  State<ActiveTasksScreen> createState() => _ActiveTasksScreenState();
}

class _ActiveTasksScreenState extends State<ActiveTasksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).fetchMyTasks();
    });
  }

  void _markComplete(String userTaskId) async {
    try {
      await Provider.of<TaskProvider>(context, listen: false).completeTask(userTaskId);
      
      if (!mounted) return;
      Provider.of<ImpactProvider>(context, listen: false).fetchImpact();
      Provider.of<AnalyticsProvider>(context, listen: false).fetchAnalytics();
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Awesome! Daily marked.'), backgroundColor: AppColors.primary));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll("Exception: ", "")), backgroundColor: Colors.redAccent));
    }
  }

  void _deleteTask(String userTaskId) async {
     try {
      await Provider.of<TaskProvider>(context, listen: false).deleteUserTask(userTaskId);
      
      if (!mounted) return;
      Provider.of<ImpactProvider>(context, listen: false).fetchImpact();
      Provider.of<AnalyticsProvider>(context, listen: false).fetchAnalytics();
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task removed successfully.'), backgroundColor: Colors.orange));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll("Exception: ", "")), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('My Checklist')),
      drawer: const AppDrawer(),
      body: taskProvider.isLoading && taskProvider.myTasks.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: () => taskProvider.fetchMyTasks(),
              child: taskProvider.myTasks.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: taskProvider.myTasks.length,
                      itemBuilder: (ctx, i) {
                        var ut = taskProvider.myTasks[i];
                        bool isCompleted = ut['status'] == 'completed';
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.04), blurRadius: 10, offset: const Offset(0, 4))]
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      ut['taskId'] != null ? ut['taskId']['title'] : 'Task',
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                        child: Row(
                                          children: [
                                            const Text('🔥 ', style: TextStyle(fontSize: 16)),
                                            Text('${ut['streak']} days', style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                        onPressed: () => _deleteTask(ut['_id'])
                                      )
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: ((ut['progress'] ?? 0) as num).toDouble() / 100,
                                        minHeight: 12,
                                        backgroundColor: isDark ? Colors.black26 : AppColors.background,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text('${ut['progress']}%', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : AppColors.textSecondary)),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: isCompleted 
                                ? ElevatedButton.icon(
                                    onPressed: null,
                                    icon: const Icon(Icons.verified),
                                    label: const Text('Fully Completed'),
                                    style: ElevatedButton.styleFrom(
                                      disabledBackgroundColor: AppColors.primary.withOpacity(0.2),
                                      disabledForegroundColor: AppColors.primary,
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: taskProvider.isLoading ? null : () => _markComplete(ut['_id']),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('Mark Complete for Today', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.list_alt, size: 80, color: AppColors.secondary),
          const SizedBox(height: 20),
          Text('No active tasks yet.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text('Go to Home and start a new challenge!', style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : AppColors.textSecondary)),
        ],
      ),
    );
  }
}
