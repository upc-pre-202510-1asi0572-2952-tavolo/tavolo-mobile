import 'dart:convert';
import 'package:tavolo_mobile/conf/api_client.dart';
import 'package:tavolo_mobile/data/models/iam/signin_response.dart';
import 'package:tavolo_mobile/data/models/iam/signin_request.dart';
import 'package:tavolo_mobile/data/models/iam/signup_request.dart';
import 'package:tavolo_mobile/data/models/iam/signup_response.dart';
import 'package:tavolo_mobile/error/exceptions.dart';
import 'package:tavolo_mobile/storage/secure_storage.dart';

class AuthRepository {
  final ApiClient apiClient;
  final SecureStorage secureStorage;

  AuthRepository({
    required this.apiClient,
    required this.secureStorage,
  });

  Future<SignUpResponse> signUp(SignUpRequest request) async {
    try {
      final response = await apiClient.post(
        '/api/v1/authentication/sign-up',
        body: request.toJson(),
      );
      
      return SignUpResponse.fromJson(response);
    } on ServerException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<SignInResponse> signIn(SignInRequest request) async {
    try {
      final response = await apiClient.post(
        '/api/v1/authentication/sign-in',
        body: request.toJson(),
      );
      
      final authResponse = SignInResponse.fromJson(response);
      
      // Guardar token y datos del usuario
      await secureStorage.saveToken(authResponse.token);
      await secureStorage.saveUser(json.encode(authResponse.toJson()));
      
      return authResponse;
    } on ServerException catch (e) {
      throw ServerException(message: e.message);
    } on UnauthorizedException {
      throw UnauthorizedException();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await secureStorage.getToken();
    return token != null;
  }

  Future<SignInResponse?> getCurrentUser() async {
    final userJson = await secureStorage.getUser();
    if (userJson == null) return null;
    
    try {
      final userData = json.decode(userJson);
      return SignInResponse.fromJson(userData);
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    await secureStorage.clearAll();
  }
}