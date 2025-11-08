import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_models.dart';

class AdminService {
  // IMPORTANT: Make sure this is the correct IP of your server!
  static const String _baseUrl = "http://10.13.66.12:5000/api/admin/users";

  static Future<List<AppUser>> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((dynamic item) => AppUser.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to load users. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(
          'Failed to connect to the server. Please check your network and IP address.');
    }
  }

  static Future<void> updateUserStatus(String userId, bool isApproved) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/$userId/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'isApproved': isApproved}),
      );
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update user status. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server to update status.');
    }
  }

  // --- NEW METHOD ---
  static Future<void> deactivateAllUsers() async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/deactivate-all'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to deactivate all users. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server to deactivate all users.');
    }
  }
}