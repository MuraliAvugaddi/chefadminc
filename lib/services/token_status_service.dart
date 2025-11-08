import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TokenStatsService {
  // IMPORTANT: Make sure this is the correct IP of your server!
  static const String _baseUrl = "http://10.13.66.12:5000/api/tokens";

  Future<Map<String, int>> getStatsForDate(DateTime date) async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final Uri url = Uri.parse('$_baseUrl/stats?date=$formattedDate');

    try {
      // The 'headers' property has been removed as we no longer need authentication.
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // Ensure values are integers to prevent runtime errors.
        return data.map((key, value) => MapEntry(key, (value ?? 0) as int));
      } else {
        // More specific error message
        throw Exception(
          'Failed to load stats. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(
        'Failed to connect to the server. Please check your network and IP address.',
      );
    }
  }
}
