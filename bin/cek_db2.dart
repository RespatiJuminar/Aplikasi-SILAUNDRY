import 'dart:io';

// Pilih SATU baris import sesuai zip yang kamu pakai:
// import '../lib/shared/data/db_service.dart'; // zip "rapi" (lib/shared/...)
import '../lib/data/db_service.dart';           // zip lama (lib/data/...)

Future<void> main() async {
  final db = DbService.instance;
  try {
    final kosong = await db.open();
    print('[OK] open() berhasil. Database kosong: $kosong');
    print('     ${db.path}');
    print('[OK] customers: ${(await db.loadCustomers()).length}');
    print('[OK] services : ${(await db.loadServices()).length}');
    print('[OK] orders   : ${(await db.loadOrders()).length}');
  } catch (e, s) {
    print('[GAGAL] ${e.runtimeType}: $e');
    print(s);
  }
  exit(0);
}