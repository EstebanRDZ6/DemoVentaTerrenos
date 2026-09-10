enum UserRole { common, seller, owner }

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.common:
        return 'Usuario común';
      case UserRole.seller:
        return 'Vendedor';
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
    this.canCreateListings = false,
    this.canUseCrm = false,
  });

  final String username;
  final UserRole role;
  final String fullName;
  final String email;
  final String whatsapp;
  final String address;
  final bool canCreateListings;
  final bool canUseCrm;

  bool get isOwner => role == UserRole.owner;
  bool get canManage => isOwner;

  AppUser copyWith({
    String? username,
    UserRole? role,
    String? fullName,
    String? email,
    String? whatsapp,
    String? address,
    bool? canCreateListings,
    bool? canUseCrm,
  }) {
    return AppUser(
      username: username ?? this.username,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      whatsapp: whatsapp ?? this.whatsapp,
      address: address ?? this.address,
      canCreateListings: canCreateListings ?? this.canCreateListings,
      canUseCrm: canUseCrm ?? this.canUseCrm,
    );
  }
}
