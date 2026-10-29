# UKu — hasil penggabungan interaktif

Basis project yang dipakai adalah `UAS-KEL3-MOBILE`. Asset gambar dan ikon dari project tersebut dipertahankan.

## Perubahan
- Tampilan dan asset yang sudah ada dipertahankan.
- Form Pengeluaran sekarang interaktif: kategori, jumlah, tanggal, lokasi, keperluan, metode pembayaran, validasi, dan simpan data.
- Data pengeluaran langsung memperbarui Beranda, Budget, dan Transaksi.
- Rekap Aktivitas memakai grafik nyata `fl_chart` (bar chart dan pie chart), bukan gambar statis.
- Tanggal pada Rekap dan Transaksi dapat dipilih.
- Budget dapat diubah.
- Target Nabung dapat dibuat dan saldo target dapat ditambah.
- Login, daftar, profil, pengeluaran, budget, dan tabungan memakai mobile API ketika pengguna masuk.
- Splash tampil 10 detik lalu menuju login; lupa password mengirim OTP email melalui backend.
- Mode Foto Bill menampilkan preview kamera langsung dan dapat mengambil gambar struk.
- File yang sudah ada dengan nama/path yang sama di project UAS tidak digandakan; file baru hanya ditambahkan bila belum ada.

## Menjalankan
```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5001/api
```

Jalankan backend mobile dari folder `backend/mobile` dengan `npm install` lalu `npm run dev`. URL `10.0.2.2` dipakai untuk Android Emulator. Untuk perangkat fisik, ganti `API_BASE_URL` dengan alamat IP LAN komputer yang menjalankan backend; untuk Windows desktop gunakan `http://localhost:5001/api`.
