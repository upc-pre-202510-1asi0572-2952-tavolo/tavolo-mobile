class SignInResponse {
  final int id;
  final String username;
  final String token;
  final List<String> roles;

  SignInResponse({
    required this.id,
    required this.username,
    required this.token,
    required this.roles,
  });

  factory SignInResponse.fromJson(Map<String, dynamic> json) {
    return SignInResponse(
      id: json['id'],
      username: json['username'],
      token: json['token'],
      roles: List<String>.from(json['roles']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'token': token,
    'roles': roles,
  };
}