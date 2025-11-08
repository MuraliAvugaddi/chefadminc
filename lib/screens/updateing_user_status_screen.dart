import 'package:chefadmin/controllers/updateing_user_status_controller.dart';
import 'package:chefadmin/models/user_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateingUserStatusScreen extends StatelessWidget {
  UpdateingUserStatusScreen({super.key});
  final AdminController controller = Get.put(AdminController());

  @override
  Widget build(BuildContext context) { // We need 'context' for the dialog
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Management"),
        backgroundColor: const Color(0xffFFC800),
        actions: [
          // --- NEW BUTTON ---
          IconButton(
            icon: const Icon(Icons.power_settings_new),
            tooltip: "Deactivate All Users",
            onPressed: () => controller.showDeactivateAllDialog(context), // Pass context
          ),
          // --- End of New Button ---

          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchUsers(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) => controller.updateSearchQuery(value),
              decoration: InputDecoration(
                hintText: "Search by phone or enrollment no...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.filteredUsers.isEmpty) {
                return const Center(
                    child: Text("No users found.", style: TextStyle(fontSize: 16)));
              }
              return ListView.builder(
                itemCount: controller.filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = controller.filteredUsers[index];
                  return UserStatusCard(user: user, controller: controller);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

// Your UserStatusCard widget remains unchanged.
class UserStatusCard extends StatelessWidget {
  const UserStatusCard({super.key, required this.user, required this.controller});
  final AppUser user;
  final AdminController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(user.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                      overflow: TextOverflow.ellipsis),
                ),
                Obx(
                  () => Switch(
                    value: user.isApproved.value,
                    activeColor: Colors.green,
                    onChanged: (bool value) => controller.toggleApproval(user),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow(
                Icons.confirmation_number_outlined, "Enrollment", user.enrollmentNo),
            const SizedBox(height: 8),
            _buildDetailRow(
                Icons.phone_android_outlined, "Phone", user.phonenumber),
            const SizedBox(height: 8),
            _buildDetailRow(
                Icons.school_outlined, "Course", "${user.course} - Year ${user.year}"),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.door_front_door_outlined, "Room No", user.room),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, color: Colors.teal, size: 20),
      const SizedBox(width: 12),
      Text("$label: ",
          style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
      Expanded(
          child: Text(value,
              style: const TextStyle(fontSize: 15),
              overflow: TextOverflow.ellipsis)),
    ]);
  }
}