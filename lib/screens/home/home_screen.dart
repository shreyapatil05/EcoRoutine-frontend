import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../utils/constants.dart';
import '../task/task_detail_screen.dart';
import '../task/create_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).fetchTasks();
      Provider.of<TaskProvider>(context, listen: false).fetchMyTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final user = Provider.of<AuthProvider>(context).user;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Eco Routine'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, '/profile'),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: Text(
                  user != null ? user['name'][0].toUpperCase() : 'E',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTaskScreen())),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: taskProvider.isLoading && taskProvider.availableTasks.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: () async {
                await taskProvider.fetchTasks();
                await taskProvider.fetchMyTasks();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hi ${user?['name']?.split(' ')[0] ?? 'there'} 👋', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Text("Let's save the planet today.", style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : AppColors.textSecondary)),
                    const SizedBox(height: 32),
                    Text('Suggested Habits', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: taskProvider.availableTasks.length,
                        itemBuilder: (ctx, i) {
                          var t = taskProvider.availableTasks[i];
                          return _buildTaskCard(t, context, isDark);
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text('Your Active Tasks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                    const SizedBox(height: 16),
                    taskProvider.myTasks.isEmpty
                        ? _buildEmptyState(isDark)
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: taskProvider.myTasks.length,
                            itemBuilder: (ctx, i) {
                              var ut = taskProvider.myTasks[i];
                              return _buildActiveTaskTile(ut, isDark);
                            },
                          )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.nature_people, size: 64, color: AppColors.secondary),
            const SizedBox(height: 16),
            Text('No active tasks yet.', style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : AppColors.textSecondary)),
            const Text('Start a habit from the suggestions above!', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(dynamic task, BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)));
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16, bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 4))]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.eco, color: AppColors.primary, size: 36),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task['title'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text('${task['ecoScore'] ?? 0} pts', style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTaskTile(dynamic ut, bool isDark) {
    bool isCompleted = ut['status'] == 'completed';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: isDark ? Colors.black26 : AppColors.background, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.local_florist, color: AppColors.primary),
        ),
        title: Text(ut['taskId'] != null ? ut['taskId']['title'] : 'Task', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text('Streak: 🔥 ${ut['streak']} days', style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (ut['progress'] ?? 0) / 100,
                backgroundColor: isDark ? Colors.black26 : AppColors.background,
                color: AppColors.primary,
                minHeight: 6,
              ),
            )
          ],
        ),
        trailing: isCompleted ? const Icon(Icons.verified, color: AppColors.primary) : const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // Future expansion could map to specific task progress detail
        },
      ),
    );
  }
}
