import 'dart:convert';
import 'package:change_life/models/todo.dart';
import 'package:http/http.dart' as http;

class ApiService {
  String url = "https://jsonplaceholder.typicode.com/todos";
  Future<List<Todo>> fetchTodos() async {
    final res = await http.get(Uri.parse(url));

    if (res.statusCode != 200) {
      throw Exception("API error: ${res.statusCode}");
    }

    final List data = jsonDecode(res.body);

    return data.map((e) => Todo.fromJson(e)).toList();
  }
}
