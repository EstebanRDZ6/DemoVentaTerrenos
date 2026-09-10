import 'package:flutter/foundation.dart';

import '../models/app_user.dart';

class ManagedUser {
  ManagedUser({
    required this.username,
    required this.fullName,
    required this.email,
    this.role = UserRole.seller,
    this.canCreateListings = true,
    this.canUseCrm = true,
  });

  final String username;
  final String fullName;
  final String email;
  UserRole role;
  bool canCreateListings;
  bool canUseCrm;
}

class AccessService {
  AccessService._();
  static final AccessService instance = AccessService._();

  final ValueNotifier<List<ManagedUser>> users = ValueNotifier<List<ManagedUser>>(<ManagedUser>[
    ManagedUser(username: 'vendedor', fullName: 'Vendedor Demo', email: 'vendedor@demo.com'),
  ]);

  void update(ManagedUser user, {UserRole? role, bool? canCreateListings, bool? canUseCrm}) {
    user.role = role ?? user.role;
    user.canCreateListings = canCreateListings ?? user.canCreateListings;
    user.canUseCrm = canUseCrm ?? user.canUseCrm;
    users.value = List<ManagedUser>.from(users.value);
  }

  ManagedUser? find(String username) {
    for (final ManagedUser user in users.value) {
      if (user.username.toLowerCase() == username.toLowerCase()) return user;
    }
    return null;
  }
}
