import 'package:chefadmin/models/tokenHostory_model.dart';
import 'package:get/get.dart';

// --- ✅ IP ADDRESS ADDED ---
// This now points to your computer's server.
const String _baseUrl = "http://10.13.66.12:5000/api/admin";

// --- ⚠️ IMPORTANT ---
// You still need to replace this with a REAL admin login token.
// You will get this from your admin login screen.
const String _adminAuthToken = "YOUR_ADMIN_JWT_TOKEN";

class ApiService extends GetConnect {
  // --- ✨ UPDATED method signature ---
  Future<List<TokenHistoryItem>> fetchTokenHistory(
    int page,
    String mealType,
  ) async {
    try {
      // --- ✨ UPDATED URL to include mealType ---
      final response = await get(
        '$_baseUrl/history?page=$page&limit=20&mealType=$mealType',
        headers: {'Authorization': 'Bearer $_adminAuthToken'},
      );

      if (response.statusCode == 200) {
        // The API returns a map { ..., "history": [...] }
        final List<dynamic> historyJson = response.body['history'];
        return historyJson
            .map((json) => TokenHistoryItem.fromJson(json))
            .toList();
      } else {
        Get.snackbar(
          'Error Fetching History',
          response.body['message'] ?? 'Unknown server error',
        );
        return [];
      }
    } catch (e) {
      print(e.toString()); // For better debugging
      Get.snackbar('Network Error', 'Could not connect to server.');
      return [];
    }
  }
}
