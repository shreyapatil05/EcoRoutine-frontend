import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../utils/constants.dart';

class TaskDetailScreen extends StatefulWidget {
  final dynamic task;
  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  int _selectedDays = 7;
  final _customDaysCtrl = TextEditingController();

  void _startChallenge() async {
    try {
      int days = _selectedDays == 0 ? int.tryParse(_customDaysCtrl.text) ?? 7 : _selectedDays;
      if (days <= 0) throw Exception("Days must be positive integer");

      await Provider.of<TaskProvider>(context, listen: false).selectTask(widget.task['_id'], days);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Challenge Started!'), backgroundColor: AppColors.primary));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll("Exception: ", "")), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.task;
    final isLoading = Provider.of<TaskProvider>(context).isLoading;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('New Challenge'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: isDark ? Colors.black26 : AppColors.background, shape: BoxShape.circle),
              child: const Icon(Icons.nature_people, size: 100, color: AppColors.primary),
            ),
            const SizedBox(height: 32),
            Text(t['title'] ?? '', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
            const SizedBox(height: 16),
            Text(t['description'] ?? '', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: isDark ? Colors.white70 : AppColors.textSecondary, height: 1.5)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.public, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('${t['impactValue'] ?? 0} ${t['impactUnit'] ?? ""} Impact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
              ],
            ),
            const Divider(height: 64, thickness: 1),
            const Text('Select Duration:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildDurationChip(7, '7 Days', isDark),
                _buildDurationChip(14, '14 Days', isDark),
                _buildDurationChip(30, '30 Days', isDark),
                _buildDurationChip(0, 'Custom', isDark),
              ],
            ),
            if (_selectedDays == 0) ...[
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
                child: TextField(
                  controller: _customDaysCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Custom Days',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              )
            ],
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: isLoading ? null : _startChallenge,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: AppColors.primary,
              ),
              child: isLoading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Start Challenge', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDurationChip(int days, String label, bool isDark) {
    bool isSelected = _selectedDays == days;
    return ChoiceChip(
      label: Text(label, style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.textPrimary), fontWeight: FontWeight.bold)),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedDays = days);
      },
      selectedColor: AppColors.primary,
      backgroundColor: isDark ? Colors.black26 : AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
