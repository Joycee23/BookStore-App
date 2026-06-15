import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthProvider with ChangeNotifier {
  String _token = "";
  String? _email;
  String _fullName = "";
  String _phoneNumber = "";
  String _address = "";
  double _walletBalance = 0.0;

  String? get userId => _token.isNotEmpty ? _token : null; // We are using the token as user ID for simplicity
  bool get isAuthenticated => _token.isNotEmpty;
  String? get email => _email;
  String get fullName => _fullName;
  String get phoneNumber => _phoneNumber;
  String get address => _address;
  double get walletBalance => _walletBalance;

  String get _apiUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';

  bool get hasUserInfo {
    return _email != null &&
        _fullName.isNotEmpty &&
        _phoneNumber.isNotEmpty &&
        _address.isNotEmpty;
  }

  set walletBalance(double value) {
    _walletBalance = value;
    notifyListeners();
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token') ?? "";
    _email = prefs.getString('email');
    _fullName = prefs.getString('full_name') ?? "";
    _phoneNumber = prefs.getString('phone_number') ?? "";
    _address = prefs.getString('address') ?? "";

    if (userId != null) {
      try {
        final response = await http.get(Uri.parse('$_apiUrl/api/users/$userId'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          _walletBalance = (data['walletBalance'] ?? 0).toDouble();
          _email = data['email'] ?? _email;
          _fullName = data['fullName'] ?? _fullName;
          _phoneNumber = data['phoneNumber'] ?? _phoneNumber;
          _address = data['address'] ?? _address;
          
          await prefs.setString('email', _email ?? '');
          await prefs.setString('full_name', _fullName);
          await prefs.setString('phone_number', _phoneNumber);
          await prefs.setString('address', _address);
        } else {
           _token = "";
           await prefs.remove('auth_token');
        }
      } catch (e) {
        print("Lỗi lấy thông tin user từ server: $e");
      }
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _token = "";
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('email');
    await prefs.remove('full_name');
    await prefs.remove('phone_number');
    await prefs.remove('address');
    notifyListeners();
  }

  Future<void> updateUserInfo({
    required String email,
    required String fullName,
    required String phoneNumber,
    required String address,
  }) async {
    if (userId == null) return;

    _email = email;
    _fullName = fullName;
    _phoneNumber = phoneNumber;
    _address = address;

    try {
      await http.post(
        Uri.parse('$_apiUrl/api/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': userId,
          'email': email,
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'address': address,
        }),
      );
    } catch (e) {
      print("Lỗi cập nhật user: $e");
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('full_name', fullName);
    await prefs.setString('phone_number', phoneNumber);
    await prefs.setString('address', address);

    notifyListeners();
  }

  Future<String> register(String email, String password, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email.trim(),
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _token = data['token'];
        _email = data['email'];
        _fullName = data['fullName'] ?? '';
        _phoneNumber = data['phoneNumber'] ?? '';
        _address = data['address'] ?? '';
        
        await _saveToken(_token);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', _email ?? '');
        
        notifyListeners();
        Navigator.pushReplacementNamed(context, '/login');
        return "Đăng ký thành công!";
      } else {
        return data['error'] ?? "Đăng ký thất bại";
      }
    } catch (e) {
      return "Lỗi kết nối: ${e.toString()}";
    }
  }

  Future<String?> login(String email, String password, BuildContext context) async {
    if (email == 'admin@gmail.com' && password == 'admin123') {
      _token = "admin_token";
      _email = email;
      await _saveToken(_token);
      notifyListeners();
      Navigator.pushReplacementNamed(context, '/admin');
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email.trim(),
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _token = data['token'];
        _email = data['email'];
        _fullName = data['fullName'] ?? '';
        _phoneNumber = data['phoneNumber'] ?? '';
        _address = data['address'] ?? '';
        
        await _saveToken(_token);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', _email ?? '');
        await prefs.setString('full_name', _fullName);
        await prefs.setString('phone_number', _phoneNumber);
        await prefs.setString('address', _address);
        
        notifyListeners();
        if (hasUserInfo) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/user_info');
        }
        return null;
      } else {
        return data['error'] ?? "Sai email hoặc mật khẩu.";
      }
    } catch (e) {
      return "Lỗi kết nối: ${e.toString()}";
    }
  }

  Future<void> updateWalletBalance(double newBalance) async {
    if (userId == null) return;
    
    try {
      await http.post(
        Uri.parse('$_apiUrl/api/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': userId,
          'email': _email,
          'fullName': _fullName,
          'phoneNumber': _phoneNumber,
          'address': _address,
          'walletBalance': newBalance,
        }),
      );
      _walletBalance = newBalance;
      notifyListeners();
    } catch (e) {
      print("Lỗi cập nhật số dư ví: $e");
    }
  }
}
