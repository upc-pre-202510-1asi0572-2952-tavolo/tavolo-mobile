abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String username;
  final String password;

  SignInRequested({required this.username, required this.password});
}

class SignUpRequested extends AuthEvent {
  final String username;
  final String password;
  final List<String> roles;

  SignUpRequested({
    required this.username,
    required this.password,
    required this.roles,
  });
}

class SignOutRequested extends AuthEvent {}