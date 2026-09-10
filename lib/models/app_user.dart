enum UserRole { common, owner }

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.common:
        return 'Usuario comun';
      case UserRole.owner:
        return 'Dueño';
    }
  }
}

class AppUser {
  const AppUser({
    required this.username,
    required this.role,
    required this.fullName,
    required this.email,
    required this.whatsapp,
    required this.address,
  });

  final String username;
  final UserRole role;
  final String fullName;
  final String email;
  final String whatsapp;
  final String address;

  AppUser copyWith({
    String? username,
    UserRole? role,
    String? fullName,
    String? email,
    String? whatsapp,
    String? address,
  }) {
    return AppUser(
      username: username ?? this.username,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      whatsapp: whatsapp ?? this.whatsapp,
      address: address ?? this.address,
    );
  }
}
