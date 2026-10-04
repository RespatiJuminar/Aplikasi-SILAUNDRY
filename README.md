# SiLaundry - Prototype Admin Desktop (Flutter)

Konversi desain Figma "Desktop UI Admin Design Laundry" ke Flutter (Dart).

## Cara menjalankan (Windows + VS Code)

1. Buat proyek Flutter kosong:
   `flutter create silaundry --platforms=windows`
2. Ganti isi folder `lib/` dan `assets/` proyek itu dengan folder `lib/` dan `assets/` dari zip ini.
3. Buka `pubspec.yaml` proyek, tambahkan di bagian `flutter:`
   ```
   assets:
     - assets/images/
   ```
4. Hapus `test/widget_test.dart` (bawaan template, mengacu ke MyApp).
5. Jalankan: `flutter run -d windows`

Login demo: username `admin`, password `admin12345`.

## Struktur

- `lib/data/` model dan penyimpanan sementara (in-memory) di `app_state.dart`
- `lib/pages/` satu file per halaman desain
- `lib/widgets/` sidebar, dialog, input, tombol, tabel

## Alur halaman

Login (atau Register) -> Landing -> Dashboard. Menu sidebar: Dashboard, Customers,
Orders, Service List (ikon gear), Account Settings (ikon profil), Logout.

## Menyambung ke database

Semua data lewat `AppState` (`lib/data/app_state.dart`). Untuk mengganti ke
database, ubah method di file itu (addCustomer, createOrder, dst.) agar memanggil
query/API, halaman tidak perlu diubah.
