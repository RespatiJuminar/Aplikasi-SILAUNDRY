import 'package:mysql_client/mysql_client.dart';

// Samakan dengan DbConfig di db_service.dart
const int port = 3307;
const String user = 'root';
const String password = '1234';

Future<void> coba(String nama, String host, bool secure) async {
  print('--- Percobaan $nama (host=$host, secure=$secure)');
  MySQLConnection? c;
  try {
    c = await MySQLConnection.createConnection(
      host: host,
      port: port,
      userName: user,
      password: password,
      secure: secure,
    );
    await c.connect(timeoutMs: 5000);
    print('  [OK] tersambung');
    final r = await c.execute('SELECT VERSION() AS versi, CURRENT_USER() AS akun');
    print('  [OK] ${r.rows.first.assoc()}');
  } catch (e) {
    print('  [GAGAL] ${e.runtimeType}: $e');
  } finally {
    try {
      await c?.close();
    } catch (_) {}
  }
}

Future<void> main() async {
  await coba('A', '127.0.0.1', false);
  await coba('B', '127.0.0.1', true);
  await coba('C', 'localhost', false);
}