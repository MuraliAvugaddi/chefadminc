import 'package:chefadmin/models/user_models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/updateing_user_status_service.dart';
import '../apis/apis_localhost.dart';

class AdminController extends GetxController {
  var isLoading = true.obs;
  final _allUsers = <AppUser>[].obs;
  var searchQuery = ''.obs;

  IO.Socket? socket;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
    _initSocketListener();
  }

  @override
  void onClose() {
    socket?.dispose();
    super.onClose();
  }

  // --- 🔌 SOCKET LISTENER (Admin Side) ---
  void _initSocketListener() {
    try {
      socket = IO.io(ApiEndpoints.socketUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });

      socket?.onConnect((_) {
        print("Connected to socket server on Admin side");
      });

      // ✅ AUTOMATIC REFRESH: When any status changes or payment is recorded, re-fetch users instantly
      socket?.on('statusUpdated', (data) {
        print("⚡ Real-time status update received! Refreshing user list...");
        fetchUsers();
      });

      socket?.onConnectError((err) => print("Socket connect error: $err"));
    } catch (e) {
      print("Socket error: $e");
    }
  }

  // --- 🔍 FILTERING LOGIC ---
  List<AppUser> get _searchBase {
    if (searchQuery.value.isEmpty) return _allUsers;
    String query = searchQuery.value.toLowerCase().trim();
    return _allUsers
        .where(
          (u) =>
              u.phonenumber.toLowerCase().contains(query) ||
              u.enrollmentNo.toLowerCase().contains(query) ||
              u.name.toLowerCase().contains(query),
        )
        .toList();
  }

  List<AppUser> get filteredUsers => _searchBase;

  // ✅ Fix for activeUsers and expiredUsers error in GridView
  List<AppUser> get activeUsers =>
      _searchBase.where((u) => u.isApproved.value).toList();

  List<AppUser> get expiredUsers =>
      _searchBase.where((u) => !u.isApproved.value).toList();

  void updateSearchQuery(String query) => searchQuery.value = query;

  // --- 📊 STATS COUNTERS (Fixes stats row errors) ---
  int get totalUsersCount => _allUsers.length;
  int get totalActiveCount => _allUsers.where((u) => u.isApproved.value).length;
  int get totalInactiveCount => _allUsers.where((u) => !u.isApproved.value).length;

  // --- 🌐 API ACTIONS ---
  void fetchUsers() async {
    try {
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
      String userId = user.id;
      await AdminService.updateUserStatus(userId, user.isApproved.value);
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

  // --- ⚠️ BULK ACTIONS (Fixes Reset Month button error) ---
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
              isDestructiveAction: true,
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

  Future<void> _deactivateAllUsers() async {
    try {
      isLoading.value = true;
      await AdminService.deactivateAllUsers();
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