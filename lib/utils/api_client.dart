import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  static String get baseUrl {
    // Nếu chạy trên máy ảo Android, localhost là 10.0.2.2.
    // Nếu chạy trên iOS Simulator, localhost là 127.0.0.1.
    return dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:3000/api';
  }

  /// Trả về URL proxy thông qua Next.js backend để bypass CORS
  static String getProxyImageUrl(String originalUrl) {
    if (!originalUrl.startsWith('http')) return originalUrl; // Local asset
    if (originalUrl.contains('/api/proxy-image')) return originalUrl; // Already proxied
    
    // Nếu baseUrl từ .env không có sẵn /api thì thêm vào
    final apiPrefix = baseUrl.endsWith('/api') ? '' : '/api';
    return '$baseUrl$apiPrefix/proxy-image?url=${Uri.encodeComponent(originalUrl)}';
  }

  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('Lỗi GET $endpoint: ${response.body}');
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('Lỗi POST $endpoint: ${response.body}');
    }
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('Lỗi PUT $endpoint: ${response.body}');
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(Uri.parse('$baseUrl$endpoint'));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('Lỗi DELETE $endpoint: ${response.body}');
    }
  }
}
