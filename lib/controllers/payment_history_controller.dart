import 'package:chefadmin/services/updateing_user_status_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PaymentHistoryController extends GetxController {
  var isLoading = true.obs;
  var payments = <dynamic>[].obs;

  var selectedMonth = DateFormat('MMMM yyyy').format(DateTime.now()).obs;
  var selectedGender = 'All'.obs;
  var selectedDate = Rxn<DateTime>(); // 👈 Calendar date support

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
      Get.snackbar("Sync Error", "Failed to sync payment records", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  void updateFilters({String? month, String? gender, DateTime? date, bool clearDate = false}) {
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