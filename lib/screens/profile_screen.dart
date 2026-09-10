import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/consulta.dart';
import '../services/auth_service.dart';
import '../services/mock_property_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _auth = AuthService.instance;
  final MockPropertyService _service = MockPropertyService.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _whatsapp = TextEditingController();
  final TextEditingController _address = TextEditingController();
  bool _formInitialized = false;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _whatsapp.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUser?>(
      valueListenable: _auth.currentUser,
      builder: (BuildContext context, AppUser? user, _) {
        if (user == null) {
          _formInitialized = false;
          return Scaffold(
            appBar: AppBar(title: const Text('Perfil')),
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Inicia sesion para ver tu perfil'),
              ),
            ),
          );
        }

        if (!_formInitialized) {
          _fullName.text = user.fullName;
          _email.text = user.email;
          _whatsapp.text = user.whatsapp;
          _address.text = user.address;
          _formInitialized = true;
        }

        final List<Consulta> myConsultas = _service.fetchConsultasByUser(user.username);

        return Scaffold(
          appBar: AppBar(title: const Text('Perfil de usuario')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Rol: ${user.role.label}', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('Usuario: ${user.username}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Datos del interesado', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _fullName,
                          decoration: const InputDecoration(labelText: 'Nombre completo'),
                          validator: (String? value) => (value == null || value.trim().isEmpty)
                              ? 'Ingrese nombre'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _email,
                          decoration: const InputDecoration(labelText: 'Correo electronico'),
                          validator: (String? value) => (value == null || !value.contains('@'))
                              ? 'Correo invalido'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _whatsapp,
                          decoration: const InputDecoration(labelText: 'WhatsApp'),
                          validator: (String? value) => (value == null || value.trim().isEmpty)
                              ? 'Ingrese WhatsApp'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _address,
                          decoration: const InputDecoration(labelText: 'Direccion'),
                          validator: (String? value) => (value == null || value.trim().isEmpty)
                              ? 'Ingrese direccion'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _auth.updateProfile(
                                fullName: _fullName.text.trim(),
                                email: _email.text.trim(),
                                whatsapp: _whatsapp.text.trim(),
                                address: _address.text.trim(),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Perfil actualizado')),
                              );
                            }
                          },
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Guardar cambios'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Mis consultas (${myConsultas.length})', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 10),
                      if (myConsultas.isEmpty)
                        const Text('Aun no registraste consultas en propiedades.')
                      else
                        ...myConsultas.map(
                          (Consulta consulta) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(consulta.nombreCompleto),
                            subtitle: Text('${consulta.publicacionTitulo} · ${consulta.email}'),
                            trailing: Chip(label: Text(consulta.estado.label)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
