import 'package:mysql_client/mysql_client.dart';

import 'models.dart';

/// Pengaturan koneksi MySQL. Nilai di bawah adalah bawaan XAMPP.
/// Ubah di sini jika MySQL-mu memakai port atau password yang berbeda.
class DbConfig {
  static const String host = '127.0.0.1';
  static const int port = 3307; // port MySQL di XAMPP (bawaan XAMPP: 3306)
  static const String user = 'root';
  static const String password = '1234'; // ISI dengan password MySQL XAMPP-mu jika ada
  static const String database = 'silaundry_app';
}

// ---------------------------------------------------------------------------
// Skema tabel. Dibuat otomatis (CREATE TABLE IF NOT EXISTS) saat aplikasi
// pertama kali tersambung ke MySQL.
//
// Relasi antar tabel:
//   customers 1 --- N orders        (orders.customer_id -> customers.id)
//   orders    1 --- N order_items   (order_items.order_id -> orders.id)
//   services  1 --- N order_items   (order_items.service_id -> services.id)
// ---------------------------------------------------------------------------
const List<String> _schema = [
  '''
  CREATE TABLE IF NOT EXISTS admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(200) NOT NULL,
    dob DATE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    password VARCHAR(255) NOT NULL
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  ''',
  '''
  CREATE TABLE IF NOT EXISTS customers (
    id VARCHAR(10) PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(200) NOT NULL,
    dob DATE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    password VARCHAR(255) NOT NULL
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  ''',
  '''
  CREATE TABLE IF NOT EXISTS services (
    id VARCHAR(10) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price_per_kg INT NOT NULL,
    days INT NOT NULL
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  ''',
  '''
  CREATE TABLE IF NOT EXISTS orders (
    id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10) NULL,
    customer_name VARCHAR(100) NOT NULL,
    customer_address VARCHAR(200) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    order_date DATETIME NOT NULL,
    note TEXT NOT NULL,
    status ENUM('received','onProgress','completed') NOT NULL DEFAULT 'received',
    payment_method ENUM('cash','eWallet','bankTransfer','creditCard') NULL,
    paid TINYINT(1) NOT NULL DEFAULT 0,
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
      REFERENCES customers (id) ON DELETE SET NULL
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  ''',
  '''
  CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(10) NOT NULL,
    service_id VARCHAR(10) NOT NULL,
    service_name VARCHAR(100) NOT NULL,
    price_per_kg INT NOT NULL,
    qty DECIMAL(8,2) NOT NULL,
    detail TEXT NOT NULL,
    CONSTRAINT fk_items_order FOREIGN KEY (order_id)
      REFERENCES orders (id) ON DELETE CASCADE,
    CONSTRAINT fk_items_service FOREIGN KEY (service_id)
      REFERENCES services (id)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  ''',
];

// ---------------------------------------------------------------------------
// Semua perintah SQL aplikasi. Tanda :nama adalah parameter yang diisi dari
// kode Dart (bukan disambung sebagai teks, sehingga aman dari SQL injection).
// ---------------------------------------------------------------------------

const _sqlCountRows = '''
SELECT (SELECT COUNT(*) FROM admins)
     + (SELECT COUNT(*) FROM customers)
     + (SELECT COUNT(*) FROM services) AS total
''';

const _sqlSelectAdmins = 'SELECT * FROM admins ORDER BY id';
const _sqlInsertAdmin = '''
INSERT INTO admins (username, name, address, dob, phone, password)
VALUES (:username, :name, :address, :dob, :phone, :password)
''';
const _sqlUpdateAdmin = '''
UPDATE admins
SET username = :username, name = :name, address = :address,
    dob = :dob, phone = :phone, password = :password
WHERE username = :old_username
''';

const _sqlSelectCustomers = 'SELECT * FROM customers ORDER BY id';
const _sqlInsertCustomer = '''
INSERT INTO customers (id, username, name, address, dob, phone, password)
VALUES (:id, :username, :name, :address, :dob, :phone, :password)
''';
const _sqlUpdateCustomer = '''
UPDATE customers
SET username = :username, name = :name, address = :address,
    dob = :dob, phone = :phone, password = :password
WHERE id = :id
''';
const _sqlDeleteCustomer = 'DELETE FROM customers WHERE id = :id';

const _sqlSelectServices = 'SELECT * FROM services ORDER BY id';
const _sqlInsertService = '''
INSERT INTO services (id, name, price_per_kg, days)
VALUES (:id, :name, :price_per_kg, :days)
''';

