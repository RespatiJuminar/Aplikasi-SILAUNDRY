import 'package:flutter/foundation.dart';
import 'models.dart';

enum UserRole { customer, admin }

/// Penyimpanan data sementara (in-memory) untuk prototype, DIPAKAI BERSAMA
/// oleh sisi admin dan sisi customer: order yang dibuat customer langsung
/// terlihat admin, dan status yang diubah admin langsung terlihat customer.
/// Nanti bagian ini bisa diganti dengan koneksi database (MySQL/SQLite/API).
class AppState extends ChangeNotifier {
  AppState() {
    _seed();
  }

  // ---------------- Login / sesi ----------------
  final List<AdminAccount> _admins = [
    AdminAccount(
      username: 'admin',
      name: 'Administrator',
      address: 'Jl. Contoh No. 1',
      dob: '01-01-2000',
      phone: '081234567890',
      password: 'admin12345',
    ),
  ];

  AdminAccount? currentAdmin;
  Customer? currentUser;

  bool login(String username, String password, UserRole role) {
    if (role == UserRole.admin) {
      for (final a in _admins) {
        if (a.username == username && a.password == password) {
          currentAdmin = a;
          currentUser = null;
          notifyListeners();
          return true;
        }
      }
    } else {
      for (final c in customers) {
        if (c.username == username && c.password == password) {
          currentUser = c;
          currentAdmin = null;
          notifyListeners();
          return true;
        }
      }
    }
    return false;
  }

  void logout() {
    currentAdmin = null;
    currentUser = null;
    notifyListeners();
  }

  // ---------------- Akun admin ----------------
  String? registerAdmin(AdminAccount account) {
    final exists = _admins.any(
      (a) => a.username.toLowerCase() == account.username.toLowerCase(),
    );
    if (exists) return 'Username is already used';
    _admins.add(account);
    return null;
  }

  String? updateAdmin({
    required String username,
    required String name,
    required String address,
    required String phone,
    required String password,
  }) {
    final me = currentAdmin;
    if (me == null) return 'No active admin';
    final used = _admins.any(
      (a) => a != me && a.username.toLowerCase() == username.toLowerCase(),
    );
    if (used) return 'Username is already used';
    me.username = username;
    me.name = name;
    me.address = address;
    me.phone = phone;
    me.password = password;
    notifyListeners();
    return null;
  }

  // ---------------- Customers ----------------
  final List<Customer> customers = [];
  int _customerCounter = 0;

  /// Dipakai admin (halaman New User).
  String? addCustomer({
    required String username,
    required String name,
    required String address,
    required String dob,
    required String phone,
    required String password,
  }) {
    if (customers.any((c) => c.username.toLowerCase() == username.toLowerCase())) {
      return 'Username is already used';
    }
    _customerCounter++;
    customers.add(Customer(
      id: 'USR-${_customerCounter.toString().padLeft(3, '0')}',
      username: username,
      name: name,
      address: address,
      dob: dob,
      phone: phone,
      password: password,
    ));
    notifyListeners();
    return null;
  }

  /// Dipakai customer (halaman Register). Sama dengan addCustomer.
  String? register({
    required String username,
    required String name,
    required String address,
    required String dob,
    required String phone,
    required String password,
  }) {
    return addCustomer(
      username: username,
      name: name,
      address: address,
      dob: dob,
      phone: phone,
      password: password,
    );
  }

  /// Dipakai admin (dialog Edit User).
  String? updateCustomer(
    Customer c, {
    required String username,
    required String name,
    required String address,
    required String phone,
  }) {
    final used = customers.any(
      (x) => x != c && x.username.toLowerCase() == username.toLowerCase(),
    );
    if (used) return 'Username is already used';
    c.username = username;
    c.name = name;
    c.address = address;
    c.phone = phone;
    notifyListeners();
    return null;
  }

  /// Dipakai customer (Account Settings milik sendiri).
  String? updateUser({
    required String username,
    required String name,
    required String address,
    required String phone,
    required String password,
  }) {
    final me = currentUser;
    if (me == null) return 'No active user';
    final err = updateCustomer(
      me,
      username: username,
      name: name,
      address: address,
      phone: phone,
    );
    if (err != null) return err;
    me.password = password;
    notifyListeners();
    return null;
  }

  void deleteCustomer(Customer c) {
    customers.remove(c);
    notifyListeners();
  }

  // ---------------- Services ----------------
  // Dikelola admin (Service List + Add Now), hanya dilihat oleh customer.
  final List<LaundryService> services = [];
  int _serviceCounter = 0;

  void addService({required String name, required int pricePerKg, required int days}) {
    _serviceCounter++;
    services.add(LaundryService(
      id: 'SRV-${_serviceCounter.toString().padLeft(3, '0')}',
      name: name,
      pricePerKg: pricePerKg,
      days: days,
    ));
    notifyListeners();
  }

  // ---------------- Orders ----------------
  final List<LaundryOrder> orders = [];
  int _orderCounter = 0;

