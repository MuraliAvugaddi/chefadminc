import 'package:chefadmin/controllers/history_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For date formatting (add with `flutter pub add intl`)

class TokenHistoryScreen extends StatelessWidget {
  const TokenHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Make sure to bind your controller
    final TokenHistoryController controller = Get.put(TokenHistoryController());
    final mealTypes = ['All', 'Breakfast', 'Lunch', 'Snacks', 'Dinner'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Token Generation History'),
        // --- ✨ NEW FILTER BUTTONS ---
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Container(
            color:
                Theme.of(context).appBarTheme.backgroundColor ?? Colors.white,
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Obx(
                () => ToggleButtons(
                  borderRadius: BorderRadius.circular(8.0),
                  selectedBorderColor: Colors.black87,
                  selectedColor: Colors.black87,
                  fillColor: Colors.teal.shade100,
                  color: Colors.black54,
                  constraints: BoxConstraints(minHeight: 36.0, minWidth: 70.0),
                  children: mealTypes
                      .map(
                        (meal) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(meal),
                        ),
                      )
                      .toList(),
                  isSelected: mealTypes
                      .map((meal) => meal == controller.selectedMealType.value)
                      .toList(),
                  onPressed: (int index) {
                    controller.changeMealType(mealTypes[index]);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshHistory,
        child: Obx(() {
          // --- ✨ Improved loading/empty state ---
          if (controller.isLoading.value && controller.historyList.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.historyList.isEmpty) {
            return Center(
              child: Text('No token history found for this filter.'),
            );
          }
          // --- END OF IMPROVEMENT ---

          return ListView.builder(
            controller: controller.scrollController,
            itemCount:
                controller.historyList.length + 1, // +1 for loading indicator
            itemBuilder: (context, index) {
              // --- Logic for "Load More" Indicator ---
              if (index == controller.historyList.length) {
                return Obx(() {
                  if (controller.isLoadingMore.value) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (!controller.hasMoreData.value) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(child: Text('End of history')),
                    );
                  } else {
                    return SizedBox.shrink(); // Nothing to show
                  }
                });
              }

              // --- The History Item Tile ---
              final item = controller.historyList[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  // Token number and meal type
                  leading: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '#${item.tokenNumber}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item.mealType,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  // Student details
                  title: Text(
                    item.name,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  subtitle: Text(
                    '${item.enrollmentNo ?? 'N/A'}\n' +
                        'Year: ${item.year ?? 'N/A'} | Room: ${item.room ?? 'N/A'}',
                  ),
                  // Time and Date
                  trailing: Text(
                    DateFormat(
                      'h:mm a\ndd-MM-yy',
                    ).format(item.generatedAt.toLocal()),
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
