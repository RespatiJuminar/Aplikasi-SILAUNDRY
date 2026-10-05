# SiLaundry - Prototype Desktop (Admin + Customer) - Flutter

Satu proyek untuk dua sisi aplikasi. Di halaman login pilih **Customer** atau **Admin**.
Data dipakai bersama: order yang dibuat customer langsung muncul di admin, dan status
yang diubah admin langsung terlihat customer.

## Cara menjalankan (Windows + VS Code)

1. `flutter create silaundry --platforms=windows`
2. Ganti folder `lib/` dan `assets/` proyek itu dengan folder `lib/` dan `assets/` dari zip ini.
3. Di `pubspec.yaml` proyek, tambahkan di bagian `flutter:`
   ```
   assets:
     - assets/images/
   ```
4. Hapus `test/widget_test.dart` (bawaan template).
5. `flutter run -d windows`

## Akun demo

| Masuk sebagai | Username | Password |
|---|---|---|
| Admin | `admin` | `admin12345` |
| Customer | `budi01` | `rahasia12345` |
| Customer lain | `siti_a`, `andi22` | `rahasia12345` |

## Struktur

- `lib/auth/` login, register, dan pilihan Customer/Admin
- `lib/admin/` semua halaman sisi admin (+ sidebar dan dialog sendiri)
- `lib/customer/` semua halaman sisi customer (+ sidebar dan dialog sendiri)
- `lib/data/` model dan penyimpanan data bersama (`app_state.dart`)
- `lib/widgets/` komponen umum (input, tombol, tabel)

## Menyambung ke database

Semua data lewat `lib/data/app_state.dart`. Ubah method di file itu (addCustomer,
createOrder, dst.) agar memanggil query/API, halaman tidak perlu diubah.
