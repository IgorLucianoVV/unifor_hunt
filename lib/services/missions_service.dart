import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:unifor_hunt/services/auth_service.dart';

class MissionsService {
  final String baseUrl = const String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://127.0.0.1:3000',
  );

  Future<Map<String, dynamic>> createMission({
    required String title,
    String? description,
    int rewardPoints = 0,
    DateTime? endAt, // <= novo
  }) async {
    final token = await AuthService().getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Não autenticado');
    }

    final uri = Uri.parse('$baseUrl/missions');
    final body = <String, dynamic>{
      'title': title,
      if (description != null && description.trim().isNotEmpty) 'description': description.trim(),
      'reward_points': rewardPoints,
      if (endAt != null) 'end_at': endAt.toUtc().toIso8601String(), // ISO-8601 UTC
    };

    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(res.body.isEmpty ? '{}' : res.body);
    if (res.statusCode >= 400) {
      throw Exception(data['error'] ?? 'Erro ao criar missão');
    }
    return Map<String, dynamic>.from(data['mission'] as Map);
  }
}
