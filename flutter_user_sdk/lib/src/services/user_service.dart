import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user.dart';

class UserServiceException implements Exception {
  final String message;

  const UserServiceException(this.message);

  @override
  String toString() => 'UserServiceException: $message';
}

class UserService {
  UserService({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  static const _baseUrl = 'https://api.azeoo.dev/v1';
  static const _apiToken =
      'api_474758da8532e795f63bc4e5e6beca7298379993f65bb861f2e8e13c352cc4dcebcc3b10961a5c369edb05fbc0b0053cf63df1c53d9ddd7e4e5d680beb514d20';

  final http.Client _httpClient;
  final Map<int, User> _memoryCache = {};

  User? peek(int userId) => _memoryCache[userId];

  void clear(int userId) => _memoryCache.remove(userId);

  Future<User> fetchUser(int userId, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedUser = _memoryCache[userId];
      if (cachedUser != null) {
        return cachedUser;
      }
    }

    final response = await _httpClient
        .get(
          Uri.parse('$_baseUrl/users/me'),
          headers: {
            'Accept-Language': 'fr-FR',
            'X-User-Id': userId.toString(),
            'Authorization': 'Bearer $_apiToken',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw UserServiceException(
        'Erreur API ${response.statusCode} pour l’utilisateur $userId',
      );
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw const UserServiceException('Réponse API inattendue.');
    }

    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw const UserServiceException('Structure de données invalide.');
    }

    final user = User.fromJson(data);
    _memoryCache[userId] = user;
    return user;
  }
}
