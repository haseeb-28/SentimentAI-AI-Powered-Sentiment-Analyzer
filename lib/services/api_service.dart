import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/sentiment_response.dart';
import '../models/movie_response.dart';

class ApiService {
  // Change this to your backend URL
  // For local development (Android emulator): 'http://10.0.2.2:8000'
  // For iOS simulator: 'http://localhost:8000'
  // For physical device: 'http://YOUR_COMPUTER_IP:8000'
  // For production: 'https://your-backend-domain.com'
  // For Android emulator use 10.0.2.2 to reach host machine
  // If you run on iOS simulator change to 'http://localhost:8000'
  static const String _baseUrl = 'http://localhost:8000';

  // Optional: if you use authentication
  static const String? _authToken = null; // or set your token here

  Future<MovieResponse> searchMovie(String movieName) async {
    final uri = Uri.parse('$_baseUrl/api/search');

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    final body = jsonEncode({'movie_name': movieName});

    try {
      final response = await http
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
        return MovieResponse.fromJson(jsonMap);
      } else if (response.statusCode == 400) {
        throw Exception('Invalid movie name. Please try again.');
      } else if (response.statusCode == 404) {
        throw Exception('Movie not found. Please check the name.');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authentication error. Please check your credentials.');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      // Network error, timeout, parsing error, etc.
      throw Exception('Failed to connect: $e');
    }
  }

  Future<SentimentResponse> predictSentiment(String text) async {
    final uri = Uri.parse('$_baseUrl/api/predict');

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    final body = jsonEncode({'text': text});

    try {
      final response = await http
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
        return SentimentResponse.fromJson(jsonMap);
      } else if (response.statusCode == 400) {
        throw Exception('Invalid input. Please check your text.');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authentication error. Please check your credentials.');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      // Network error, timeout, parsing error, etc.
      throw Exception('Failed to connect: $e');
    }
  }
}

