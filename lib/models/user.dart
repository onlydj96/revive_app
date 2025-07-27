class User {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String role;
  final DateTime joinDate;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.role,
    required this.joinDate,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    String? role,
    DateTime? joinDate,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      joinDate: joinDate ?? this.joinDate,
    );
  }
}