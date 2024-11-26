import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey = 'YOUR_API_KEY';

  Future<List<String>> fetchJournalingIdeas(String prompt) async {
    final url = Uri.parse('https://api.openai.com/v1/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
    final body = jsonEncode({
      'model': 'text-davinci-003',
      'prompt': prompt,
      'max_tokens': 150,
      'n': 5,
      'stop': null,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['choices'].map((choice) => choice['text']));
    } else {
      throw Exception('Failed to fetch journaling ideas');
    }
  }
}
