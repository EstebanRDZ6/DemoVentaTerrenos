enum PaymentStatus { paid, pending, overdue }

class RentalPayment {
  const RentalPayment({required this.id, required this.tenant, required this.property, required this.month, required this.dueDate, required this.amountArs, required this.status, required this.paidDate});
  final String id;
  final String tenant;
  final String property;
  final String month;
  final DateTime dueDate;
  final double amountArs;
  final PaymentStatus status;
  final DateTime? paidDate;
}
