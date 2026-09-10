import '../models/rental_payment.dart';

class MockRentalService {
  MockRentalService._();
  static final MockRentalService instance = MockRentalService._();

  final List<RentalPayment> _payments = <RentalPayment>[
    RentalPayment(id: 'rp1', tenant: 'Lucía Gómez', property: 'Casa 2 Dormitorios · Posadas', month: 'Septiembre 2026', dueDate: DateTime(2026, 9, 10), amountArs: 320000, status: PaymentStatus.paid, paidDate: DateTime(2026, 9, 5)),
    RentalPayment(id: 'rp2', tenant: 'Nicolás Ríos', property: 'Departamento 1 Dormitorio · Garupá', month: 'Septiembre 2026', dueDate: DateTime(2026, 9, 10), amountArs: 240000, status: PaymentStatus.pending, paidDate: null),
    RentalPayment(id: 'rp3', tenant: 'Marcos Ayala', property: 'Casa con Jardín · Candelaria', month: 'Septiembre 2026', dueDate: DateTime(2026, 9, 5), amountArs: 420000, status: PaymentStatus.overdue, paidDate: null),
    RentalPayment(id: 'rp4', tenant: 'Romina Pereyra', property: 'Duplex · Posadas Norte', month: 'Septiembre 2026', dueDate: DateTime(2026, 9, 12), amountArs: 500000, status: PaymentStatus.paid, paidDate: DateTime(2026, 9, 3)),
  ];

  List<RentalPayment> fetchPayments() => List<RentalPayment>.from(_payments);
}