const _sqlSelectOrders = 'SELECT * FROM orders ORDER BY order_date DESC, id DESC';
const _sqlSelectItems = 'SELECT * FROM order_items WHERE order_id = :order_id ORDER BY id';
const _sqlInsertOrder = '''
INSERT INTO orders (id, customer_id, customer_name, customer_address,
                    customer_phone, order_date, note, status, payment_method, paid)
VALUES (:id, NULLIF(:customer_id, ''), :customer_name, :customer_address,
        :customer_phone, :order_date, :note, :status, NULLIF(:payment_method, ''), :paid)
''';
const _sqlUpdateOrder = '''
UPDATE orders
SET note = :note, status = :status, payment_method = NULLIF(:payment_method, ''), paid = :paid
WHERE id = :id
''';
const _sqlInsertItem = '''
INSERT INTO order_items (order_id, service_id, service_name, price_per_kg, qty, detail)
VALUES (:order_id, :service_id, :service_name, :price_per_kg, :qty, :detail)
''';
const _sqlDeleteItems = 'DELETE FROM order_items WHERE order_id = :order_id';
const _sqlDeleteOrder = 'DELETE FROM orders WHERE id = :id';


// ---------------------------------------------------------------------------
// Query LAPORAN (reporting dashboard): gabungan beberapa tabel dengan JOIN
// dan pengelompokan GROUP BY. Hasilnya menjadi bar, line, dan pie chart.
// ---------------------------------------------------------------------------

// Perbandingan layanan: total nilai order tiap layanan (services JOIN order_items).
// LEFT JOIN supaya layanan yang belum pernah dipesan tetap tampil dengan nilai 0.
const _sqlReportRevenueByService = '''
SELECT s.name AS nama, COALESCE(SUM(i.qty * i.price_per_kg), 0) AS total
FROM services s
LEFT JOIN order_items i ON i.service_id = s.id
GROUP BY s.id, s.name
ORDER BY s.id
''';

// Jumlah order per minggu. bucket 0 = 7 hari terakhir, 1 = minggu sebelumnya, dst.
const _sqlReportOrdersPerWeek = '''
SELECT FLOOR(DATEDIFF(CURDATE(), DATE(order_date)) / 7) AS bucket, COUNT(*) AS jumlah
FROM orders
GROUP BY bucket
''';

// Jumlah order tiap status.
const _sqlReportOrdersByStatus = '''
SELECT status, COUNT(*) AS jumlah
FROM orders
GROUP BY status
''';

// ---------------------------------------------------------------------------

String _two(int n) => n.toString().padLeft(2, '0');

/// DateTime -> teks DATETIME MySQL ("2026-11-16 10:30:00").
String _dateTime(DateTime d) =>
    '${d.year}-${_two(d.month)}-${_two(d.day)} ${_two(d.hour)}:${_two(d.minute)}:${_two(d.second)}';

/// "12-03-1999" (format aplikasi) -> "1999-03-12" (format DATE MySQL).
String _toSqlDate(String ddMMyyyy) {
  final p = ddMMyyyy.split('-');
  if (p.length == 3 && p[2].length == 4) return '${p[2]}-${p[1]}-${p[0]}';
  return ddMMyyyy;
}

/// "1999-03-12" (DATE MySQL) -> "12-03-1999" (format aplikasi).
String _fromSqlDate(String sql) {
  final p = sql.split('-');
  if (p.length == 3 && p[0].length == 4) return '${p[2]}-${p[1]}-${p[0]}';
  return sql;
}

/// Satu-satunya tempat yang berbicara langsung dengan MySQL.
/// Semua perintah SQL ada di file ini dan hanya dipanggil dari `AppState`.
/// Halaman tidak mengakses database.
class DbService {
  DbService._();

  static final DbService instance = DbService._();

  MySQLConnection? _conn;

  /// Keterangan koneksi (untuk ditampilkan).
  String path = '';

  MySQLConnection get _c => _conn!;

  /// Tersambung ke MySQL, membuat database dan tabel jika belum ada.
  /// Mengembalikan true jika database masih kosong (belum ada data sama sekali).
  Future<bool> open() async {
    final conn = await MySQLConnection.createConnection(
      host: DbConfig.host,
      port: DbConfig.port,
      userName: DbConfig.user,
      password: DbConfig.password,
      secure: false,
    );
    await conn.connect(timeoutMs: 5000);
    await conn.execute(
      'CREATE DATABASE IF NOT EXISTS ${DbConfig.database} '
      'CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci',
    );
    await conn.execute('USE ${DbConfig.database}');
    for (final sql in _schema) {
      await conn.execute(sql);
    }
    _conn = conn;
    path = 'mysql://${DbConfig.user}@${DbConfig.host}:${DbConfig.port}/${DbConfig.database}';

    final r = await conn.execute(_sqlCountRows);
    final total = int.parse(r.rows.first.assoc()['total']!);
    return total == 0;
  }

