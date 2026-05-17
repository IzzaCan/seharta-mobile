# 💍 Seharta (Satu Harta) - Joint Financial Management App

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![GetX](https://img.shields.io/badge/GetX-Architecture-blue?style=for-the-badge)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

**Seharta** adalah aplikasi pencatatan dan manajemen keuangan yang dirancang khusus untuk pasangan. Berbeda dengan aplikasi keuangan pada umumnya, Seharta secara radikal menghilangkan fitur dompet pribadi untuk menciptakan transparansi finansial 100% dalam keluarga. Aplikasi ini mengintegrasikan teknologi *Computer Vision* (OCR) untuk kemudahan *input* data dan *Large Language Model* (LLM) untuk memberikan wawasan finansial yang cerdas.

## ✨ Fitur Utama (Key Features)

* **Asynchronous Couple Pairing:** Tautkan akun dengan pasangan menggunakan Kode PIN 6-digit atau pemindaian QR Code tanpa harus *online* di waktu yang bersamaan. Kode *pairing* tetap dapat diakses kapan saja melalui menu Profil/Pengaturan Keluarga dalam bentuk *Bottom Sheet* interaktif.
* **Smart Receipt Scanner (OCR):** Pencatatan pengeluaran otomatis dari foto struk belanja menggunakan teknologi Google ML Kit.
* **100% Shared Wallets:** Seluruh dompet dan rekening bersifat gabungan. Setiap transaksi dilengkapi dengan *Contributor Badge* (Avatar) untuk melacak siapa yang melakukan *input*.
* **AI Financial Insights:** Evaluasi pengeluaran bulanan dan rekomendasi optimasi anggaran berbasis AI (LLM).
* **Asset & Goal Tracking:** Pantau komposisi aset tetap (kendaraan, emas, properti) dan progres tabungan masa depan dengan indikator visual yang intuitif.

## 🛠️ Teknologi yang Digunakan (Tech Stack)

**Mobile Application (Frontend):**
* **Framework:** Flutter (Dart)
* **State Management & Routing:** GetX (Get CLI)
* **UI Components:** Custom Canvas (Donut Charts), Glassmorphism, Slidable Lists.
* **Device APIs:** Camera, Local Storage.

## 📂 Struktur Proyek (GetX Pattern)

Proyek ini dibangun menggunakan standar **GetX Pattern** untuk memisahkan *logic*, *view*, dan *routing* agar kode lebih mudah dikelola (*maintainable*).

```text
lib/
│
├── app/
│   ├── data/                 # Model, Provider, dan API Services
│   ├── modules/              # Berisi seluruh halaman aplikasi
│   │   ├── add_transaction/  # Controller, Binding, View
│   │   ├── analytics/
│   │   ├── change_pin/
│   │   ├── edit_family_name/
│   │   ├── harta/
│   │   ├── home/
│   │   ├── loading_ocr/
│   │   ├── manage_categories/
│   │   ├── manage_wallets/
│   │   ├── profile/
│   │   ├── scan_receipt/
│   │   └── select_status/
│   │
│   └── routes/               # Definisi AppPages dan AppRoutes
│
└── main.dart                 # Entry point aplikasi
```
## 🚀 Cara Instalasi & Menjalankan Proyek (Getting Started)

### Prasyarat (Prerequisites)
* Flutter SDK (Versi 3.x ke atas)
* Dart SDK
* Android Studio / VS Code dengan ekstensi Flutter

### Langkah-langkah Instalasi
1. Lakukan *Clone* repositori ini:
   ```bash
   git clone [https://github.com/username-anda/seharta-app.git](https://github.com/IzzaCan/seharta-app.git)
   ```
2. Masuk ke direktori proyek:
```Bash
cd seharta-app
```
3. Unduh seluruh dependensi aplikasi:
```Bash
flutter pub get
```
4. Jalankan aplikasi di emulator atau perangkat fisik:
```Bash
flutter run
```
(Catatan: Jika menjalankan di Flutter Web dan gambar aset tidak muncul, bersihkan cache terlebih dahulu menggunakan flutter clean lalu flutter run -d chrome).
