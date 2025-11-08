import 'package:chefadmin/models/user_models.dart';
import 'package:flutter/cupertino.dart'; // Import Cupertino
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/updateing_user_status_service.dart';

class AdminController extends GetxController {
  // <-- FIX 1: Was [
  var isLoading = true.obs;
  final _allUsers = <AppUser>[].obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    // <-- FIX 2: Was oninit
    super.onInit(); // <-- FIX 3: Was oninit
    fetchUsers();
  }

  List<AppUser> get filteredUsers {
    // <-- FIX 4: Removed the bad comment line
    if (searchQuery.value.isEmpty) {
      return _allUsers;
    } else {
      String query = searchQuery.value.toLowerCase().trim();
      return _allUsers
          .where(
            (user) =>
                user.phonenumber.toLowerCase().contains(query) ||
                user.enrollmentNo.toLowerCase().contains(query),
          )
          .toList();
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void fetchUsers() async {
    try {
      isLoading.value = true;
      var fetchedUsers = await AdminService.fetchUsers();
      _allUsers.assignAll(fetchedUsers);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch users: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleApproval(AppUser user) async {
    bool originalStatus = user.isApproved.value;
    user.isApproved.value = !originalStatus;

    try {
      await AdminService.updateUserStatus(user.id, user.isApproved.value);
      Get.snackbar(
        'Success',
        "${user.name}'s status updated.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      user.isApproved.value = originalStatus;
      Get.snackbar('Error', 'Failed to update status for ${user.name}.');
    }
  }

  // --- NEW METHODS ---

  // 1. Shows the confirmation dialog
  void showDeactivateAllDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext ctx) {
        return CupertinoAlertDialog(
          title: const Text('Confirm Action'),
          content: const Text(
            'Are you sure you want to deactivate ALL users? This will stop them from generating tokens until you re-approve them one-by-one.',
          ),
          actions: [
            // "No" button
            CupertinoDialogAction(
              child: const Text('No', style: TextStyle(color: Colors.blue)),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            // "Yes" button
            CupertinoDialogAction(
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(ctx).pop(); // Close the dialog
                _deactivateAllUsers(); // Call the function to do the work
              },
            ),
          ],
        );
      },
    );
  }

  // 2. Private method that does the work
  Future<void> _deactivateAllUsers() async {
    try {
      isLoading.value = true; // Show loading spinner
      await AdminService.deactivateAllUsers();
      fetchUsers(); // Refresh the user list
      Get.snackbar(
        'Success',
        'All users have been deactivated.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to deactivate users: ${e.toString()}');
    } finally {
      isLoading.value = false; // Hide loading spinner
    }
  }
}
