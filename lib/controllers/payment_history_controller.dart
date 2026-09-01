import 'package:chefadmin/services/updateing_user_status_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PaymentHistoryController extends GetxController {
  var isLoading = true.obs;
  var payments = <dynamic>[].obs;

  var selectedMonth = DateFormat('MMMM yyyy').format(DateTime.now()).obs;
  var selectedGender = 'All'.obs;
  var selectedDate = Rxn<DateTime>();
  var searchQuery = ''.obs; // 👈 Search query observable

  // 📊 Filtered payments based on search query
  List<dynamic> get filteredPayments {
    if (searchQuery.value.isEmpty) return payments;
    String q = searchQuery.value.toLowerCase().trim();
    return payments.where((p) {
      final user = p['userId'] ?? {};
      String name = (user['name'] ?? '').toString().toLowerCase();
      String enrollment = (user['enrollmentNo'] ?? '').toString().toLowerCase();
      String phone = (user['phonenumber'] ?? '').toString().toLowerCase();
      String txnId = (p['transactionId'] ?? '').toString().toLowerCase();
      return name.contains(q) ||
          enrollment.contains(q) ||
          phone.contains(q) ||
          txnId.contains(q);
    }).toList();
  }

  // 📊 Live Calculated Metrics based on filtered results
  int get totalStudentsPaid => filteredPayments.length;
  int get onlineCount =>
      filteredPayments.where((p) => p['method'] != 'offline').length;
  int get cashCount =>
      filteredPayments.where((p) => p['method'] == 'offline').length;

  double get totalCollection =>
      filteredPayments.fold(0, (sum, item) => sum + (item['amount'] ?? 0));

  @override
  void onInit() {
    super.onInit();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    try {
      isLoading(true);
      final data = await AdminService.fetchGlobalPayments(
        selectedMonth.value,
        selectedGender.value,
        date: selectedDate.value,
      );
      payments.assignAll(data);
    } catch (e) {
      Get.snackbar(
        "Sync Error",
        "Failed to sync payment records",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  // 🔍 Fixes the red squiggly error on your TextField
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void updateFilters({
    String? month,
    String? gender,
    DateTime? date,
    bool clearDate = false,
  }) {
    if (month != null) selectedMonth.value = month;
    if (gender != null) selectedGender.value = gender;
    if (clearDate) {
      selectedDate.value = null;
    } else if (date != null) {
      selectedDate.value = date;
    }
    fetchPayments();
  }
}
