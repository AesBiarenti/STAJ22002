import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class AIService {
  // Yeni backend URL'i - Android Emulator için
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // Health check
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/health'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Health check hatası: $e');
      return false;
    }
  }

  // Excel dosyası yükleme
  static Future<Map<String, dynamic>> uploadExcelFile(File file) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload-employees'),
      );

      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);

      return {
        'success': response.statusCode == 200 && jsonData['success'] == true,
        'message': jsonData['message'] ?? 'Bilinmeyen hata',
        'error': jsonData['error'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Dosya yükleme hatası: $e',
        'error': e.toString(),
      };
    }
  }

  // AI sorgusu
  static Future<Map<String, dynamic>> queryAI(String query) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'question': query}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'answer': data['answer'] ?? 'Yanıt alınamadı',
          'error': data['error'],
        };
      } else {
        return {
          'success': false,
          'answer': 'Sunucu hatası: ${response.statusCode}',
          'error': 'HTTP_ERROR',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'answer': 'Bağlantı hatası: $e',
        'error': e.toString(),
      };
    }
  }

  // Gelişmiş AI sorgusu - Chat history desteği
  static Future<Map<String, dynamic>> queryAIWithHistory(
    String query,
    List<Map<String, String>> history,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'question': query, 'history': history}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'answer': data['answer'] ?? 'Yanıt alınamadı',
          'error': data['error'],
          'context_used': data['context_used'] ?? false,
          'context_info': data['context_info'],
          'sources': data['sources'],
        };
      } else {
        return {
          'success': false,
          'answer': 'Sunucu hatası: ${response.statusCode}',
          'error': 'HTTP_ERROR',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'answer': 'Bağlantı hatası: $e',
        'error': e.toString(),
      };
    }
  }

  // Çalışan istatistikleri
  static Future<Map<String, dynamic>> getMesaiStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/employee-stats'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {'success': true, 'stats': data['stats']};
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'İstatistik alınamadı',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Sunucu hatası: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  // Tüm çalışanları getir
  static Future<Map<String, dynamic>> getAllEmployees() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/employees'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'employees': data['data'] ?? [],
          'count': data['count'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'error': 'Sunucu hatası: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }
}

/// AI yanıt modeli
class AIResponse {
  final String query;
  final String response;
  final List<Source> sources;

  AIResponse({
    required this.query,
    required this.response,
    required this.sources,
  });

  factory AIResponse.fromJson(Map<String, dynamic> json) {
    return AIResponse(
      query: json['query'] ?? '',
      response: json['response'] ?? '',
      sources:
          (json['sources'] as List?)
              ?.map((source) => Source.fromJson(source))
              .toList() ??
          [],
    );
  }
}

/// Kaynak modeli
class Source {
  final String text;
  final double score;

  Source({required this.text, required this.score});

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      text: json['text'] ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Upload yanıt modeli
class UploadResponse {
  final String message;
  final int rowsProcessed;

  UploadResponse({required this.message, required this.rowsProcessed});

  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(
      message: json['message'] ?? '',
      rowsProcessed: json['rows_processed'] ?? 0,
    );
  }
}
