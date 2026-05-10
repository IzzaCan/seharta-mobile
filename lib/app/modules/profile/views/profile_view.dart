import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../routes/app_pages.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  // Palet Warna
  final Color primaryColor = const Color(0xFF0D2B33); // Dark Teal
  final Color greenAccent = const Color(0xFF2ECC71); // Light Emerald Green
  final Color redAccent = const Color(0xFFE74C3C); // Danger Red
  final Color backgroundColor = const Color(0xFFF8F9FF);
  final Color cardColor = Colors.white;
  final Color borderColor = const Color(0xFFE0E5E9);
  final Color bgLightGreen = const Color(0xFFE8F5EE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      
      // BOTTOM NAVIGATION BAR (Sama seperti Home)
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(Routes.ADD_TRANSACTION);
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                label: 'HOME',
                isActive: false,
                onTap: () => Get.offAllNamed(Routes.HOME),
              ),
              _buildNavItem(
                icon: Icons.account_balance_wallet_outlined,
                label: 'HARTA',
                isActive: false,
                onTap: () => Get.offAllNamed(Routes.HARTA),
              ),
              const SizedBox(width: 48), // Ruang untuk FAB
              _buildNavItem(
                icon: Icons.bar_chart_rounded,
                label: 'ANALYTICS',
                isActive: false,
                onTap: () => Get.offAllNamed(Routes.ANALYTICS),
              ),
              _buildNavItem(
                icon: Icons.person,
                label: 'PROFILE',
                isActive: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),

      
      // BODY / KONTEN UTAMA
      
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Header Sederhana
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/100?img=11',
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: greenAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 2. Foto Profil & Identitas Utama
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=11',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Adit Pratama',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'adit.pratama@email.com',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(height: 16),

              // 3. Badge Status Tautan Pasangan
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF67F2A5,
                  ), // Warna hijau terang dari desain
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Tertaut dengan Sarah 💍',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D2B33),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const CircleAvatar(
                        radius: 8,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/100?img=5',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 4. Section: Pengaturan Keluarga
              _buildSectionCard(
                icon: Icons.people_outline,
                title: 'Pengaturan Keluarga',
                children: [
                  _buildListTile(
                    title: 'Ubah Nama Keluarga',
                    subtitle: 'Keluarga Adit & Sarah',
                    onTap: () => Get.toNamed(Routes.EDIT_FAMILY_NAME),
                  ),
                  _buildSwitchTile(
                    title: 'Notifikasi Pasangan',
                    value: controller.isNotificationOn,
                    onChanged: controller.toggleNotification,
                  ),
                  _buildListTile(
                    title: 'Putuskan Tautan',
                    icon: Icons.link_off,
                    isDestructive: true,
                    showTrailing: false,
                    onTap: controller.unpairAccount,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 5. Section: Kustomisasi Keuangan
              _buildSectionCard(
                icon: Icons.account_balance_outlined,
                title: 'Kustomisasi Keuangan',
                children: [
                  _buildListTile(
                    title: 'Kelola Kategori',
                    icon: Icons.category_outlined,
                    onTap: () => Get.toNamed(Routes.MANAGE_CATEGORIES),
                  ),
                  _buildListTile(
                    title: 'Kelola Dompet/Rekening',
                    icon: Icons.account_balance_wallet_outlined,
                    onTap: () => Get.toNamed(Routes.MANAGE_WALLETS),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 6. Section: Keamanan & Privasi
              _buildSectionCard(
                icon: Icons.security_outlined,
                title: 'Keamanan & Privasi',
                children: [
                  _buildSwitchTile(
                    title: 'Kunci Aplikasi',
                    icon: Icons.lock_outline,
                    value: controller.isAppLockOn,
                    onChanged: controller.toggleAppLock,
                  ),
                  _buildListTile(
                    title: 'Ubah PIN',
                    icon: Icons.password_outlined,
                    onTap: () => Get.toNamed(Routes.CHANGE_PIN),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 7. Section: Ekspor Data & Bantuan
              _buildSectionCard(
                icon: Icons.settings_outlined,
                title: 'Ekspor Data & Bantuan',
                children: [
                  _buildListTile(
                    title: 'Ekspor Data Transaksi',
                    icon: Icons.download_outlined,
                    trailingWidget: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildFileBadge('PDF'),
                        const SizedBox(width: 4),
                        _buildFileBadge('XLS'),
                      ],
                    ),
                    onTap: () {},
                  ),
                  _buildListTile(
                    title: 'Pusat Bantuan & FAQ',
                    icon: Icons.help_outline,
                    showTrailing: false,
                    onTap: () {},
                  ),
                  _buildListTile(
                    title: 'Syarat & Ketentuan',
                    icon: Icons.description_outlined,
                    showTrailing: false,
                    onTap: () {},
                  ),
                  _buildListTile(
                    title: 'Keluar',
                    icon: Icons.logout,
                    isDestructive: true,
                    showTrailing: false,
                    onTap: controller.logout,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 8. Footer Version
              Text(
                'Versi Aplikasi 2.4.1 (Stable Build)',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              const SizedBox(height: 80), // Padding untuk BottomNav
            ],
          ),
        ),
      ),
    );
  }

  
  // REUSABLE WIDGETS
  

  // Komponen Navigasi Bawah
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: isActive
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
            : null,
        decoration: isActive
            ? BoxDecoration(
                color: bgLightGreen,
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isActive ? primaryColor : Colors.grey[400], size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? primaryColor : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Kerangka Card untuk setiap Section
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: greenAccent, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Column(children: children),
        ],
      ),
    );
  }

  // Item List Standar (dengan panah chevron)
  Widget _buildListTile({
    required String title,
    String? subtitle,
    IconData? icon,
    bool isDestructive = false,
    bool showTrailing = true,
    Widget? trailingWidget,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isDestructive ? redAccent : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isDestructive
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isDestructive ? redAccent : primaryColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
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
    );
  }

  // Item List dengan Switch (Toggle)
  Widget _buildSwitchTile({
    required String title,
    IconData? icon,
    required RxBool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.grey[600], size: 20),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: primaryColor,
              ),
            ),
          ),
          Obx(
            () => Switch(
              value: value.value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: primaryColor,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }

  // Badge khusus untuk PDF dan XLS
  Widget _buildFileBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
