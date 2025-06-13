import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tavolo_mobile/data/models/iam/signin_request.dart';
import 'package:tavolo_mobile/data/models/iam/signup_request.dart';
import 'package:tavolo_mobile/data/repositories/auth_repository.dart';
import 'package:tavolo_mobile/error/exceptions.dart';
import 'package:tavolo_mobile/presentation/auth/bloc/auth_event.dart';
import 'package:tavolo_mobile/presentation/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final isAuthenticated = await authRepository.isAuthenticated();
      if (isAuthenticated) {
        final user = await authRepository.getCurrentUser();
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(Unauthenticated());
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final request = SignInRequest(
        username: event.username,
        password: event.password,
      );
      final user = await authRepository.signIn(request);
      emit(Authenticated(user));
    } on ServerException catch (e) {
      emit(AuthError(e.message));
    } on UnauthorizedException {
      emit(AuthError('Credenciales inválidas'));
    } catch (e) {
      emit(AuthError('Ocurrió un error inesperado'));
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Primero realizamos el registro
      final signUpRequest = SignUpRequest(
        username: event.username,
        password: event.password,
        roles: event.roles,
      );
      await authRepository.signUp(signUpRequest);
      
      // Después del registro exitoso, iniciamos sesión automáticamente
      final signInRequest = SignInRequest(
        username: event.username,
        password: event.password,
      );
      final signedInUser = await authRepository.signIn(signInRequest);
      
      emit(Authenticated(signedInUser));
    } on ServerException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Ocurrió un error inesperado'));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await authRepository.signOut();
    emit(Unauthenticated());
  }
}