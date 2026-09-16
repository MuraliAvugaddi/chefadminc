import 'dart:convert';
import 'package:chefadmin/apis/apis_localhost.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user_models.dart';

class AdminService {
  // Fetch all users
  static Future<List<AppUser>> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.adminUsers));
      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((dynamic item) => AppUser.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Connection error');
    }
  }

  static Future<void> updateUserStatus(String userId, bool isApproved) async {
    final url = '${ApiEndpoints.adminUsers}/$userId/status';

    final response = await http.patch(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'isApproved': isApproved}),
    );

    if (response.statusCode != 200) {
      throw Exception('Update failed with status: ${response.statusCode}');
    }
  }

  static Future<void> deactivateAllUsers() async {
    final response = await http.patch(
      Uri.parse('${ApiEndpoints.adminUsers}/deactivate-all'),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Deactivate all failed with status: ${response.statusCode}',
      );
    }
  }

  // ✅ Fetch Global Payments with optional DateTime date parameter
  static Future<List<dynamic>> fetchGlobalPayments(
    String month,
    String gender, {
    DateTime? date,
  }) async {
    String url = "${ApiEndpoints.adminAllPayments}?month=$month&gender=$gender";
    if (date != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      url += "&date=$formattedDate";
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Payment fetch failed');
  }

  static Future<List<dynamic>> getSkipReport(
    String date,
    String mealType,
  ) async {
    final String url =
        "${ApiEndpoints.adminSkipReport}?date=$date&mealType=$mealType";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body)['report'] ?? [];
    }
    throw Exception('Skip report failed');
  }

  // ============================================================
  // ✅ FETCH STUDENT FEEDBACK METHOD (Admin Side)
  // ============================================================
  static Future<List<dynamic>> fetchStudentFeedback({DateTime? date}) async {
    try {
      final box = GetStorage();
      final token = box.read('token');

      String url = ApiEndpoints.adminFeedbackList;
      if (date != null) {
        String formattedDate = DateFormat('yyyy-MM-dd').format(date);
        url += "?date=$formattedDate";
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load feedback records');
      }
    } catch (e) {
      throw Exception('Connection error while fetching feedback: $e');
    }
  }
}