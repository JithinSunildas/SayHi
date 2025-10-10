import '../models/user.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class AuthController {
  final String serverUrl;
  User? _currentUser;
  late Box<User> _userBox;

  AuthController(this.serverUrl) {
    _userBox = Hive.box<User>('userBox');
    _loadUser();
  }

  User? get currentUser => _currentUser;

  void _loadUser() {
    _currentUser = _userBox.get('currentUser');
  }

  Future<void> _saveUser(User user) async {
    await _userBox.put('currentUser', user);
  }

  Future<void> logout() async {
    _currentUser = null;
    await _userBox.delete('currentUser');
  }

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

      if (response.statusCode == 200) {
        _currentUser = User(username: username, password: password);
        await _saveUser(_currentUser!);
        return true;
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        _currentUser = User(username: username, password: password);
        await _saveUser(_currentUser!);
        return true;
      }
      return false;
    } catch (e) {
      print('Signup error: $e');
      return false;
    }
  }
}
