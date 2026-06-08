import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/course_model.dart';
import '../models/audio_model.dart';
import 'package:flutter/foundation.dart';

class ApiProvider {
  // Change cette URL quand le backend Laravel est déployé
  // static const String baseUrl = 'http://192.168.1.45:8000/api/v1';
  static const String baseUrl =
      'https://bling-roundness-untangled.ngrok-free.dev/api/v1';

  // Timeout : 10 secondes max par requête
  static const Duration timeout = Duration(seconds: 10);

  final http.Client _client;

  ApiProvider({http.Client? client}) : _client = client ?? http.Client();

  // Headers communs à toutes les requêtes
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        'User-Agent': 'EcodiApp/1.0',
      };

  // ─── Cours ───────────────────────────────────────────

  // GET /api/courses
  Future<List<CourseModel>> fetchCourses() async {
    try {
      debugPrint('🌐 Appel API : $baseUrl/courses');

      final response = await _client
          .get(Uri.parse('$baseUrl/courses'), headers: _headers)
          .timeout(timeout);

      debugPrint('📡 Status : ${response.statusCode}');
      debugPrint('📦 Body : ${response.body.substring(0, 100)}');

      _checkStatus(response);

      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => CourseModel.fromJson(json)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('❌ Erreur API : $e');
      throw ApiException(message: 'Erreur réseau : $e');
    }
  }

  // GET /api/courses/{id}
  Future<CourseModel> fetchCourse(int id) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/courses/$id'), headers: _headers)
          .timeout(timeout);

      _checkStatus(response);

      final data = jsonDecode(response.body)['data'];
      return CourseModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Erreur réseau : $e');
    }
  }

  // ─── Audios ──────────────────────────────────────────

  // GET /api/audios/{courseId}
  Future<List<AudioModel>> fetchAudios(int courseId) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/audios/$courseId'), headers: _headers)
          .timeout(timeout);

      _checkStatus(response);

      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => AudioModel.fromJson(json)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Erreur réseau : $e');
    }
  }

  // ─── Recherche ───────────────────────────────────────

  // GET /api/search?q=
  Future<List<CourseModel>> search(String query) async {
    try {
      final uri =
          Uri.parse('$baseUrl/search').replace(queryParameters: {'q': query});

      final response =
          await _client.get(uri, headers: _headers).timeout(timeout);

      _checkStatus(response);

      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => CourseModel.fromJson(json)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Erreur réseau : $e');
    }
  }

  // ─── Helper ──────────────────────────────────────────

  void _checkStatus(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) return;

    switch (response.statusCode) {
      case 404:
        throw ApiException(message: 'Ressource introuvable', code: 404);
      case 500:
        throw ApiException(message: 'Erreur serveur', code: 500);
      default:
        throw ApiException(
          message: 'Erreur HTTP ${response.statusCode}',
          code: response.statusCode,
        );
    }
  }

  void dispose() => _client.close();
}

// Exception personnalisée pour les erreurs API
class ApiException implements Exception {
  final String message;
  final int? code;

  ApiException({required this.message, this.code});

  @override
  String toString() => 'ApiException: $message (code: $code)';
}
