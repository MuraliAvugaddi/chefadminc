import 'package:chefadmin/models/user_models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart'
    as IO; // ✅ Added socket client import
import '../services/updateing_user_status_service.dart';

class AdminController extends GetxController {
  var isLoading = true.obs;
  final _allUsers = <AppUser>[].obs;
  var searchQuery = ''.obs;

  IO.Socket? socket; // ✅ Socket instance variable

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
    _initSocketListener(); // ✅ Listen for real-time changes
  }

  @override
  void onClose() {
    socket?.dispose(); // ✅ Clean up socket connection on close
    super.onClose();
  }

  // --- 🔌 SOCKET LISTENER ---

  void _initSocketListener() {
    try {
      // Connect to your backend socket server (update URL to match your backend environment)
      socket = IO.io('http://localhost:5000', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });

      socket?.onConnect((_) {
        print("Connected to socket server");
      });

      // Listen for backend broadcast events triggering status updates or bulk resets
      socket?.on('statusUpdated', (data) {
        // Automatically refresh the user list when any state change occurs on the server
        fetchUsers();
      });

      socket?.onConnectError((err) => print("Socket connect error: $err"));
    } catch (e) {
      print("Socket error: $e");
    }
  }

  // --- 🔍 FILTERING LOGIC ---

  // Private helper to apply search to the entire user base
  List<AppUser> get _searchBase {
    if (searchQuery.value.isEmpty) return _allUsers;
    String query = searchQuery.value.toLowerCase().trim();
    return _allUsers
        .where(
          (u) =>
              u.phonenumber.toLowerCase().contains(query) ||
              u.enrollmentNo.toLowerCase().contains(query),
        )
        .toList();
  }

  // Returns all users that match the search
  List<AppUser> get filteredUsers => _searchBase;

  // Returns only APPROVED users that match the search
  List<AppUser> get activeUsers =>
      _searchBase.where((u) => u.isApproved.value).toList();

  // Returns only EXPIRED/REVOKED users that match the search
  List<AppUser> get expiredUsers =>
      _searchBase.where((u) => !u.isApproved.value).toList();

  void updateSearchQuery(String query) => searchQuery.value = query;

  // --- 🌐 API ACTIONS ---

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
    user.isApproved.value = !originalStatus; // UI updates immediately

    try {
      await AdminService.updateUserStatus(user.id, user.isApproved.value);
      Get.snackbar(
        'Status Updated',
        "${user.name} is now ${user.isApproved.value ? 'Active' : 'Inactive'}",
        backgroundColor: user.isApproved.value ? Colors.green : Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      user.isApproved.value = originalStatus; // Rollback if server fails
      Get.snackbar('Error', 'Update failed for ${user.name}');
    }
  }

  // --- ⚠️ BULK ACTIONS ---

  // Shows the confirmation dialog
  void showDeactivateAllDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext ctx) {
        return CupertinoAlertDialog(
          title: const Text('Confirm Action'),
          content: const Text(
            'Are you sure you want to deactivate ALL users? This will stop everyone from generating tokens until you re-approve them.',
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true, // Makes the text red automatically
              onPressed: () {
                Navigator.of(ctx).pop();
                _deactivateAllUsers();
              },
              child: const Text('Deactivate All'),
            ),
          ],
        );
      },
    );
  }

  // Private method that performs the bulk reset
  Future<void> _deactivateAllUsers() async {
    try {
      isLoading.value = true;
      await AdminService.deactivateAllUsers();

      // Refresh local list to show all users as deactivated
      fetchUsers();

      Get.snackbar(
        'Success',
        'All users have been deactivated for the new month.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Bulk deactivation failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
