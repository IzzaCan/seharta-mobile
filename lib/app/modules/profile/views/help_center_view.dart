import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class HelpCenterView extends GetView<ProfileController> {
  const HelpCenterView({Key? key}) : super(key: key);

  // Palet Warna Seharta (Konsisten dengan ProfileView)
  final Color primaryDark = const Color(0xFF0D2B33);
  final Color greenAccent = const Color(0xFF1F9975);
  final Color backgroundColor = const Color(0xFFF8F9FF);
  final Color borderColor = const Color(0xFFE0E5E9);
  final Color questionColor = const Color(0xFF004D40); // Dark Teal
  final Color answerColor = const Color(0xFF333333); // Dark Grey

  static final List<Map<String, dynamic>> faqList = [
    {
      'topic': 'Akun Bersama',
      'icon': Icons.people_alt_rounded,
      'question': 'Bagaimana cara menghubungkan akun dengan pasangan?',
      'answer': 'Anda cukup membagikan \'Family ID\' yang tertera di halaman Profile kepada pasangan Anda. Setelah pasangan memasukkan ID tersebut saat pendaftaran atau di pengaturan akun, dompet dan pencatatan keuangan Anda berdua akan otomatis sinkron.',
    },
    {
      'topic': 'Keamanan',
      'icon': Icons.security_rounded,
      'question': 'Siapa saja yang bisa melihat data keuangan kami?',
      'answer': 'Keamanan data Anda adalah prioritas kami. Data keuangan di dalam Joint Account hanya dapat diakses oleh Anda dan pasangan resmi Anda yang terikat pada Family ID yang sama.',
    },
    {
      'topic': 'Fitur Scan Struk',
      'icon': Icons.document_scanner_rounded,
      'question': 'Bagaimana cara agar scan struk belanja berhasil 100%?',
      'answer': 'Untuk hasil OCR yang akurat, pastikan:\n\n1. Struk berada di tempat yang terang dan tidak remang-remang.\n2. Posisi kamera tepat tegak lurus di atas struk (tidak miring/distorsi).\n3. Tulisan nama toko, tanggal, serta total harga terlihat jelas dan tidak terlipat.',
    },
    {
      'topic': 'Fitur Analisis',
      'icon': Icons.analytics_rounded,
      'question': 'Apa perbedaan menu Anggaran di Home dan Analisis di Tab?',
      'answer': 'Menu Anggaran di halaman Beranda berfungsi sebagai pengontrol harian untuk melihat sisa kuota belanja agar tidak boros. Sementara menu Analisis (Analytics) dirancang untuk melihat performa makro keuangan, seperti total kekayaan bersih (Net Worth), grafik donat pengeluaran, hingga analisis perilaku siapa yang paling aktif mencatat transaksi.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryDark),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Pusat Bantuan',
          style: TextStyle(
            color: primaryDark,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: faqList.length,
        itemBuilder: (context, index) {
          final faq = faqList[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: primaryDark.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ExpansionTile(
                // Desain visual ExpansionTile bersih tanpa border bawaan
                shape: const Border(),
                collapsedShape: const Border(),
                iconColor: greenAccent,
                collapsedIconColor: Colors.grey[500],
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: greenAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    faq['icon'] as IconData,
                    color: greenAccent,
                    size: 20,
                  ),
                ),
                title: Text(
                  faq['question'] as String,
                  style: TextStyle(
                    color: questionColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        faq['answer'] as String,
                        style: TextStyle(
                          color: answerColor,
                          fontSize: 13,
                          height: 1.5, // Breathable line height
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
