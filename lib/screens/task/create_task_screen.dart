import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../utils/constants.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({Key? key}) : super(key: key);

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _daysCtrl = TextEditingController();

  void _createTask() async {
    try {
      if (_titleCtrl.text.isEmpty || _descCtrl.text.isEmpty || _daysCtrl.text.isEmpty) {
        throw Exception("Please fill all fields");
      }
      int days = int.tryParse(_daysCtrl.text) ?? 0;
      if (days <= 0) throw Exception("Duration must be at least 1 day");

      await Provider.of<TaskProvider>(context, listen: false)
          .createTask(_titleCtrl.text.trim(), _descCtrl.text.trim(), days);
          
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Custom task requested!'), backgroundColor: AppColors.primary));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll("Exception: ", "")), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = Provider.of<TaskProvider>(context).isLoading;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Create Eco Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.eco_rounded, size: 80, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('Design Your Habit', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
            const SizedBox(height: 32),
            _buildField(_titleCtrl, 'Task Title', Icons.title, isDark),
            const SizedBox(height: 16),
            _buildField(_descCtrl, 'Description', Icons.description, isDark, maxLines: 3),
            const SizedBox(height: 16),
            _buildField(_daysCtrl, 'Duration (Days)', Icons.calendar_today, isDark, isNumber: true),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: isLoading ? null : _createTask,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: AppColors.primary,
              ),
              child: isLoading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Create & Suggest', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String lbl, IconData icon, bool isDark, {int maxLines = 1, bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: lbl,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          prefixIcon: Icon(icon, color: AppColors.primary),
        ),
      ),
    );
  }
}
