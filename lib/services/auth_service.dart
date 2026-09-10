import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import 'access_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();
  final ValueNotifier<AppUser?> currentUser = ValueNotifier<AppUser?>(null);

  bool login({required String username, required String password}) {
    final String normalizedUser = username.trim().toLowerCase();
    final String normalizedPass = password.trim().toLowerCase();
    if (normalizedUser == 'sitios' && normalizedPass == 'propiedades') {
      currentUser.value = const AppUser(username: 'Sitios', role: UserRole.owner, fullName: 'Administrador Sitios', email: 'sitiospropiedades@gmail.com', whatsapp: '+54 9 3764 26-0767', address: 'Av. Francisco de Haro 1234, Posadas, Misiones', canCreateListings: true, canUseCrm: true);
      return true;
    }
    final ManagedUser? managed = AccessService.instance.find(normalizedUser);
    if (managed != null && normalizedPass == '1234') {
      currentUser.value = AppUser(username: managed.username, role: managed.role, fullName: managed.fullName, email: managed.email, whatsapp: '+54 9 3764 00-1111', address: 'Posadas, Misiones', canCreateListings: managed.canCreateListings, canUseCrm: managed.canUseCrm);
      return true;
    }
    if (normalizedUser == 'cliente' && normalizedPass == '1234') {
      currentUser.value = const AppUser(username: 'Cliente', role: UserRole.common, fullName: 'Usuario Comun', email: 'cliente@demo.com', whatsapp: '+54 9 3764 00-0000', address: 'Barrio Centro, Posadas, Misiones');
      return true;
    }
    return false;
  }

  void logout() => currentUser.value = null;

  void updateProfile({required String fullName, required String email, required String whatsapp, required String address}) {
    final AppUser? user = currentUser.value;
    if (user == null) return;
    currentUser.value = user.copyWith(fullName: fullName, email: email, whatsapp: whatsapp, address: address);
  }
}
