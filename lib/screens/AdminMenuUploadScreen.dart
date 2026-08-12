import 'package:chefadmin/controllers/admin_menu_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const Color primaryColor = Color(0xFFFADD73);
const Color primaryDark = Color(0xFFD5A514);
const Color darkTextColor = Color(0xFF252A27);

class AdminMenuUploadScreen extends StatelessWidget {
  const AdminMenuUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminMenuController controller = Get.put(AdminMenuController());

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      appBar: AppBar(
        title: const Text(
          "Admin - Publish Mess Menu",
          style: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month and Year Input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.monthController,
                      decoration: const InputDecoration(
                        labelText: "Month Name",
                        hintText: "e.g. September 2026",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: controller.yearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Year",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                "Select Day to Edit Items (Separate items with commas):",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkTextColor),
              ),
              const SizedBox(height: 10),

              // Day Selector Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: controller.days.map((day) {
                    bool isSelected = controller.selectedDay.value == day;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(day),
                        selected: isSelected,
                        selectedColor: primaryDark,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : darkTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => controller.changeDay(day),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Meal Input Fields for Selected Day
              _buildInputField(
                "Breakfast Items",
                controller.formControllers[controller.selectedDay.value]!['breakfast']!,
                "e.g. Idli Sambar, Coconut Chutney, Tea",
              ),
              const SizedBox(height: 12),
              _buildInputField(
                "Lunch Items",
                controller.formControllers[controller.selectedDay.value]!['lunch']!,
                "e.g. Chole, Mix Dal, Matar Pulao, Roti",
              ),
              const SizedBox(height: 12),
              _buildInputField(
                "Snacks Items",
                controller.formControllers[controller.selectedDay.value]!['snacks']!,
                "e.g. Pani Puri, Roohafza",
              ),
              const SizedBox(height: 12),
              _buildInputField(
                "Dinner Items",
                controller.formControllers[controller.selectedDay.value]!['dinner']!,
                "e.g. Soya Chilli, Dal Fry, Jeera Rice, Jalebi",
              ),
              const SizedBox(height: 30),

              // Publish Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () => controller.publishMenu(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Publish Monthly Menu",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }
}