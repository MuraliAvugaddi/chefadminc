import 'package:chefadmin/controllers/token_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TokenStatusScreen extends StatelessWidget {
  TokenStatusScreen({super.key});
  final TokenStatsController controller = Get.put(TokenStatsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Token Dashboard"),
        backgroundColor: const Color(0xffFFC800),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchDashboardData(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value, style: const TextStyle(color: Colors.red)));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsSection(
                title: "Today's Tokens",
                subtitle: DateFormat('MMMM d, yyyy').format(DateTime.now()),
                stats: controller.todayStats,
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              _buildStatsSection(
                title: "Yesterday's Tokens",
                subtitle: DateFormat('MMMM d, yyyy').format(DateTime.now().subtract(const Duration(days: 1))),
                stats: controller.yesterdayStats,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatsSection({
    required String title,
    required String subtitle,
    required Map<String, int> stats,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemBuilder: (context, index) {
            String mealType = stats.keys.elementAt(index);
            int count = stats.values.elementAt(index);
            return StatCard(title: mealType, count: count);
          },
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final int count;
  const StatCard({super.key, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87)),
            const SizedBox(height: 8),
            Text('$count',
                style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFFAC30A))),
          ],
        ),
      ),
    );
  }
}
