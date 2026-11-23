import 'dart:math';

import 'package:flutter/foundation.dart';

import 'db_service.dart';
import 'models.dart';

enum UserRole { customer, admin }

/// Pusat data dan logika bisnis, DIPAKAI BERSAMA oleh sisi admin dan customer:
/// order yang dibuat customer langsung terlihat admin, dan status yang diubah
/// admin langsung terlihat customer.
///
/// Cara kerja penyimpanan:
/// 1. Saat aplikasi dibuka, [init] memuat semua data dari database MySQL
///    ke dalam daftar di memori (cache). Database yang dipakai: MySQL (XAMPP).
/// 2. Halaman membaca dari daftar di memori, jadi tampilan cepat.
/// 3. Setiap perubahan (tambah, ubah, hapus) langsung memperbarui daftar
///    di memori DAN ditulis ke database lewat [DbService] (antrean `_enqueue`).
class AppState extends ChangeNotifier {
  final DbService _dbs = DbService.instance;

  /// true jika database MySQL berhasil dibuka.
  bool usingDatabase = false;

  /// Keterangan koneksi database (alamat MySQL), untuk ditampilkan.
  String dbPath = '';

  /// Pesan error jika database gagal dibuka (ditampilkan di halaman login).
  String dbError = '';

  // ---------------- Penyimpanan ----------------

  Future<void> _writes = Future<void>.value();

  /// Menjalankan penulisan database satu per satu sesuai urutan.
  void _enqueue(Future<void> Function() job) {
    if (!usingDatabase) return;
    _writes = _writes.then((_) => job()).catchError((Object e, StackTrace s) {
      debugPrint('Database error: $e');
    });
  }

  /// Dipanggil sekali di `main()` sebelum aplikasi tampil.
  Future<void> init() async {
    try {
      final created = await _dbs.open();
      dbPath = _dbs.path;
      usingDatabase = true;
      if (created) {
        _seed();
        await _writes;
      } else {
        await _load();
        if (_admins.isEmpty && customers.isEmpty && services.isEmpty) {
          _seed();
          await _writes;
        }
      }
    } catch (e) {
      debugPrint('Database tidak bisa dibuka, memakai data sementara: $e');
      dbError = e.toString();
      usingDatabase = false;
      _resetCache();
      _seed();
    }
  }

  void _resetCache() {
    _admins.clear();
    customers.clear();
    services.clear();
    orders.clear();
    _customerCounter = 0;
    _serviceCounter = 0;
    _orderCounter = 0;
    currentAdmin = null;
    currentUser = null;
  }

  Future<void> _load() async {
    _admins
      ..clear()
      ..addAll(await _dbs.loadAdmins());
    customers
      ..clear()
      ..addAll(await _dbs.loadCustomers());
    services
      ..clear()
      ..addAll(await _dbs.loadServices());
    orders
      ..clear()
      ..addAll(await _dbs.loadOrders());

    _customerCounter = max(
      _maxSuffix(customers.map((c) => c.id)),
      _maxSuffix(orders.map((o) => o.customerId)),
    );
    _serviceCounter = _maxSuffix(services.map((s) => s.id));
    _orderCounter = _maxSuffix(orders.map((o) => o.id));
  }

  /// Angka terbesar di belakang tanda "-" pada daftar id (USR-003 menjadi 3).
  int _maxSuffix(Iterable<String> ids) {
    var best = 0;
    for (final id in ids) {
      final n = int.tryParse(id.substring(id.lastIndexOf('-') + 1)) ?? 0;
      if (n > best) best = n;
    }
    return best;
  }

