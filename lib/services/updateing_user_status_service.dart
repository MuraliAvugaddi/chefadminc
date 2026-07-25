import 'dart:convert';
import 'package:chefadmin/apis/api_endpoints.dart';
import 'package:chefadmin/apis/apis_localhost.dart';
import 'package:http/http.dart' as http;
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
    final response = await http.patch(
      Uri.parse('${ApiEndpoints.adminUsers}/$userId/status'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'isApproved': isApproved}),
    );
    if (response.statusCode != 200) throw Exception('Update failed');
  }

  static Future<void> deactivateAllUsers() async {
    await http.patch(Uri.parse('${ApiEndpoints.adminUsers}/deactivate-all'));
  }

  static Future<List<dynamic>> fetchGlobalPayments(
    String month,
    String gender,
  ) async {
    final String url =
        "${ApiEndpoints.adminAllPayments}?month=$month&gender=$gender";
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
