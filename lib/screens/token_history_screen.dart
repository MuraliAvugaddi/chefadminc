import 'package:chefadmin/controllers/history_controller.dart';
import 'package:chefadmin/models/tokenHostory_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TokenHistoryScreen extends StatelessWidget {
  const TokenHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TokenHistoryController controller = Get.put(TokenHistoryController());
    final mealTypes = ['All', 'Breakfast', 'Lunch', 'Snacks', 'Dinner'];

    // Responsiveness variables
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = screenWidth > 900;

    return Scaffold(
      backgroundColor: const Color(0xffF4F7FE), // Softer background
      appBar: AppBar(
        toolbarHeight: 70,
        title: Text(
          "Generation Logs",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          _buildHeaderAction(
            icon: Icons.calendar_month_outlined,
            color: const Color(0xffFFC800),
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: controller.selectedDate.value,
                firstDate: DateTime(2025),
                lastDate: DateTime.now(),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xffFFC800),
                      onPrimary: Colors.black,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) controller.updateDate(picked);
            },
            tooltip: "Filter by Date",
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 1200,
          ), // Dashboard width limit
          child: Column(
            children: [
              // --- 📅 DATE SELECTOR & FILTER BAR ---
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Color(0xffE0E0E0), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: mealTypes.map((meal) {
                            return Obx(() {
                              bool isSel =
                                  controller.selectedMealType.value == meal;
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: ChoiceChip(
                                  label: Text(meal),
                                  selected: isSel,
                                  onSelected: (_) =>
                                      controller.changeMealType(meal),
                                  selectedColor: const Color(0xffFFC800),
                                  backgroundColor: const Color(0xffF8F9FA),
                                  labelStyle: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: isSel
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSel
                                        ? Colors.black
                                        : Colors.grey[600],
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  side: BorderSide.none,
                                  showCheckmark: false,
                                ),
                              );
                            });
                          }).toList(),
                        ),
                      ),
                    ),
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffFFC800).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          DateFormat(
                            'dd MMM yyyy',
                          ).format(controller.selectedDate.value),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- 📋 LOGS GRID ---
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.historyList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xffFFC800),
                      ),
                    );
                  }
                  if (controller.historyList.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_toggle_off,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "No logs found for this selection",
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ],
                    );
                  }

                  return GridView.builder(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.all(20),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: screenWidth > 1200
                          ? 3
                          : (isWideScreen ? 2 : 1),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent:
                          100, // Compact height for cleaner dashboard
                    ),
                    itemCount: controller.historyList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == controller.historyList.length) {
                        return controller.isLoadingMore.value
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xffFFC800),
                                ),
                              )
                            : const SizedBox(height: 40);
                      }
                      return _buildHistoryCard(controller.historyList[index]);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(TokenHistoryItem item) {
    return _HoverableCard(
      child: Row(
        children: [
          // Token Badge
          Container(
            width: 60,
            decoration: BoxDecoration(
              color: const Color(0xffFFC800).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "#${item.tokenNumber}",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  item.mealType.substring(0, 3).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Room ${item.room} • ${item.enrollmentNo}",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // Time
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('h:mm a').format(item.generatedAt.toLocal()),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                DateFormat('dd MMM').format(item.generatedAt.toLocal()),
                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper Widget for Web Hover Effect
class _HoverableCard extends StatefulWidget {
  final Widget child;
  const _HoverableCard({required this.child});

  @override
  State<_HoverableCard> createState() => __HoverableCardState();
}

class __HoverableCardState extends State<_HoverableCard> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isHovered
                  ? Colors.black.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.3),
              blurRadius: isHovered ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
