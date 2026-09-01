import 'dart:convert';
import 'package:chefadmin/apis/api_endpoints.dart';
import 'package:chefadmin/apis/apis_localhost.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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

    // 🔍 Debug prints to track what is being sent and received
    print("----------------------------------------");
    print("PATCH URL: $url");
    print("Payload: ${json.encode({'isApproved': isApproved})}");

    final response = await http.patch(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'isApproved': isApproved}),
    );

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");
    print("----------------------------------------");

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

  // ✅ fetchGlobalPayments with optional DateTime date parameter
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
}
