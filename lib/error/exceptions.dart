class ServerException implements Exception {
  final String message;

  ServerException({required this.message});
}

class UnauthorizedException implements Exception {}

class CacheException implements Exception {}
