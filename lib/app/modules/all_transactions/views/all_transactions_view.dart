import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/all_transactions_controller.dart';
import '../../wallet/models/wallet_model.dart';
import '../../../data/providers/api_provider.dart';

class AllTransactionsView extends GetView<AllTransactionsController> {
  const AllTransactionsView({Key? key}) : super(key: key);

  // Palet Warna Seharta
  final Color primaryDark = const Color(0xFF0D2B33);
  final Color primaryColor = const Color(0xFF0D2B33);
  final Color greenAccent = const Color(0xFF1F9975);
  final Color backgroundColor = const Color(0xFFF8F9FF);
  final Color cardBackgroundColor = Colors.white;
  final Color borderColor = const Color(0xFFE0E5E9);

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
          'Semua Riwayat',
          style: TextStyle(
            color: primaryDark,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips (Bulan/Tahun & Jenis)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            height: 52,
            child: Obx(() {
              final hasCustomDate = controller.startDate.value != null && controller.endDate.value != null;
              final dateRangeText = hasCustomDate 
                  ? '${DateFormat('dd MMM').format(controller.startDate.value!)} - ${DateFormat('dd MMM').format(controller.endDate.value!)}'
                  : '';
              return ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Advanced Filter Button
                  GestureDetector(
                    onTap: () => _showFilterBottomSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: primaryDark,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Icon(Icons.filter_list, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  if (hasCustomDate) ...[
                    _buildFilterChip(
                      label: dateRangeText,
                      isActive: true,
                      onTap: () => controller.clearDateRange(),
                      onClose: true,
                    ),
                  ] else ...[
                    _buildFilterChip(
                      label: 'Bulan Ini',
                      isActive: controller.selectedMonth.value == DateTime.now().month && 
                                controller.selectedYear.value == DateTime.now().year,
                      onTap: () => controller.changeMonth(DateTime.now().month, DateTime.now().year),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Bulan Lalu',
                      isActive: controller.selectedMonth.value == (DateTime.now().month == 1 ? 12 : DateTime.now().month - 1) && 
                                controller.selectedYear.value == (DateTime.now().month == 1 ? DateTime.now().year - 1 : DateTime.now().year),
                      onTap: () {
                        final prevMonth = DateTime.now().month == 1 ? 12 : DateTime.now().month - 1;
                        final prevYear = DateTime.now().month == 1 ? DateTime.now().year - 1 : DateTime.now().year;
                        controller.changeMonth(prevMonth, prevYear);
                      },
                    ),
                  ],
                  const SizedBox(width: 12),
                  Container(width: 1, color: borderColor), // Separator
                  const SizedBox(width: 12),
                  _buildTypeChip(label: 'Semua', type: 'ALL'),
                  const SizedBox(width: 8),
                  _buildTypeChip(label: 'Pemasukan', type: 'INCOME'),
                  const SizedBox(width: 8),
                  _buildTypeChip(label: 'Pengeluaran', type: 'EXPENSE'),
                  const SizedBox(width: 8),
                  _buildTypeChip(label: 'Transfer', type: 'TRANSFER'),
                ],
              );
            }),
          ),
          const SizedBox(height: 12),
          
