import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthController {
  final String serverUrl;
  User? _currentUser;

  AuthController(this.serverUrl);

  User? get currentUser => _currentUser;

  Future<bool> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$serverUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      // Check both status code AND response body
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          _currentUser = User(username: username, password: password);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> signup(
    String username,
    String password,
    String confirmPassword,
  ) async {
    if (username.isEmpty || password.isEmpty) {
      return false;
    }
    if (password != confirmPassword) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$serverUrl/api/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      // Check both status code AND response body
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          _currentUser = User(username: username, password: password);
          return true;
        }
      }

      // Handle 409 Conflict (user already exists)
      if (response.statusCode == 409) {
        print('User already exists - only one user allowed');
        return false;
      }

      return false;
    } catch (e) {
      print('Signup error: $e');
      return false;
    }
  }

  void logout() {
    _currentUser = null;
  }
}
