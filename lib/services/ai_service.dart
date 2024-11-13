import 'dart:convert';
import 'package:http/http.dart' as http;
class AIService {
  static const String _apiUrl = 'https://api-inference.huggingface.co/models/openai-community/gpt2';
  static const Map<String, String> _headers = {
    'Authorization': 'Bearer hf_***************************',
    'Content-Type': 'application/json',
  };

  Future<String> analyzeData(List<Map<String, dynamic>> data) async {
    final inputs = data.map((e) => 'Usage: ${e['usage']} GB').join('\n');
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: _headers,
      body: jsonEncode({'inputs': inputs}),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result is List && result.isNotEmpty && result[0] is Map) {
        return result[0]['generated_text'] ?? 'No insight available';
      } else {
        return 'No insight available';
      }
    } else {
      print('API Error: ${response.body}');
      throw Exception('Failed to load insight');
    }
  }
}
