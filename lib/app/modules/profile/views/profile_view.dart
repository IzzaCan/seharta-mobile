import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/profile_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../data/providers/api_provider.dart';
import '../../notifications/controllers/notification_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  // Palet Warna Finansial Modern (Lebih sleek, minim saturasi mencolok)
  final Color primaryColor = const Color(0xFF0F172A); // Slate 900
  final Color secondaryColor = const Color(0xFF334155); // Slate 700
  final Color accentColor = const Color(0xFF0EA5E9); // Modern Blue/Teal Accent
  final Color greenAccent = const Color(0xFF10B981); // Emerald 500
  final Color redAccent = const Color(0xFFEF4444); // Red 500
  final Color backgroundColor = const Color(0xFFF8FAFC); // Slate 50
  final Color cardColor = Colors.white;
  final Color borderColor = const Color(0xFFE2E8F0); // Slate 200
  final Color bgLightAccent = const Color(0xFFF0F9FF); // Sky 50

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      
      // BOTTOM NAVIGATION BAR (Sama seperti Home)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(Routes.ADD_TRANSACTION);
        },
        backgroundColor: const Color(0xFF0D2B33), // Mempertahankan brand utama
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              icon: Icons.home_outlined,
              label: 'Beranda',
              isActive: false,
              onTap: () => Get.offAllNamed(Routes.HOME),
            ),
            _buildNavItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Harta',
              isActive: false,
              onTap: () => Get.offAllNamed(Routes.HARTA),
            ),
            const SizedBox(width: 48), // Ruang kosong untuk FAB
            _buildNavItem(
              icon: Icons.analytics_outlined,
              label: 'Analytics',
              isActive: false,
              onTap: () => Get.offAllNamed(Routes.ANALYTICS),
            ),
            _buildNavItem(
              icon: Icons.person,
              label: 'Profile',
              isActive: true,
              onTap: () {},
            ),
          ],
        ),
      ),

      
      // BODY / KONTEN UTAMA
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.settings_outlined, color: secondaryColor),
                      onPressed: () => controller.showSettingsBottomSheet(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 2. Dual-Avatar Connection Card (Kartu Utama)
                _buildDualAvatarCard(context),
                const SizedBox(height: 32),

                // 3. Section: Pengaturan Keluarga
                Text(
                  'Keluarga',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: secondaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSectionCard(
                  children: [
                    Obx(() {
                      final name = controller.familyName.value;
                      return _buildListTile(
                        title: 'Nama Keluarga',
                        subtitle: name.isEmpty ? 'Belum diatur' : name,
                        icon: Icons.people_outline,
                        iconBgColor: accentColor.withValues(alpha: 0.1),
                        iconColor: accentColor,
                        onTap: () => Get.toNamed(Routes.EDIT_FAMILY_NAME),
                      );
                    }),
                    Obx(() {
                      final notifController = Get.find<NotificationController>();
                      return _buildSwitchTile(
                        title: 'Pengaturan Notifikasi',
                        icon: Icons.notifications_active_outlined,
                        iconBgColor: greenAccent.withValues(alpha: 0.1),
                        iconColor: greenAccent,
                        value: notifController.isPushEnabled.value,
                        onChanged: (val) => notifController.togglePushSetting(val),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 24),

                // 4. Section: Kustomisasi Keuangan
                Text(
                  'Keuangan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: secondaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSectionCard(
                  children: [
                    _buildListTile(
                      title: 'Kelola Kategori',
                      icon: Icons.category_outlined,
                      iconBgColor: accentColor.withValues(alpha: 0.1),
                      iconColor: accentColor,
                      onTap: () => Get.toNamed(Routes.MANAGE_CATEGORIES),
                    ),
                    _buildListTile(
                      title: 'Kelola Dompet & Rekening',
                      icon: Icons.account_balance_wallet_outlined,
                      iconBgColor: accentColor.withValues(alpha: 0.1),
                      iconColor: accentColor,
                      onTap: () => Get.toNamed(Routes.MANAGE_WALLETS),
                    ),
                    _buildListTile(
                      title: 'Ekspor Data Transaksi',
                      icon: Icons.download_outlined,
                      iconBgColor: greenAccent.withValues(alpha: 0.1),
                      iconColor: greenAccent,
                      trailingWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildFileBadge('PDF'),
                          const SizedBox(width: 4),
                          _buildFileBadge('XLS'),
                        ],
                      ),
                      onTap: () => controller.showExportBottomSheet(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 5. Section: Keamanan & Akun
                Text(
                  'Keamanan & Akun',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: secondaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSectionCard(
                  children: [
                    GetBuilder<ProfileController>(
                      builder: (controller) => _buildSwitchTile(
                        title: 'Kunci Aplikasi (PIN)',
                        icon: Icons.lock_outline,
                        iconBgColor: secondaryColor.withValues(alpha: 0.1),
                        iconColor: secondaryColor,
                        value: controller.isAppLockOn,
                        onChanged: controller.toggleAppLock,
                      ),
                    ),
                    _buildListTile(
                      title: 'Ubah PIN',
                      icon: Icons.password_outlined,
                      iconBgColor: secondaryColor.withValues(alpha: 0.1),
                      iconColor: secondaryColor,
                      onTap: () => Get.toNamed(Routes.PIN),
                    ),
                    _buildListTile(
                      title: 'Pusat Bantuan',
                      icon: Icons.help_outline,
                      iconBgColor: secondaryColor.withValues(alpha: 0.1),
                      iconColor: secondaryColor,
                      onTap: () => Get.toNamed(Routes.HELP_CENTER),
                    ),
                    _buildListTile(
                      title: 'Keluar',
                      icon: Icons.logout,
                      iconBgColor: redAccent.withValues(alpha: 0.1),
                      iconColor: redAccent,
                      isDestructive: true,
                      showTrailing: false,
                      onTap: controller.logout,
                      isLast: true,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 6. Footer Version
                Center(
                  child: Obx(() => Text(
                    'Seharta ${controller.appVersion.value}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  )),
                ),
                const SizedBox(height: 80), // Padding untuk BottomNav
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- KOMPONEN BARU: DUAL AVATAR CARD ---
  Widget _buildDualAvatarCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. My Profile
          Row(
            children: [
              Obx(() => Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundImage: controller.avatarUrl != null
                        ? NetworkImage(ApiProvider.getImageUrl(controller.avatarUrl))
                        : const NetworkImage('https://ui-avatars.com/api/?name=Anda&background=0F172A&color=fff&size=150'),
                  ),
                  GestureDetector(
                    onTap: () => _showImageSourceDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              )),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                      controller.currentUser.value?.fullName ?? 'Pengguna',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    )),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                      controller.currentUser.value?.email ?? 'email@domain.com',
                      style: TextStyle(fontSize: 13, color: secondaryColor),
                    )),
                  ],
                ),
              ),
            ],
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          ),

          // 2. Partner Profile
          Row(
            children: [
              Obx(() => CircleAvatar(
                radius: 20,
                backgroundImage: controller.partnerAvatarUrl != null
                    ? NetworkImage(ApiProvider.getImageUrl(controller.partnerAvatarUrl))
                    : NetworkImage(
                        'https://ui-avatars.com/api/?name=${controller.partnerName ?? "P"}&background=10B981&color=fff',
                      ),
              )),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.link, size: 14, color: greenAccent),
                        const SizedBox(width: 4),
                        Text(
                          'Tertaut dengan',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: greenAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Obx(() => Text(
                      controller.partnerName ?? 'Belum tertaut',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    )),
                  ],
                ),
              ),
              // Unlink Button directly inside the card for better UX
              TextButton(
                onPressed: () => Get.toNamed(Routes.DISCONNECT_CONFIRMATION),
                style: TextButton.styleFrom(
                  backgroundColor: redAccent.withValues(alpha: 0.1),
                  foregroundColor: redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Putuskan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- REUSABLE WIDGETS LAMA YANG DISESUAIKAN ---

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    // Mempertahankan brand hijau asli Seharta di Navigasi
    final Color navActiveColor = const Color(0xFF0D2B33); 
    final Color navBgColor = const Color(0xFFE8F5EE);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? navBgColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: isActive ? navActiveColor : Colors.grey[400],
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? navActiveColor : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    bool isDestructive = false,
    bool showTrailing = true,
    Widget? trailingWidget,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isDestructive ? FontWeight.bold : FontWeight.w600,
                          color: isDestructive ? redAccent : primaryColor,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(fontSize: 12, color: secondaryColor),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailingWidget != null) trailingWidget,
                if (trailingWidget == null && showTrailing)
                  Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
              ],
            ),
          ),
          if (!isLast) const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9), indent: 64),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required bool value,
    required Function(bool) onChanged,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.white,
                activeTrackColor: accentColor,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey[300],
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9), indent: 64),
      ],
    );
  }

  Widget _buildFileBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: secondaryColor,
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Foto Profil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.camera_alt, color: accentColor),
              ),
              title: const Text('Ambil dari Kamera', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Get.back();
                controller.pickProfilePicture(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.photo_library, color: accentColor),
              ),
              title: const Text('Ambil dari Galeri', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Get.back();
                controller.pickProfilePicture(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
