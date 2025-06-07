class SignUpRequest {
  final String username;
  final String password;
  final List<String> roles;

  SignUpRequest({
    required this.username,
    required this.password,
    required this.roles,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
    'roles': roles,
  };
}