          // Daftar Transaksi (Lazy-loaded)
          Expanded(
            child: controller.obx(
              (transactions) => ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemCount: transactions!.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  return _buildTransactionItem(tx, context);
                },
              ),
              onLoading: const Center(child: CircularProgressIndicator()),
              onEmpty: _buildEmptyState(),
              onError: (error) => Center(
                child: Text('Gagal memuat: $error', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    bool onClose = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? primaryDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? primaryDark : borderColor,
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: primaryDark.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[700],
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (onClose) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.close,
                size: 14,
                color: isActive ? Colors.white : Colors.grey[700],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip({required String label, required String type}) {
    return Obx(() {
      final isActive = controller.selectedType.value == type;
      return _buildFilterChip(
        label: label,
        isActive: isActive,
        onTap: () => controller.changeType(type),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada transaksi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada riwayat transaksi yang cocok.',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel tx, BuildContext context) {
    final isExpense = tx.transactionType.toUpperCase() == 'EXPENSE' || tx.transactionType.toUpperCase() == 'TRANSFER';
    final isTransfer = tx.transactionType.toUpperCase() == 'TRANSFER';
    final icon = isTransfer
        ? Icons.swap_horiz
        : (isExpense ? Icons.shopping_basket_outlined : Icons.account_balance_wallet_outlined);
    final title = _shortTitle(tx, isExpense, isTransfer);
    final category = tx.categoryName ?? 'Transfer';
    final amount = '${isExpense ? "-" : "+"} ${controller.formatRupiah(tx.amount)}';
    final wallet = tx.walletName ?? 'Dompet';
    final avatarUrl = tx.creatorAvatarUrl != null
        ? ApiProvider.getImageUrl(tx.creatorAvatarUrl)
        : 'https://ui-avatars.com/api/?name=${tx.creatorName ?? "User"}&background=1F9975&color=fff';
    final date = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.tryParse(tx.transactionDate) ?? DateTime.now());

    return Material(
      color: cardBackgroundColor,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showTransactionDetailBottomSheet(context, tx),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 0.8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 46,
                height: 46,
                child: Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5EE),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: const Color(0xFF1F9975), size: 20),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 8,
                          backgroundImage: NetworkImage(avatarUrl),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$category • $date',
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isExpense ? Colors.red : const Color(0xFF1F9975),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    wallet,
                    style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: judul pendek untuk kartu list (merchant dari hasil OCR),
  // menyembunyikan dump notes panjang agar tidak tampil di list.
  String _shortTitle(TransactionModel tx, bool isExpense, bool isTransfer) {
    final notes = tx.notes;
    if (notes != null && notes.isNotEmpty) {
      if (notes.startsWith('DETAIL SCAN STRUK')) {
        // Dump hasil OCR: ambil "Merchant : <nama>" sebagai judul singkat.
        final merchantMatch =
            RegExp(r'Merchant[ \t]*:[ \t]*([^\n]+)', caseSensitive: false).firstMatch(notes);
        if (merchantMatch != null) {
          final merchant = merchantMatch.group(1)!.trim();
          if (merchant.isNotEmpty) return merchant;
        }
      } else {
        // Catatan biasa (bukan dump OCR): gunakan baris pertamanya.
        final firstLine = notes.split('\n').first.trim();
        if (firstLine.isNotEmpty) return firstLine;
      }
    }
    return isTransfer ? 'Transfer' : (isExpense ? 'Pengeluaran' : 'Pemasukan');
  }

  void _showTransactionDetailBottomSheet(BuildContext context, TransactionModel tx) {
    final isExpense = tx.transactionType.toUpperCase() == 'EXPENSE' || tx.transactionType.toUpperCase() == 'TRANSFER';
    final isTransfer = tx.transactionType.toUpperCase() == 'TRANSFER';
    
    final typeText = isTransfer 
        ? 'Transfer' 
        : (isExpense ? 'Pengeluaran' : 'Pemasukan');
    final typeColor = isTransfer 
        ? const Color(0xFF007AFF) 
        : (isExpense ? Colors.red : const Color(0xFF1F9975));

    final amountText = '${isExpense ? "-" : "+"} ${controller.formatRupiah(tx.amount)}';
    final formattedDate = DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.tryParse(tx.transactionDate) ?? DateTime.now());
    
    final avatarUrl = tx.creatorAvatarUrl != null
        ? ApiProvider.getImageUrl(tx.creatorAvatarUrl)
        : 'https://ui-avatars.com/api/?name=${tx.creatorName ?? "User"}&background=1F9975&color=fff';

    Get.bottomSheet(
      SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detail Transaksi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: primaryDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, size: 20, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Amount Display Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: typeColor.withOpacity(0.15), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          typeText,
                          style: TextStyle(
                            color: typeColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        amountText,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: typeColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (tx.notes != null && tx.notes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          tx.notes!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Details List Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor, width: 0.8),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        icon: Icons.category_outlined,
                        label: 'Kategori',
                        value: tx.categoryName ?? 'Transfer',
                      ),
                      const Divider(height: 24, thickness: 0.5),
                      _buildDetailRow(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Dompet',
                        value: tx.walletName ?? 'Dompet',
                      ),
                      const Divider(height: 24, thickness: 0.5),
                      _buildDetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Tanggal',
                        value: formattedDate,
                      ),
                      const Divider(height: 24, thickness: 0.5),
                      _buildCreatorRow(
                        avatarUrl: avatarUrl,
                        name: tx.creatorName ?? 'User',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: Colors.grey[400]),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCreatorRow({
    required String avatarUrl,
    required String name,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.person_outline, size: 20, color: Colors.grey[400]),
        const SizedBox(width: 12),
        Text(
          'Dibuat Oleh',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundImage: NetworkImage(avatarUrl),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 14,
                color: primaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
  void _showFilterBottomSheet(BuildContext context) {
    final tempType = controller.selectedType.value.obs;
    final tempMonth = controller.selectedMonth.value.obs;
    final tempYear = controller.selectedYear.value.obs;
    final tempStart = Rxn<DateTime>(controller.startDate.value);
    final tempEnd = Rxn<DateTime>(controller.endDate.value);

    Get.bottomSheet(
      SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Transaksi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: primaryDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, size: 20, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Transaction Type
                _buildSectionTitle('Tipe Transaksi'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildImpeccableTypeChip('Semua', 'ALL', tempType),
                    _buildImpeccableTypeChip('Pemasukan', 'INCOME', tempType),
                    _buildImpeccableTypeChip('Pengeluaran', 'EXPENSE', tempType),
                    _buildImpeccableTypeChip('Transfer', 'TRANSFER', tempType),
                  ],
                ),
                const SizedBox(height: 28),

                // Periode Section (Bulan & Tahun)
                _buildSectionTitle('Periode (Bulan & Tahun)'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildImpeccableDropdown<int>(
                        value: tempMonth,
                        items: List.generate(12, (index) => index + 1),
                        labelBuilder: (val) => _monthName(val),
                        onChanged: (val) {
                          tempMonth.value = val;
                          tempStart.value = null;
                          tempEnd.value = null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildImpeccableDropdown<int>(
                        value: tempYear,
                        items: [2024, 2025, 2026, 2027],
                        labelBuilder: (val) => val.toString(),
                        onChanged: (val) {
                          tempYear.value = val;
                          tempStart.value = null;
                          tempEnd.value = null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Date Range
                _buildSectionTitle('Rentang Tanggal Kustom'),
                const SizedBox(height: 12),
                Obx(() {
                  final hasCustomDate = tempStart.value != null && tempEnd.value != null;
                  final text = hasCustomDate
                      ? '${DateFormat('dd MMM yyyy').format(tempStart.value!)} - ${DateFormat('dd MMM yyyy').format(tempEnd.value!)}'
                      : 'Pilih Rentang Tanggal...';
                  return InkWell(
                    onTap: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        initialDateRange: hasCustomDate
                            ? DateTimeRange(start: tempStart.value!, end: tempEnd.value!)
                            : null,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: primaryDark,
                                onPrimary: Colors.white,
                                surface: Colors.white,
                                onSurface: primaryDark,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        tempStart.value = picked.start;
                        tempEnd.value = picked.end;
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: hasCustomDate ? greenAccent.withOpacity(0.1) : Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: hasCustomDate ? greenAccent.withOpacity(0.5) : borderColor,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded, 
                                color: hasCustomDate ? greenAccent : Colors.grey[400], 
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                text,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: hasCustomDate ? primaryDark : Colors.grey[500],
                                  fontWeight: hasCustomDate ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          if (hasCustomDate)
                            GestureDetector(
                              onTap: () {
                                tempStart.value = null;
                                tempEnd.value = null;
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: greenAccent.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.close, color: greenAccent, size: 14),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 36),

                // Button Terapkan
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      controller.selectedType.value = tempType.value;
                      if (tempStart.value != null && tempEnd.value != null) {
                        controller.setDateRange(tempStart.value!, tempEnd.value!);
                      } else {
                        controller.changeMonth(tempMonth.value, tempYear.value);
                      }
                      Get.back();
                    },
                    child: const Text(
                      'Terapkan Filter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.grey[800],
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildImpeccableDropdown<T>({
    required Rx<T> value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required Function(T) onChanged,
  }) {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value.value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[500]),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                labelBuilder(item),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryDark,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    ));
  }

  Widget _buildImpeccableTypeChip(String label, String type, RxString selectedType) {
    return Obx(() {
      final isActive = selectedType.value == type;
      return GestureDetector(
        onTap: () => selectedType.value = type,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? primaryDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? primaryDark : borderColor,
              width: 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: primaryDark.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey[700],
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      );
    });
  }

  String _monthName(int monthNum) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[monthNum - 1];
  }
}
