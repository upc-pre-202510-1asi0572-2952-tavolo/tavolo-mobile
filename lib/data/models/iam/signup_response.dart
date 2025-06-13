class SignUpResponse {
  final int id;
  final String username;
  final List<String> roles;

  SignUpResponse({
    required this.id,
    required this.username,
    required this.roles,
  });

  factory SignUpResponse.fromJson(Map<String, dynamic> json) {
    return SignUpResponse(
      id: json['id'],
      username: json['username'],
      roles: List<String>.from(json['roles']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'roles': roles,
  };
}