  /// TRANSAKSI: semua perintah di dalam [body] berhasil bersama (COMMIT),
  /// atau jika ada satu yang gagal, semuanya dibatalkan (ROLLBACK).
  Future<void> _transaction(Future<void> Function() body) async {
    await _c.execute('START TRANSACTION');
    try {
      await body();
      await _c.execute('COMMIT');
    } catch (e) {
      await _c.execute('ROLLBACK');
      rethrow;
    }
  }

  // ---------------- Admin ----------------

  Map<String, dynamic> _adminParams(AdminAccount a) => {
        'username': a.username,
        'name': a.name,
        'address': a.address,
        'dob': _toSqlDate(a.dob),
        'phone': a.phone,
        'password': a.password,
      };

  Future<List<AdminAccount>> loadAdmins() async {
    final res = await _c.execute(_sqlSelectAdmins);
    final result = <AdminAccount>[];
    for (final row in res.rows) {
      final m = row.assoc();
      result.add(AdminAccount(
        username: m['username']!,
        name: m['name']!,
        address: m['address']!,
        dob: _fromSqlDate(m['dob']!),
        phone: m['phone']!,
        password: m['password']!,
      ));
    }
    return result;
  }

  Future<void> insertAdmin(AdminAccount a) async {
    await _c.execute(_sqlInsertAdmin, _adminParams(a));
  }

  /// [oldUsername] adalah username sebelum diubah, dipakai untuk mencari baris.
  Future<void> updateAdmin(String oldUsername, AdminAccount a) async {
    await _c.execute(_sqlUpdateAdmin, {..._adminParams(a), 'old_username': oldUsername});
  }

  // ---------------- Customers ----------------

  Map<String, dynamic> _customerParams(Customer c) => {
        'id': c.id,
        'username': c.username,
        'name': c.name,
        'address': c.address,
        'dob': _toSqlDate(c.dob),
        'phone': c.phone,
        'password': c.password,
      };

  Future<List<Customer>> loadCustomers() async {
    final res = await _c.execute(_sqlSelectCustomers);
    final result = <Customer>[];
    for (final row in res.rows) {
      final m = row.assoc();
      result.add(Customer(
        id: m['id']!,
        username: m['username']!,
        name: m['name']!,
        address: m['address']!,
        dob: _fromSqlDate(m['dob']!),
        phone: m['phone']!,
        password: m['password']!,
      ));
    }
    return result;
  }

  Future<void> insertCustomer(Customer c) async {
    await _c.execute(_sqlInsertCustomer, _customerParams(c));
  }

  Future<void> updateCustomer(Customer c) async {
    await _c.execute(_sqlUpdateCustomer, _customerParams(c));
  }

  Future<void> deleteCustomer(String id) async {
    await _c.execute(_sqlDeleteCustomer, {'id': id});
  }

  // ---------------- Services ----------------

  Future<List<LaundryService>> loadServices() async {
    final res = await _c.execute(_sqlSelectServices);
    final result = <LaundryService>[];
    for (final row in res.rows) {
      final m = row.assoc();
      result.add(LaundryService(
        id: m['id']!,
        name: m['name']!,
        pricePerKg: int.parse(m['price_per_kg']!),
        days: int.parse(m['days']!),
      ));
    }
    return result;
  }

  Future<void> insertService(LaundryService s) async {
    await _c.execute(_sqlInsertService, {
      'id': s.id,
      'name': s.name,
      'price_per_kg': s.pricePerKg,
      'days': s.days,
    });
  }

  // ---------------- Orders ----------------

  Map<String, dynamic> _orderParams(LaundryOrder o) => {
        'id': o.id,
        'customer_id': o.customerId, // '' disimpan sebagai NULL (lihat NULLIF di SQL)
        'customer_name': o.customerName,
        'customer_address': o.customerAddress,
        'customer_phone': o.customerPhone,
        'order_date': _dateTime(o.date),
        'note': o.note,
        'status': o.status.name,
        'payment_method': o.paymentMethod?.name ?? '',
        'paid': o.paid ? 1 : 0,
      };

