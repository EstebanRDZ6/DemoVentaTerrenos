enum ConsultaEstado {
  nueva,
  seguimiento,
  visitoPropiedad,
  reserva,
  cerrado,
}

extension ConsultaEstadoLabel on ConsultaEstado {
  String get label {
    switch (this) {
      case ConsultaEstado.nueva:
        return 'Nueva consulta';
      case ConsultaEstado.seguimiento:
        return 'En seguimiento';
      case ConsultaEstado.visitoPropiedad:
        return 'Visito propiedad';
      case ConsultaEstado.reserva:
        return 'Reserva / Señado';
      case ConsultaEstado.cerrado:
        return 'Cerrado';
    }
  }
}

class Consulta {
  const Consulta({
    required this.id,
    required this.publicacionId,
    required this.publicacionTitulo,
    required this.nombreCompleto,
    required this.telefono,
    required this.email,
    required this.tipoOperacion,
    required this.interes,
    required this.ubicacion,
    required this.presupuesto,
    required this.estado,
    required this.fechaContacto,
    required this.notas,
    required this.creadoPor,
    required this.whatsapp,
    required this.direccion,
  });

  final String id;
  final String publicacionId;
  final String publicacionTitulo;
  final String nombreCompleto;
  final String telefono;
  final String email;
  final String tipoOperacion;
  final String interes;
  final String ubicacion;
  final String presupuesto;
  final ConsultaEstado estado;
  final DateTime fechaContacto;
  final String notas;
  final String creadoPor;
  final String whatsapp;
  final String direccion;

  Consulta copyWith({ConsultaEstado? estado}) {
    return Consulta(
      id: id,
      publicacionId: publicacionId,
      publicacionTitulo: publicacionTitulo,
      nombreCompleto: nombreCompleto,
      telefono: telefono,
      email: email,
      tipoOperacion: tipoOperacion,
      interes: interes,
      ubicacion: ubicacion,
      presupuesto: presupuesto,
      estado: estado ?? this.estado,
      fechaContacto: fechaContacto,
      notas: notas,
      creadoPor: creadoPor,
      whatsapp: whatsapp,
      direccion: direccion,
    );
  }
}
