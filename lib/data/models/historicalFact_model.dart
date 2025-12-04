import 'dart:convert';

import 'package:http/http.dart' as http;

class HistoryFact {
  final String year;
  final String title;
  final String description;

  HistoryFact({
    required this.year,
    required this.title,
    required this.description,
  });

  factory HistoryFact.fromJson(Map<String, dynamic> json) {
    return HistoryFact(
      year: json['year'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

Future<List<HistoryFact>> fetchHistoricalFacts() async {
  final url = Uri.parse('https://api.dayinhistory.com/api/today/');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final events = data['events'] as List;
    return events.map((e) => HistoryFact.fromJson(e)).toList();
  } else {
    throw Exception('Failed to fetch history facts');
  }
}
