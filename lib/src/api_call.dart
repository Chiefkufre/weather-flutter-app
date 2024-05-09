import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/src/secrets.dart';

Future<Map<String, dynamic>> fetchWeatherData() async {
  const String language = "en";
  String? apiKey = openWeatherApiKey;

  if (apiKey.isEmpty) {
    throw Exception("API key is missing. Please set 'openWeatherApiKey'.");
  }

  try {
    final Uri url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?lat=44.34&lon=10.99&lang=$language&appid=$apiKey");

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      return jsonData; // Return extracted data
    } else {
      // Handle specific error codes if needed
      throw Exception(
          "API request failed with status code: ${response.statusCode}");
    }
  } catch (e) {
    // Provide meaningful error message for users
    throw Exception("Error fetching weather data: ${e.toString()}");
  }
}

// Future getGeolocationData(String cityName, String countryCode) async {
//   String? apiKey = openWeatherApiKey;
//   try {
//     final response = await http.get(
//       Uri.parse(
//           'http://api.openweathermap.org/geo/1.0/direct?q=$cityName,$countryCode&appid=$apiKey'),
//     );
//   } on Exception catch (e) {
//     print(e);
//   }
// }
