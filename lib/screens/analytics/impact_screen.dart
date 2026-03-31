import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/impact_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../utils/constants.dart';

class ImpactScreen extends StatefulWidget {
  const ImpactScreen({Key? key}) : super(key: key);

  @override
  State<ImpactScreen> createState() => _ImpactScreenState();
}

class _ImpactScreenState extends State<ImpactScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ImpactProvider>(context, listen: false).fetchImpact();
    });
  }

  IconData _getIcon(String name) {
    name = name.toLowerCase();
    if (name.contains("water") || name.contains("liquid")) return Icons.water_drop;
    if (name.contains("co2") || name.contains("cloud") || name.contains("methane") || name.contains("air")) return Icons.cloud;
    if (name.contains("plastic") || name.contains("recycle") || name.contains("trash")) return Icons.recycling;
    if (name.contains("energy") || name.contains("power") || name.contains("light")) return Icons.bolt;
    if (name.contains("tree") || name.contains("wood") || name.contains("plant")) return Icons.park;
    return Icons.eco;
  }

  Color _getColor(String name) {
    name = name.toLowerCase();
    if (name.contains("water")) return Colors.blue;
    if (name.contains("co2") || name.contains("methane")) return Colors.brown;
    if (name.contains("plastic") || name.contains("recycle")) return Colors.teal;
    if (name.contains("energy")) return Colors.amber;
    return AppColors.primary;
  }

  String _formatImpactSentence(Map<String, dynamic> item) {
    String name = item['impactName'] ?? "Impact";
    var value = item['total'] ?? 0;
    String unit = item['unit'] ?? "points";

    String lowerName = name.toLowerCase();

    if (lowerName.contains("co2")) return "You reduced $value g CO₂";
    if (lowerName.contains("water")) return "You saved $value liters of water";
    if (lowerName.contains("plastic")) return "You avoided $value g plastic";
    if (lowerName.contains("energy")) return "You saved $value kWh energy";
    if (lowerName.contains("methane")) return "You reduced $value g methane";

    return "$name: $value $unit";
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ImpactProvider>(context);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('My Environmental Impact')),
      drawer: const AppDrawer(),
      body: provider.isLoading && provider.impacts.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: () => provider.fetchImpact(),
              child: provider.impacts.isEmpty
                  ? _buildEmptyState(isDark)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.public, size: 80, color: Colors.white),
                                SizedBox(height: 16),
                                Text('You are making a difference!', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 48),
                          Text('Green Contributions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                          const SizedBox(height: 24),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: provider.impacts.length,
                            itemBuilder: (context, index) {
                              final impact = provider.impacts[index];
                              String name = impact['impactName'] ?? "Impact";
                              
                              Color color = _getColor(name);
                              IconData icon = _getIcon(name);
                              String sentence = _formatImpactSentence(impact);

                              return _buildImpactRow(icon, sentence, color, isDark);
                            },
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
          const Icon(Icons.nature_people, size: 80, color: AppColors.secondary),
          const SizedBox(height: 20),
          Text('No impact yet.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text('Start completing habits to see your impact!', style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildImpactRow(IconData icon, String sentence, Color color, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.04), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(sentence, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
          )
        ],
      ),
    );
  }
}
