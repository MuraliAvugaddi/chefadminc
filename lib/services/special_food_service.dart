import 'dart:convert';
import 'package:chefadmin/apis/api_endpoints.dart';
import 'package:chefadmin/apis/apis_localhost.dart';
import 'package:http/http.dart' as http;


class SpecialFoodService {
  static Future<List<dynamic>> fetchMenu(String token) async {
    try {
      final res = await http.get(
        Uri.parse(ApiEndpoints.specialFoodMenu),
        headers: {'Authorization': 'Bearer $token'},
      );
      return res.statusCode == 200 ? json.decode(res.body)['menu'] ?? [] : [];
    } catch (e) {
      return [];
    }
  }
}