  Map<String, dynamic> _itemParams(String orderId, OrderItem i) => {
        'order_id': orderId,
        'service_id': i.serviceId,
        'service_name': i.serviceName,
        'price_per_kg': i.pricePerKg,
        'qty': i.qty,
        'detail': i.detail,
      };

  Future<List<LaundryOrder>> loadOrders() async {
    final res = await _c.execute(_sqlSelectOrders);
    final headers = [for (final row in res.rows) row.assoc()];

    final result = <LaundryOrder>[];
    for (final m in headers) {
      final id = m['id']!;
      final itemRes = await _c.execute(_sqlSelectItems, {'order_id': id});
      final items = <OrderItem>[];
      for (final row in itemRes.rows) {
        final i = row.assoc();
        items.add(OrderItem(
          serviceId: i['service_id']!,
          serviceName: i['service_name']!,
          pricePerKg: int.parse(i['price_per_kg']!),
          qty: double.parse(i['qty']!),
          detail: i['detail']!,
        ));
      }
      final method = m['payment_method'];
      result.add(LaundryOrder(
        id: id,
        customerId: m['customer_id'] ?? '',
        customerName: m['customer_name']!,
        customerAddress: m['customer_address']!,
        customerPhone: m['customer_phone']!,
        date: DateTime.parse(m['order_date']!),
        items: items,
        note: m['note']!,
        status: OrderStatus.values.byName(m['status']!),
        paymentMethod: method == null ? null : PaymentMethod.values.byName(method),
        paid: m['paid'] == '1',
      ));
    }
    return result;
  }

  /// FITUR TRANSAKSIONAL: membuat order.
  /// Menulis ke 2 tabel sekaligus dalam satu transaksi:
  ///   1. orders       : satu baris header order (pemilik = customers.id)
  ///   2. order_items  : satu baris per layanan (merujuk ke services.id)
  /// Jika salah satu gagal (misal layanan tidak ada), semuanya di-ROLLBACK
  /// sehingga tidak pernah ada order tanpa item.
  Future<void> insertOrder(LaundryOrder o) async {
    await _transaction(() async {
      await _c.execute(_sqlInsertOrder, _orderParams(o));
      for (final i in o.items) {
        await _c.execute(_sqlInsertItem, _itemParams(o.id, i));
      }
    });
  }

  /// Menyimpan perubahan order (status, pembayaran, catatan, jumlah kg).
  /// Juga transaksi: tabel orders diperbarui dan order_items ditulis ulang.
  Future<void> saveOrder(LaundryOrder o) async {
    await _transaction(() async {
      await _c.execute(_sqlUpdateOrder, _orderParams(o));
      await _c.execute(_sqlDeleteItems, {'order_id': o.id});
      for (final i in o.items) {
        await _c.execute(_sqlInsertItem, _itemParams(o.id, i));
      }
    });
  }

  Future<void> deleteOrder(String id) async {
    await _transaction(() async {
      await _c.execute(_sqlDeleteItems, {'order_id': id});
      await _c.execute(_sqlDeleteOrder, {'id': id});
    });
  }

  // ---------------- Laporan ----------------

  /// Bar chart: total nilai order tiap layanan.
  Future<List<ReportPoint>> queryRevenueByService() async {
    final res = await _c.execute(_sqlReportRevenueByService);
    final result = <ReportPoint>[];
    for (final row in res.rows) {
      final m = row.assoc();
      result.add(ReportPoint(m['nama']!, double.parse(m['total']!)));
    }
    return result;
  }

  /// Line chart: jumlah order per minggu (kunci = nomor minggu ke belakang).
  Future<Map<int, int>> queryOrdersPerWeek() async {
    final res = await _c.execute(_sqlReportOrdersPerWeek);
    final result = <int, int>{};
    for (final row in res.rows) {
      final m = row.assoc();
      result[double.parse(m['bucket']!).floor()] = int.parse(m['jumlah']!);
    }
    return result;
  }

  /// Pie chart: jumlah order tiap status.
  Future<Map<OrderStatus, int>> queryOrdersByStatus() async {
    final res = await _c.execute(_sqlReportOrdersByStatus);
    final result = <OrderStatus, int>{
      for (final st in OrderStatus.values) st: 0,
    };
    for (final row in res.rows) {
      final m = row.assoc();
      result[OrderStatus.values.byName(m['status']!)] = int.parse(m['jumlah']!);
    }
    return result;
  }
}
