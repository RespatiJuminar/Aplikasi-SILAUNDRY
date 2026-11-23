-- =====================================================================
-- SiLaundry - Database MySQL (XAMPP / phpMyAdmin), nama database: silaundry_app
-- Aplikasi membuat database dan tabel ini OTOMATIS saat pertama dijalankan.
-- File ini untuk dokumentasi dan bahan screenshot di phpMyAdmin
-- (tab SQL) atau MySQL Workbench.
--
-- Relasi:
--   customers 1 --- N orders        (orders.customer_id -> customers.id)
--   orders    1 --- N order_items   (order_items.order_id -> orders.id)
--   services  1 --- N order_items   (order_items.service_id -> services.id)
-- =====================================================================

-- ---------------------------------------------------------------------
-- BAGIAN 1. Struktur database
-- ---------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS silaundry_app CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE silaundry_app;

CREATE TABLE IF NOT EXISTS admins (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  address VARCHAR(200) NOT NULL,
  dob DATE NOT NULL,
  phone VARCHAR(20) NOT NULL,
  password VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS customers (
  id VARCHAR(10) PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  address VARCHAR(200) NOT NULL,
  dob DATE NOT NULL,
  phone VARCHAR(20) NOT NULL,
  password VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS services (
  id VARCHAR(10) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  price_per_kg INT NOT NULL,
  days INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- Bagian 2-5 butuh data awal: jalankan aplikasi SATU KALI dulu supaya
-- customers (USR-001) dan services (SRV-001, SRV-002) terisi.
-- ---------------------------------------------------------------------

-- ---------------------------------------------------------------------
-- BAGIAN 2. FITUR TRANSAKSIONAL: membuat order (menulis 2 tabel sekaligus)
-- Satu order = 1 baris di orders + 2 baris di order_items.
-- Semua berhasil bersama (COMMIT) atau batal bersama (ROLLBACK).
-- ---------------------------------------------------------------------
START TRANSACTION;

INSERT INTO orders (id, customer_id, customer_name, customer_address, customer_phone,
                    order_date, note, status, payment_method, paid)
VALUES ('ORD-9001', 'USR-001', 'Budi Santoso', 'Jl. Mawar No. 12', '081311112222',
        NOW(), 'Contoh transaksi', 'received', NULL, 0);

INSERT INTO order_items (order_id, service_id, service_name, price_per_kg, qty, detail)
VALUES ('ORD-9001', 'SRV-001', 'Laundry 2 Hari', 8000, 3.00, '5 kaos, 2 celana'),
       ('ORD-9001', 'SRV-002', 'Laundry 1 Hari', 9500, 2.00, 'Seprai');

COMMIT;

-- ---------------------------------------------------------------------
-- BAGIAN 3. Transaksi DIBATALKAN (ROLLBACK)
-- Data masuk sementara di dalam transaksi, lalu dibatalkan sehingga
-- tidak ada yang tersimpan (ORD-9002 tidak akan ada setelah ROLLBACK).
-- ---------------------------------------------------------------------
START TRANSACTION;

INSERT INTO orders (id, customer_id, customer_name, customer_address, customer_phone,
                    order_date, note, status, payment_method, paid)
VALUES ('ORD-9002', 'USR-001', 'Budi Santoso', 'Jl. Mawar No. 12', '081311112222',
        NOW(), 'Akan dibatalkan', 'received', NULL, 0);

INSERT INTO order_items (order_id, service_id, service_name, price_per_kg, qty, detail)
VALUES ('ORD-9002', 'SRV-001', 'Laundry 2 Hari', 8000, 1.00, '');

SELECT id, note FROM orders WHERE id = 'ORD-9002';   -- masih terlihat di dalam transaksi

ROLLBACK;

SELECT id, note FROM orders WHERE id = 'ORD-9002';   -- kosong: sudah dibatalkan

-- ---------------------------------------------------------------------
-- BAGIAN 4. Nota transaksi (gabungan 4 tabel dengan JOIN)
-- ---------------------------------------------------------------------
SELECT o.id AS no_order, c.name AS customer, o.order_date,
       s.name AS layanan, i.qty AS kg, i.price_per_kg AS harga,
       i.qty * i.price_per_kg AS subtotal
FROM orders o
JOIN customers   c ON c.id = o.customer_id
JOIN order_items i ON i.order_id = o.id
JOIN services    s ON s.id = i.service_id
WHERE o.id = 'ORD-9001'
ORDER BY i.id;

-- Total per order
SELECT o.id AS no_order, o.status, SUM(i.qty * i.price_per_kg) AS total
FROM orders o
JOIN order_items i ON i.order_id = o.id
GROUP BY o.id, o.status
ORDER BY o.order_date DESC;

-- ---------------------------------------------------------------------
-- BAGIAN 5. Membersihkan data contoh (item ikut terhapus: ON DELETE CASCADE)
-- ---------------------------------------------------------------------
DELETE FROM orders WHERE id IN ('ORD-9001', 'ORD-9002');

-- ---------------------------------------------------------------------
-- BAGIAN 6. QUERY LAPORAN (angka di grafik dashboard admin berasal dari
-- query-query ini; dijalankan aplikasi lewat db_service.dart)
-- Hasilnya berisi jika aplikasi sudah memasukkan data contoh
-- (jalankan aplikasinya minimal satu kali).
--
-- FILTER PERIODE: ubah @days_back (= jumlah hari periode dikurangi 1)
--   7 hari terakhir = 6 | 30 hari = 29 | 6 minggu (42 hari) = 41 | 90 hari = 89
-- GROUPING TREN: pilih salah satu query 6b (per hari / minggu / bulan)
-- ---------------------------------------------------------------------
SET @days_back = 41;   -- 6 minggu terakhir

-- 6a. BAR CHART - perbandingan layanan: total nilai order per layanan
SELECT s.name AS nama, COALESCE(SUM(i.qty * i.price_per_kg), 0) AS total
FROM services s
LEFT JOIN (
    SELECT oi.service_id, oi.qty, oi.price_per_kg
    FROM order_items oi
    JOIN orders o ON o.id = oi.order_id
    WHERE o.order_date >= DATE_SUB(CURDATE(), INTERVAL @days_back DAY)
) i ON i.service_id = s.id
GROUP BY s.id, s.name
ORDER BY s.id;

-- 6b-1. LINE CHART - jumlah order per HARI
SELECT DATEDIFF(CURDATE(), DATE(order_date)) AS bucket, COUNT(*) AS jumlah
FROM orders
WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL @days_back DAY)
GROUP BY bucket;

-- 6b-2. LINE CHART - jumlah order per MINGGU (bucket 0 = 7 hari terakhir)
SELECT FLOOR(DATEDIFF(CURDATE(), DATE(order_date)) / 7) AS bucket, COUNT(*) AS jumlah
FROM orders
WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL @days_back DAY)
GROUP BY bucket;

-- 6b-3. LINE CHART - jumlah order per BULAN
SELECT PERIOD_DIFF(DATE_FORMAT(CURDATE(), '%Y%m'), DATE_FORMAT(order_date, '%Y%m')) AS bucket,
       COUNT(*) AS jumlah
FROM orders
WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL @days_back DAY)
GROUP BY bucket;

-- 6c. PIE CHART - jumlah order per status
SELECT status, COUNT(*) AS jumlah
FROM orders
WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL @days_back DAY)
GROUP BY status;
