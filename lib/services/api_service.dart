import 'dart:convert';
import 'package:change_life/models/todo.dart';
import 'package:http/http.dart' as http;

class ApiService {

  Future<List<Todo>> fetchTodos() async {

  final res = await http.get(Uri.parse("https://jsonplaceholder.typicode.com/todos"))

    final data = jsonDecode(res.body);

    final list = data.map<Todo>((e) {
      return Todo.fromJson(e);
    }).toList();

    return list;
  }

}