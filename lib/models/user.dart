class AppUser {
  final int id;
  final String name;
  final String role;
  final String outlet;

  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    required this.outlet,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      name: json['name'] as String,
      role: json['role'] as String,
      outlet: json['outlet'] as String,
    );
  }
}
