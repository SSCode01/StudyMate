import 'dart:convert';
import 'package:http/http.dart' as http;
import 'quote_model.dart';

class QuoteService {
  Future<List<Quote>> fetchQuotes() async {
    final url = Uri.parse("https://zenquotes.io/api/quotes");

    final response = await http.get(url);

    print("STATUS CODE: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) {
        return Quote(
          content: e['q'],
          author: e['a'],
        );
      }).toList();
    } else {
      throw Exception("Failed to load quotes");
    }
  }
}
