import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../data/models/quiz_model.dart';

class AIService {
  static const String _realDeviceHost = "http://10.10.246.88:5000";

  static String get _baseUrl {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:5000";
    } else if (Platform.isIOS) {
      return "http://localhost:5000";
    } else {
      return _realDeviceHost;
    }
  }

  Future<String?> getSummary(String text) async {
    try {
      final response = await http
          .post(
            Uri.parse("$_baseUrl/summarize"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"text": text}),
          )
          .timeout(
            const Duration(seconds: 360),
            onTimeout: () {
              throw Exception(
                'Request timeout - Server took too long to respond',
              );
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['summary'] as String?;
      } else if (response.statusCode == 503) {
        return "Error: Ollama AI service is not running. Please start Ollama.";
      } else {
        final data = jsonDecode(response.body);
        return "Error: ${data['error'] ?? 'Unknown error'}";
      }
    } on http.ClientException {
      return "Error: Cannot connect to AI server. Make sure Flask is running on port 5000.";
    } on SocketException {
      return "Error: Network error. Check your connection and server.";
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<List<QuizQuestion>?> getQuiz(String text) async {
    try {
      final response = await http
          .post(
            Uri.parse("$_baseUrl/quiz"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"text": text}),
          )
          .timeout(
            const Duration(seconds: 360),
            onTimeout: () {
              throw Exception(
                'Request timeout - Quiz generation took too long',
              );
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List quizList = data["quiz"];
        return quizList.map((q) => QuizQuestion.fromJson(q)).toList();
      } else if (response.statusCode == 503) {
        print("Ollama is not running");
        return null;
      }
      return null;
    } on http.ClientException {
      print("Cannot connect to Flask server");
      return null;
    } on SocketException {
      print("Network error - check server connection");
      return null;
    } catch (e) {
      print("Quiz error: $e");
      return null;
    }
  }

  Future<bool> checkConnection() async {
    try {
      final response = await http
          .get(Uri.parse("$_baseUrl/health"))
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print("Connection check failed: $e");
      return false;
    }
  }
}
