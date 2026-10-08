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
- File yang sudah ada dengan nama/path yang sama di project UAS tidak digandakan; file baru hanya ditambahkan bila belum ada.

## Menjalankan
```bash
flutter pub get
flutter run
```
