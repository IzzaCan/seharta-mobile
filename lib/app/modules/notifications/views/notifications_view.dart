import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/time_ago.dart';
import '../../../utils/notification_parser.dart';

import '../../../data/models/notification_model.dart';
import '../bindings/notifications_page_controller.dart';

class NotificationsView extends GetView<NotificationsPageController> {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Semua Notifikasi',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          Obx(() {
            if (controller.globalController.hasUnread.value) {
              return TextButton(
                onPressed: () {
                  controller.globalController.markAllAsRead();
                },
                child: Text(
                  'Tandai Dibaca',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.onRefresh,
        color: Theme.of(context).colorScheme.secondary,
        child: Obx(() {
          final notifications = controller.globalController.allNotifications;
          final isLoading = controller.globalController.isLoadingAll.value;
          
          if (isLoading && notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (notifications.isEmpty) {
            return _buildEmptyState(context);
          }
          
          return ListView.separated(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: notifications.length + (controller.isLoadingMore.value ? 1 : 0),
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              if (index == notifications.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              
              final item = notifications[index];
              return _NotificationTile(
                notification: item,
                onTap: () {
                  if (!item.isRead) {
                    controller.globalController.markAsRead(item.id);
                  }
                  _showNotificationDetail(context, item);
                },
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: Get.height * 0.7,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada notifikasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Notifikasi aktivitas keluarga Anda\nakan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDetail(BuildContext context, NotificationResponse item) {
    final parsed = parseNotification(item);
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.secondary;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Dynamic Content Header
              _buildModalHeader(theme, accentColor, parsed, item),
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 20),
              
              // Dynamic Body Layout based on Category
              _buildModalBody(theme, accentColor, parsed),
              
              const SizedBox(height: 32),
              
              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalHeader(ThemeData theme, Color accentColor, ParsedNotification parsed, NotificationResponse item) {
    IconData iconData = Icons.notifications_none_rounded;
    Color iconColor = theme.primaryColor;
    Color bgColor = theme.primaryColor.withOpacity(0.1);
    
    switch (parsed.categoryType) {
      case 'TRANSACTION':
        iconData = Icons.receipt_long_rounded;
        iconColor = accentColor;
        bgColor = accentColor.withOpacity(0.1);
        break;
      case 'OCR':
        iconData = Icons.document_scanner_rounded;
        iconColor = Colors.blue.shade700;
        bgColor = Colors.blue.shade50;
        break;
      case 'BUDGET':
        iconData = parsed.isOverBudget ? Icons.error_outline_rounded : Icons.warning_amber_rounded;
        iconColor = parsed.isOverBudget ? Colors.red.shade700 : Colors.amber.shade700;
        bgColor = parsed.isOverBudget ? Colors.red.shade50 : Colors.amber.shade50;
        break;
      case 'WALLET':
        iconData = Icons.account_balance_wallet_rounded;
        iconColor = accentColor;
        bgColor = accentColor.withOpacity(0.1);
        break;
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, color: iconColor, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                parsed.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatFullDateTime(item.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModalBody(ThemeData theme, Color accentColor, ParsedNotification parsed) {
    switch (parsed.categoryType) {
      case 'TRANSACTION':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (parsed.amount != null) ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        parsed.transactionType == 'INCOME' ? 'Pemasukan' : 'Pengeluaran',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: parsed.transactionType == 'INCOME' ? accentColor : Colors.redAccent,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        parsed.amount!,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  _buildNotificationDetailRow('Kategori', parsed.categoryName ?? 'Umum'),
                  _buildNotificationDetailRow('Dompet', parsed.walletName ?? 'Dompet Bersama'),
                  _buildNotificationDetailRow('Keterangan', parsed.description ?? '-'),
                ],
              ),
            ),
          ],
        );
        
      case 'OCR':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.document_scanner_rounded, size: 40, color: Colors.blue.shade700),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              parsed.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            if (parsed.ocrMerchant != null || parsed.ocrTotal != null) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    if (parsed.ocrMerchant != null)
                      _buildNotificationDetailRow('Merchant', parsed.ocrMerchant!),
                    if (parsed.ocrTotal != null)
                      _buildNotificationDetailRow('Total Dideteksi', parsed.ocrTotal!),
                  ],
                ),
              ),
            ],
          ],
        );
        
      case 'BUDGET':
        final Color alertColor = parsed.isOverBudget ? Colors.red.shade700 : Colors.amber.shade700;
        final Color alertBg = parsed.isOverBudget ? Colors.red.shade50 : Colors.amber.shade50;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: alertBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: alertColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    parsed.isOverBudget ? Icons.error_outline_rounded : Icons.warning_amber_rounded,
                    color: alertColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      parsed.isOverBudget ? 'Segera evaluasi pengeluaran bersama!' : 'Hampir mencapai batas anggaran keluarga.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: alertColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              parsed.message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            if (parsed.budgetPercentage != null || parsed.budgetRemaining != null) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    if (parsed.budgetPercentage != null)
                      _buildNotificationDetailRow('Penggunaan', parsed.budgetPercentage!),
                    if (parsed.budgetRemaining != null)
                      _buildNotificationDetailRow('Sisa Anggaran', parsed.budgetRemaining!),
                  ],
                ),
              ),
            ],
          ],
        );
        
      case 'WALLET':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card wallet mock visual
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 28),
                  SizedBox(height: 24),
                  Text(
                    'Dompet Bersama Keluarga',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Saldo Terupdate',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              parsed.message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        );
        
      default:
        return Text(
          parsed.message,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.5,
          ),
        );
    }
  }

  Widget _buildNotificationDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationResponse notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isUnread = !notification.isRead;
    
    // Choose icon based on type
    IconData iconData = Icons.notifications_outlined;
    Color iconColor = Colors.grey.shade600;
    Color bgColor = Colors.grey.shade100;
    
    if (notification.type == 'ACTIVITY') {
      iconData = Icons.compare_arrows_rounded;
      iconColor = theme.colorScheme.secondary;
      bgColor = theme.colorScheme.secondary.withOpacity(0.1);
    } else {
      iconData = Icons.info_outline_rounded;
      iconColor = theme.primaryColor;
      bgColor = theme.primaryColor.withOpacity(0.1);
    }

    return Material(
      color: isUnread ? Colors.white : const Color(0xFFFAFAFA),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                              color: isUnread ? Colors.black87 : Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatTimeAgo(notification.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: isUnread ? theme.colorScheme.secondary : Colors.grey.shade500,
                            fontWeight: isUnread ? FontWeight.w500 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: isUnread ? Colors.black87 : Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              // Unread Indicator Dot
              if (isUnread) ...[
                const SizedBox(width: 12),
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