  /// Order milik customer yang sedang login, terbaru di atas.
  List<LaundryOrder> get myOrders {
    final me = currentUser;
    if (me == null) return [];
    return orders.where((o) => o.customerId == me.id).toList();
  }

  /// Admin mengisi [customer]. Customer yang sedang login tidak perlu
  /// mengisinya, otomatis memakai akunnya sendiri.
  LaundryOrder createOrder({
    Customer? customer,
    required List<OrderItem> items,
    DateTime? date,
  }) {
    final owner = customer ?? currentUser!;
    _orderCounter++;
    final details = items
        .where((i) => i.detail.isNotEmpty)
        .map((i) => '${i.serviceName}: ${i.detail}')
        .join('\n');
    final order = LaundryOrder(
      id: 'ORD-${_orderCounter.toString().padLeft(4, '0')}',
      customerId: owner.id,
      customerName: owner.name,
      customerAddress: owner.address,
      customerPhone: owner.phone,
      date: date ?? DateTime.now(),
      items: List.of(items),
      note: details,
    );
    orders.insert(0, order);
    notifyListeners();
    return order;
  }

  /// Admin: ubah status order (Received / On Progress / Completed).
  void updateOrderStatus(LaundryOrder order, OrderStatus status) {
    order.status = status;
    notifyListeners();
  }

  /// Customer: batalkan order yang belum dibayar.
  void cancelOrder(LaundryOrder order) {
    orders.remove(order);
    notifyListeners();
  }

  /// Customer: bayar order lewat halaman Check Out.
  void payOrder(LaundryOrder order, PaymentMethod method) {
    order.paymentMethod = method;
    order.paid = true;
    notifyListeners();
  }

  /// Customer: edit jumlah kg dan catatan order (hanya saat status Received).
  void updateOrder(
    LaundryOrder order, {
    required Map<OrderItem, double> qty,
    required String note,
  }) {
    qty.forEach((item, q) => item.qty = q);
    order.note = note;
    notifyListeners();
  }

  // ---------------- Statistik dashboard admin ----------------
  int countByStatus(OrderStatus s) => orders.where((o) => o.status == s).length;

  int get balance => orders
      .where((o) => o.status == OrderStatus.completed)
      .fold(0, (sum, o) => sum + o.total);

  int get ordersThisWeek {
    final limit = DateTime.now().subtract(const Duration(days: 7));
    return orders.where((o) => o.date.isAfter(limit)).length;
  }

  // ---------------- Data awal (contoh) ----------------
  void _seed() {
    addService(name: 'Laundry 2 Hari', pricePerKg: 8000, days: 2);
    addService(name: 'Laundry 1 Hari', pricePerKg: 9500, days: 1);
    final s1 = services[0];
    final s2 = services[1];

    addCustomer(username: 'budi01', name: 'Budi Santoso', address: 'Jl. Mawar No. 12', dob: '12-03-1999', phone: '081311112222', password: 'rahasia12345');
    addCustomer(username: 'siti_a', name: 'Siti Aminah', address: 'Jl. Melati No. 5', dob: '25-07-2001', phone: '082133334444', password: 'rahasia12345');
    addCustomer(username: 'andi22', name: 'Andi Pratama', address: 'Jl. Kenanga No. 8', dob: '02-11-1998', phone: '085755556666', password: 'rahasia12345');
    final budi = customers[0];
    final siti = customers[1];

    // Order lama dulu, supaya order terbaru berada paling atas.
    createOrder(
      customer: budi,
      items: [OrderItem(serviceId: s1.id, serviceName: s1.name, pricePerKg: s1.pricePerKg, qty: 3, detail: '5 kaos, 2 celana')],
      date: DateTime.now().subtract(const Duration(days: 3)),
    )
      ..status = OrderStatus.completed
      ..paymentMethod = PaymentMethod.cash
      ..paid = true;

    createOrder(
      customer: budi,
      items: [OrderItem(serviceId: s2.id, serviceName: s2.name, pricePerKg: s2.pricePerKg, qty: 2.5, detail: 'Jaket dan selimut')],
      date: DateTime.now().subtract(const Duration(days: 1)),
    )
      ..status = OrderStatus.onProgress
      ..paymentMethod = PaymentMethod.eWallet
      ..paid = true;

    createOrder(
      customer: siti,
      items: [OrderItem(serviceId: s1.id, serviceName: s1.name, pricePerKg: s1.pricePerKg, qty: 2, detail: 'Seprai')],
      date: DateTime.now().subtract(const Duration(hours: 5)),
    )
      ..status = OrderStatus.onProgress
      ..paymentMethod = PaymentMethod.bankTransfer
      ..paid = true;

    // Masih Received dan belum dibayar: bisa dicoba Edit Order dan Pay Now.
    createOrder(
      customer: budi,
      items: [OrderItem(serviceId: s1.id, serviceName: s1.name, pricePerKg: s1.pricePerKg, qty: 4, detail: '8 kemeja')],
    );
  }
}

/// Satu instance global supaya mudah dipakai di semua halaman.
final AppState appState = AppState();
