# SiLaundry - Prototype Desktop (Admin + Customer) - Flutter + MySQL

Satu proyek untuk dua sisi aplikasi. Di halaman login pilih **Customer** atau **Admin**.
Data disimpan di database MySQL (XAMPP) dan dipakai bersama: order yang dibuat customer
langsung terlihat admin, dan status yang diubah admin langsung terlihat customer.

## Persiapan

1. Buka **XAMPP Control Panel**, klik **Start** pada **MySQL** (dan Apache jika ingin memakai phpMyAdmin).
2. Pasang paket MySQL sekali di folder proyek:

       flutter pub add mysql_client

   (Jika sebelumnya sempat memasang paket SQLite: `flutter pub remove sqflite_common_ffi sqlite3_flutter_libs`)
3. Pengaturan koneksi ada di `lib/shared/data/db_service.dart`, kelas `DbConfig`.
   Isi bawaan di zip ini: host 127.0.0.1, **port 3307**, user root, password kosong,
   database **silaundry_app**. **Isi `password` sesuai password MySQL XAMPP-mu** dan ubah
   port jika MySQL-mu bukan di 3307 (bawaan XAMPP 3306).

## Cara menjalankan (Windows + VS Code)

1. `flutter create silaundry --platforms=windows`
2. Ganti folder `lib/` dan `assets/` proyek itu dengan folder `lib/` dan `assets/` dari zip ini.
   Folder `database/` berisi file SQL untuk dokumentasi.
3. Di `pubspec.yaml` proyek, tambahkan di bagian `flutter:`
   ```
   assets:
     - assets/images/
   ```
4. Hapus `test/widget_test.dart` (bawaan template).
5. `flutter run -d windows` (harus Windows desktop, bukan Chrome, karena koneksi MySQL memakai socket).

Database `silaundry` dan 5 tabelnya dibuat OTOMATIS saat pertama dijalankan, lalu diisi data
contoh. Buka `http://localhost/phpmyadmin` dan refresh untuk melihatnya.
Di halaman login tampil tulisan "Database MySQL aktif - data tersimpan" jika koneksi berhasil.
Jika tampil "Database tidak aktif", cek apakah MySQL di XAMPP sudah Start (aplikasi tetap
jalan dengan data sementara).

## Dashboard laporan (admin)

Di halaman Dashboard admin ada bagian **Business Report** dengan 3 grafik:

| Grafik | Isi | Query |
|---|---|---|
| Bar chart | Perbandingan layanan: total nilai order per layanan | `services` LEFT JOIN `order_items` + `GROUP BY` |
| Line chart | Tren jumlah order per minggu (6 minggu terakhir) | `orders` + `GROUP BY` minggu |
| Pie chart | Komposisi order per status | `orders` + `GROUP BY status` |

Query ada di `lib/shared/data/db_service.dart` (`_sqlReport...`), dipanggil lewat
`appState.loadReport()`, dan digambar oleh `lib/admin/widgets/charts.dart`.
Grafik otomatis dimuat ulang saat ada order baru atau status berubah. Query yang sama ada di
`database/silaundry.sql` bagian 6. Jika database tidak aktif, grafik memakai data di memori.

Data contoh berisi 18 order tersebar 6 minggu. Jika database `silaundry_app` sudah terlanjur
terisi dari versi sebelumnya (data contoh lama), kosongkan dulu supaya data baru dimasukkan:
di phpMyAdmin tab SQL jalankan `DROP DATABASE silaundry_app;` lalu jalankan aplikasi lagi.

## Akun demo

| Masuk sebagai | Username | Password |
|---|---|---|
| Admin | `admin` | `admin12345` |
| Customer | `budi01` | `rahasia12345` |
| Customer lain | `siti_a`, `andi22` | `rahasia12345` |

## Tabel dan relasi

    customers 1 --- N orders        (orders.customer_id -> customers.id)
    orders    1 --- N order_items   (order_items.order_id -> orders.id)
    services  1 --- N order_items   (order_items.service_id -> services.id)
    admins                          (akun admin)

## Fitur transactional

"Buat Order" menulis ke tabel `orders` dan `order_items` dalam satu transaksi
(`START TRANSACTION` ... `COMMIT`, atau `ROLLBACK` jika ada yang gagal).
Lihat method `insertOrder` di `lib/shared/data/db_service.dart`.
Bahan screenshot di phpMyAdmin: `database/silaundry.sql` (bagian 2 sampai 4).

## Struktur folder (dikelompokkan per kategori)

    lib/
      main.dart                     titik awal aplikasi
      admin/                        KHUSUS ADMIN
        pages/                      dashboard, customers, new user, orders, new order,
                                    order detail, service list, account settings, landing
        widgets/                    shell.dart (sidebar), dialogs.dart (dialog admin),
                                    charts.dart (bar, line, pie chart)
      customer/                     KHUSUS CUSTOMER
        pages/                      dashboard, service list, orders, new order, checkout,
                                    payment, account settings, landing
        widgets/                    shell.dart (sidebar), dialogs.dart (dialog customer)
      shared/                       DIPAKAI ADMIN DAN CUSTOMER
        auth/                       login, register, pilihan Customer/Admin
        data/                       models.dart, app_state.dart, db_service.dart (MySQL)
        widgets/                    komponen umum (input, tombol, tabel), layout login
        theme.dart                  warna dan gaya teks
    database/silaundry.sql          skema + contoh transaksi, rollback, dan query nota

Aturan: file di `admin/` tidak mengimpor file dari `customer/` (dan sebaliknya).
Keduanya hanya memakai `shared/`. Satu-satunya pengecualian adalah `shared/auth/login_page.dart`
yang membuka halaman landing admin atau customer sesuai peran yang dipilih.
