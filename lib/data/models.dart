/// Akun admin (untuk login, register, dan Account Settings admin).
class AdminAccount {
  AdminAccount({
    required this.username,
    required this.name,
    required this.address,
    required this.dob,
    required this.phone,
    required this.password,
  });

  String username;
  String name;
  String address;
  String dob;
  String phone;
  String password;
}

/// Akun customer. Dikelola admin di halaman Customers, dan dipakai
/// customer sendiri untuk login dan Account Settings.
class Customer {
  Customer({
    required this.id,
    required this.username,
    required this.name,
    required this.address,
    required this.dob,
    required this.phone,
    required this.password,
  });

  final String id;
  String username;
  String name;
  String address;
  String dob;
  String phone;
  String password;
}

/// Jenis layanan laundry, contoh: Laundry 2 Hari Rp 8.000/kg.
class LaundryService {
  LaundryService({
    required this.id,
    required this.name,
    required this.pricePerKg,
    required this.days,
  });

  final String id;
  final String name;
  final int pricePerKg;
  final int days;
}

/// Satu baris isi keranjang / order.
class OrderItem {
  OrderItem({
    required this.serviceId,
    required this.serviceName,
    required this.pricePerKg,
    required this.qty,
    this.detail = '',
  });

  final String serviceId;
  final String serviceName;
  final int pricePerKg;
  double qty;
  String detail;

  int get subtotal => (pricePerKg * qty).round();
}

enum OrderStatus { received, onProgress, completed }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.received:
        return 'Received';
      case OrderStatus.onProgress:
        return 'On Progress';
      case OrderStatus.completed:
        return 'Completed';
    }
  }
}

enum PaymentMethod { cash, eWallet, bankTransfer, creditCard }

extension PaymentMethodX on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.eWallet:
        return 'E-Wallet';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.creditCard:
        return 'Credit Card';
    }
  }
}

class LaundryOrder {
  LaundryOrder({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerAddress,
    required this.customerPhone,
    required this.date,
    required this.items,
    this.note = '',
    this.status = OrderStatus.received,
    this.paymentMethod,
    this.paid = false,
  });

  final String id;
  final String customerId;
  // Data customer disalin saat order dibuat (snapshot), supaya order lama
  // tetap terbaca walau akun customer-nya sudah diubah atau dihapus.
  final String customerName;
  final String customerAddress;
  final String customerPhone;
  final DateTime date;
  final List<OrderItem> items;
  String note;
  OrderStatus status;
  PaymentMethod? paymentMethod;
  bool paid;

  int get total => items.fold(0, (sum, i) => sum + i.subtotal);
  double get totalQty => items.fold(0.0, (sum, i) => sum + i.qty);
}
