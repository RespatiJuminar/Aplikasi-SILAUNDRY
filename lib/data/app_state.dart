import 'package:flutter/foundation.dart';
import 'models.dart';

/// Penyimpanan data sementara (in-memory) untuk prototype.
/// Nanti bagian ini bisa diganti dengan koneksi database (MySQL/SQLite/API).
class AppState extends ChangeNotifier {
  AppState() {
    _seed();
  }

  // ---------------- Akun admin ----------------
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

  bool login(String username, String password) {
    for (final a in _admins) {
      if (a.username == username && a.password == password) {
        currentAdmin = a;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  String? registerAdmin(AdminAccount account) {
    final exists = _admins.any(
      (a) => a.username.toLowerCase() == account.username.toLowerCase(),
    );
    if (exists) return 'Username is already used';
    _admins.add(account);
    return null;
  }

  void logout() {
    currentAdmin = null;
    notifyListeners();
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

  void deleteCustomer(Customer c) {
    customers.remove(c);
    notifyListeners();
  }

  // ---------------- Services ----------------
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

  LaundryOrder createOrder({
    required Customer customer,
    required List<OrderItem> items,
    DateTime? date,
  }) {
    _orderCounter++;
    final details = items
        .where((i) => i.detail.isNotEmpty)
        .map((i) => '${i.serviceName}: ${i.detail}')
        .join('\n');
    final order = LaundryOrder(
      id: 'ORD-${_orderCounter.toString().padLeft(3, '0')}',
      customerId: customer.id,
      customerName: customer.name,
      customerAddress: customer.address,
      customerPhone: customer.phone,
      date: date ?? DateTime.now(),
      items: List.of(items),
      note: details,
    );
    orders.insert(0, order);
    notifyListeners();
    return order;
  }

  void updateOrderStatus(LaundryOrder order, OrderStatus status) {
    order.status = status;
    notifyListeners();
  }

  // ---------------- Statistik dashboard ----------------
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

    addCustomer(username: 'budi01', name: 'Budi Santoso', address: 'Jl. Mawar No. 12', dob: '12-03-1999', phone: '081311112222', password: 'rahasia123');
    addCustomer(username: 'siti_a', name: 'Siti Aminah', address: 'Jl. Melati No. 5', dob: '25-07-2001', phone: '082133334444', password: 'rahasia123');
    addCustomer(username: 'andi22', name: 'Andi Pratama', address: 'Jl. Kenanga No. 8', dob: '02-11-1998', phone: '085755556666', password: 'rahasia123');

    final s1 = services[0];
    final s2 = services[1];
    createOrder(
      customer: customers[0],
      items: [OrderItem(serviceId: s1.id, serviceName: s1.name, pricePerKg: s1.pricePerKg, qty: 3, detail: '5 kaos, 2 celana')],
      date: DateTime.now().subtract(const Duration(days: 2)),
    ).status = OrderStatus.completed;
    createOrder(
      customer: customers[1],
      items: [OrderItem(serviceId: s2.id, serviceName: s2.name, pricePerKg: s2.pricePerKg, qty: 2.5, detail: 'Jaket dan selimut')],
      date: DateTime.now().subtract(const Duration(days: 1)),
    ).status = OrderStatus.onProgress;
    createOrder(
      customer: customers[2],
      items: [OrderItem(serviceId: s1.id, serviceName: s1.name, pricePerKg: s1.pricePerKg, qty: 4)],
    );
  }
}

/// Satu instance global supaya mudah dipakai di semua halaman.
final AppState appState = AppState();
