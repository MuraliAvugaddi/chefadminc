import 'dart:convert';
import 'package:chefadmin/apis/apis_localhost.dart';
import 'package:http/http.dart' as http;

class MenuService {
  // Fetch active menu
  Future<Map<String, dynamic>> fetchActiveMenu() async {
    final response = await http.get(
      Uri.parse(ApiEndpoints.menuActive),
      headers: {'Content-Type': 'application/json'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data['menu'];
    } else {
      throw Exception(data['message'] ?? 'Failed to load active menu.');
    }
  }

  // Upload / Publish New Monthly Menu
  Future<bool> uploadMonthlyMenu(Map<String, dynamic> menuPayload) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.adminUploadMenu),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(menuPayload),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return true;
    } else {
      throw Exception(data['message'] ?? 'Failed to publish menu.');
    }
  }
}