  // ---------------- Login / sesi ----------------
  final List<AdminAccount> _admins = [];

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
    _enqueue(() => _dbs.insertAdmin(account));
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
    final oldUsername = me.username;
    me.username = username;
    me.name = name;
    me.address = address;
    me.phone = phone;
    me.password = password;
    _enqueue(() => _dbs.updateAdmin(oldUsername, me));
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
    final customer = Customer(
      id: 'USR-${_customerCounter.toString().padLeft(3, '0')}',
      username: username,
      name: name,
      address: address,
      dob: dob,
      phone: phone,
      password: password,
    );
    customers.add(customer);
    _enqueue(() => _dbs.insertCustomer(customer));
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
    _enqueue(() => _dbs.updateCustomer(c));
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
    _enqueue(() => _dbs.updateCustomer(me));
    notifyListeners();
    return null;
  }

  void deleteCustomer(Customer c) {
    customers.remove(c);
    _enqueue(() => _dbs.deleteCustomer(c.id));
    notifyListeners();
  }

  // ---------------- Services ----------------
  // Dikelola admin (Service List + Add Now), hanya dilihat oleh customer.
  final List<LaundryService> services = [];
  int _serviceCounter = 0;

  void addService({required String name, required int pricePerKg, required int days}) {
    _serviceCounter++;
    final service = LaundryService(
      id: 'SRV-${_serviceCounter.toString().padLeft(3, '0')}',
      name: name,
      pricePerKg: pricePerKg,
      days: days,
    );
    services.add(service);
    _enqueue(() => _dbs.insertService(service));
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
    _enqueue(() => _dbs.insertOrder(order));
    notifyListeners();
    return order;
  }

  /// Admin: ubah status order (Received / On Progress / Completed).
  void updateOrderStatus(LaundryOrder order, OrderStatus status) {
    order.status = status;
    _enqueue(() => _dbs.saveOrder(order));
    notifyListeners();
  }

  /// Customer: batalkan order yang belum dibayar.
  void cancelOrder(LaundryOrder order) {
    orders.remove(order);
    _enqueue(() => _dbs.deleteOrder(order.id));
    notifyListeners();
  }

  /// Customer: bayar order lewat halaman Check Out.
  void payOrder(LaundryOrder order, PaymentMethod method) {
    order.paymentMethod = method;
    order.paid = true;
    _enqueue(() => _dbs.saveOrder(order));
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
    _enqueue(() => _dbs.saveOrder(order));
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

  // ---------------- Laporan (reporting dashboard admin) ----------------

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  /// Data untuk grafik di dashboard admin, sesuai pilihan [filter]:
  /// periode (FILTER) dan pengelompokan tren per hari/minggu/bulan (GROUPING).
  /// Jika database aktif, data diambil dengan query SQL (JOIN, WHERE, GROUP BY di
  /// `db_service.dart`). Jika tidak, dihitung dari data yang ada di memori.
  Future<ReportData> loadReport({ReportFilter filter = const ReportFilter()}) async {
    final daysBack = filter.days - 1; // hari ini + (days - 1) hari sebelumnya
    if (usingDatabase) {
      try {
        await _writes; // pastikan semua perubahan sudah tertulis ke database
        final revenue = await _dbs.queryRevenueByService(daysBack);
        final buckets = await _dbs.queryTrend(filter.unit, daysBack);
        final status = await _dbs.queryOrdersByStatus(daysBack);
        return _buildReport(filter, revenue, buckets, status);
      } catch (e) {
        debugPrint('Query laporan gagal, memakai data di memori: $e');
      }
    }
    return _reportFromMemory(filter);
  }

  DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  /// Nomor kelompok sebuah tanggal: 0 = hari/minggu/bulan ini, 1 = sebelumnya, dst.
  /// (sama dengan perhitungan bucket pada query SQL).
  int _bucketOf(DateTime d, TrendUnit unit, DateTime today) {
    final daysAgo = today.difference(DateTime(d.year, d.month, d.day)).inDays;
    switch (unit) {
      case TrendUnit.day:
        return daysAgo;
      case TrendUnit.week:
        return daysAgo ~/ 7;
      case TrendUnit.month:
        return (today.year * 12 + today.month) - (d.year * 12 + d.month);
    }
  }

  /// Cadangan jika database tidak aktif: hitung dari daftar order di memori.
  ReportData _reportFromMemory(ReportFilter filter) {
    final today = _today();
    final start = today.subtract(Duration(days: filter.days - 1));
    final inPeriod = orders.where((o) => !o.date.isBefore(start)).toList();

    final revenue = <ReportPoint>[];
    for (final s in services) {
      var sum = 0;
      for (final o in inPeriod) {
        for (final i in o.items) {
          if (i.serviceId == s.id) sum += i.subtotal;
        }
      }
      revenue.add(ReportPoint(s.name, sum.toDouble()));
    }

    final buckets = <int, int>{};
    for (final o in inPeriod) {
      final bucket = _bucketOf(o.date, filter.unit, today);
      buckets[bucket] = (buckets[bucket] ?? 0) + 1;
    }

    final status = <OrderStatus, int>{
      for (final st in OrderStatus.values) st: 0,
    };
    for (final o in inPeriod) {
      status[o.status] = (status[o.status] ?? 0) + 1;
    }
    return _buildReport(filter, revenue, buckets, status);
  }

  String _bucketLabel(TrendUnit unit, int bucket, DateTime today) {
    switch (unit) {
      case TrendUnit.day:
        {
          final date = today.subtract(Duration(days: bucket));
          return '${date.day}/${date.month}';
        }
      case TrendUnit.week:
        {
          // Tanggal awal rentang 7 hari tersebut.
          final date = today.subtract(Duration(days: bucket * 7 + 6));
          return '${date.day}/${date.month}';
        }
      case TrendUnit.month:
        {
          final index = today.year * 12 + (today.month - 1) - bucket;
          return '${_monthNames[index % 12]} ${(index ~/ 12) % 100}';
        }
    }
  }

  ReportData _buildReport(
    ReportFilter filter,
    List<ReportPoint> revenue,
    Map<int, int> buckets,
    Map<OrderStatus, int> status,
  ) {
    final today = _today();
    final start = today.subtract(Duration(days: filter.days - 1));
    final count = switch (filter.unit) {
      TrendUnit.day => filter.days,
      TrendUnit.week => (filter.days / 7).ceil(),
      TrendUnit.month => (today.year * 12 + today.month) - (start.year * 12 + start.month) + 1,
    };

    // Dari kelompok terlama (kiri) sampai terbaru (kanan); yang kosong bernilai 0.
    final trend = <ReportPoint>[];
    for (var i = 0; i < count; i++) {
      final bucket = count - 1 - i;
      trend.add(ReportPoint(
        _bucketLabel(filter.unit, bucket, today),
        (buckets[bucket] ?? 0).toDouble(),
      ));
    }

    return ReportData(
      revenueByService: revenue,
      trend: trend,
      ordersByStatus: [
        for (final st in OrderStatus.values)
          ReportPoint(st.label, (status[st] ?? 0).toDouble()),
      ],
    );
  }

  // ---------------- Data awal (contoh) ----------------
  // Hanya dijalankan saat database baru dibuat (atau database tidak aktif).
  void _seed() {
    registerAdmin(AdminAccount(
      username: 'admin',
      name: 'Administrator',
      address: 'Jl. Contoh No. 1',
      dob: '01-01-2000',
      phone: '081234567890',
      password: 'admin12345',
    ));

    addService(name: 'Laundry 2 Hari', pricePerKg: 8000, days: 2);
    addService(name: 'Laundry 1 Hari', pricePerKg: 9500, days: 1);

    addCustomer(username: 'budi01', name: 'Budi Santoso', address: 'Jl. Mawar No. 12', dob: '12-03-1999', phone: '081311112222', password: 'rahasia12345');
    addCustomer(username: 'siti_a', name: 'Siti Aminah', address: 'Jl. Melati No. 5', dob: '25-07-2001', phone: '082133334444', password: 'rahasia12345');
    addCustomer(username: 'andi22', name: 'Andi Pratama', address: 'Jl. Kenanga No. 8', dob: '02-11-1998', phone: '085755556666', password: 'rahasia12345');

    // Data contoh tersebar 6 minggu terakhir supaya grafik laporan terisi.
    // Urutan dari yang terlama, supaya order terbaru berada paling atas.
    const samples = <_Sample>[
      _Sample(40, 0, 0, 3.0, OrderStatus.completed, PaymentMethod.cash, '5 kaos, 2 celana'),
      _Sample(38, 1, 1, 2.0, OrderStatus.completed, PaymentMethod.eWallet, 'Seprai'),
      _Sample(33, 2, 0, 4.0, OrderStatus.completed, PaymentMethod.cash, 'Pakaian harian'),
      _Sample(31, 0, 1, 1.5, OrderStatus.completed, PaymentMethod.bankTransfer, 'Kemeja'),
      _Sample(27, 1, 0, 5.0, OrderStatus.completed, PaymentMethod.cash, 'Pakaian harian'),
      _Sample(24, 2, 1, 2.5, OrderStatus.completed, PaymentMethod.eWallet, 'Jaket'),
      _Sample(20, 0, 0, 3.5, OrderStatus.completed, PaymentMethod.creditCard, 'Pakaian harian'),
      _Sample(18, 1, 1, 3.0, OrderStatus.completed, PaymentMethod.cash, 'Selimut'),
      _Sample(14, 2, 0, 2.0, OrderStatus.completed, PaymentMethod.eWallet, 'Handuk'),
      _Sample(12, 0, 1, 4.0, OrderStatus.completed, PaymentMethod.bankTransfer, 'Jaket dan selimut'),
      _Sample(9, 1, 0, 3.0, OrderStatus.completed, PaymentMethod.cash, 'Pakaian harian'),
      _Sample(8, 2, 1, 1.0, OrderStatus.completed, PaymentMethod.eWallet, 'Kemeja'),
      _Sample(5, 0, 0, 2.5, OrderStatus.onProgress, PaymentMethod.cash, 'Pakaian harian'),
      _Sample(4, 1, 1, 3.5, OrderStatus.onProgress, PaymentMethod.eWallet, 'Jaket'),
      _Sample(3, 2, 0, 6.0, OrderStatus.onProgress, PaymentMethod.bankTransfer, 'Seprai dan handuk'),
      _Sample(2, 0, 1, 2.0, OrderStatus.received, PaymentMethod.cash, 'Kemeja'),
      _Sample(1, 1, 0, 2.0, OrderStatus.received, null, 'Pakaian harian'),
      // Masih Received dan belum dibayar: bisa dicoba Edit Order dan Pay Now.
      _Sample(0, 0, 0, 4.0, OrderStatus.received, null, '8 kemeja'),
    ];
    for (final sample in samples) {
      final svc = services[sample.service];
      final order = createOrder(
        customer: customers[sample.customer],
        items: [
          OrderItem(
            serviceId: svc.id,
            serviceName: svc.name,
            pricePerKg: svc.pricePerKg,
            qty: sample.kg,
            detail: sample.detail,
          ),
        ],
        date: DateTime.now().subtract(Duration(days: sample.daysAgo)),
      );
      if (sample.status != OrderStatus.received) {
        updateOrderStatus(order, sample.status);
      }
      if (sample.method != null) payOrder(order, sample.method!);
    }
  }
}

/// Satu instance global supaya mudah dipakai di semua halaman.
final AppState appState = AppState();

/// Satu baris data contoh untuk membuat order awal (lihat `_seed`).
class _Sample {
  const _Sample(
    this.daysAgo,
    this.customer,
    this.service,
    this.kg,
    this.status,
    this.method,
    this.detail,
  );

  final int daysAgo;
  final int customer;
  final int service;
  final double kg;
  final OrderStatus status;
  final PaymentMethod? method;
  final String detail;
}
