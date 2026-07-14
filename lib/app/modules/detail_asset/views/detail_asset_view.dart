import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/detail_asset_controller.dart';
import '../../harta/models/asset_model.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/asset_helper.dart';
import '../../../data/models/gold_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DetailAssetView extends GetView<DetailAssetController> {
  const DetailAssetView({Key? key}) : super(key: key);

  final Color primaryDark = const Color(0xFF0D2B33);
  final Color bgLightGreen = const Color(0xFFE8F5EE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: Text(controller.asset.assetName, style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMainPhoto(),
            const SizedBox(height: 16),
            _buildInfoCard(),
            const SizedBox(height: 16),
            if (controller.documentUrls.isNotEmpty) ...[
              _buildDocumentSection(context),
              const SizedBox(height: 16),
            ],
            _buildNotesSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: controller.canEdit ? _buildActionButtons() : const SizedBox.shrink(),
    );
  }

  Widget _buildMainPhoto() {
    final photoUrl = controller.mainPhotoUrl;
    return Container(
      width: double.infinity,
      height: 250,
      color: Colors.white,
      child: photoUrl != null
          ? CachedNetworkImage(
              imageUrl: photoUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => _buildPlaceholder(),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_not_supported_outlined, size: 64, color: Colors.grey[300]),
        const SizedBox(height: 8),
        Text('Tidak ada foto utama', style: TextStyle(color: Colors.grey[400])),
      ],
    );
  }

  Widget _buildInfoCard() {
    final asset = controller.asset;
    final formattedPrice = 'Rp ${asset.purchasePrice.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}';
    final isPersonal = asset.ownershipType == 'PERSONAL';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow('Nama Aset', asset.assetName),
          const Divider(height: 24, color: Color(0xFFE0E5E9)),
          _buildInfoRow('Kategori', translateAssetCategory(asset.categoryName)),
          const Divider(height: 24, color: Color(0xFFE0E5E9)),
          _buildInfoRow(
            'Kepemilikan',
            isPersonal ? asset.ownerName : 'Bersama (Joint)',
            valueColor: isPersonal ? const Color(0xFF1F9975) : const Color(0xFFD97706),
          ),
          const Divider(height: 24, color: Color(0xFFE0E5E9)),
          _buildInfoRow('Harga Pembelian', formattedPrice, valueColor: primaryDark, isBold: true),
          const Divider(height: 24, color: Color(0xFFE0E5E9)),
          _buildInfoRow('Tanggal Pembelian', asset.purchaseDate != null ? DateFormat('dd MMM yyyy').format(asset.purchaseDate!) : '-'),
          if (controller.isGold) ...[
            const Divider(height: 24, color: Color(0xFFE0E5E9)),
            _buildInfoRow(
              'Berat Emas',
              '${controller.goldGram?.toStringAsFixed(2) ?? "0.00"} Gram',
              valueColor: const Color(0xFFD4A843),
              isBold: true,
            ),
            const Divider(height: 24, color: Color(0xFFE0E5E9)),
            _buildInfoRow(
              'Nilai Saat Ini (Valuasi)',
              'Rp ${controller.currentGoldValue.toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
              valueColor: primaryDark,
              isBold: true,
            ),
            const Divider(height: 24, color: Color(0xFFE0E5E9)),
            Builder(builder: (_) {
              final profitLoss = controller.profitLossAmount;
              final isProfit = profitLoss >= 0;
              final formattedProfitLoss = 'Rp ${profitLoss.abs().toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}';
              final pct = controller.profitLossPercentage.abs().toStringAsFixed(1);
              return _buildInfoRow(
                isProfit ? 'Estimasi Keuntungan' : 'Estimasi Kerugian',
                '${isProfit ? "+" : "-"}$formattedProfitLoss ($pct%)',
                valueColor: isProfit ? const Color(0xFF00C853) : const Color(0xFFFF1744),
                isBold: true,
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14,
              color: valueColor ?? primaryDark,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dokumen / Bukti Lainnya', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryDark)),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.documentUrls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final url = controller.documentUrls[index];
                return GestureDetector(
                  onTap: () => _showImageViewer(context, url),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 100,
                      color: Colors.grey[200],
                      child: CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showImageViewer(BuildContext context, String url) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                errorWidget: (context, url, error) => const Center(child: Text('Gagal memuat gambar', style: TextStyle(color: Colors.white))),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    final rawNotes = controller.asset.notes;
    final notes = GoldGramHelper.removeGram(rawNotes);
    final hasNotes = notes.trim().isNotEmpty;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Catatan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryDark)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              hasNotes ? notes : 'Belum ada catatan untuk aset ini.',
              style: TextStyle(
                color: hasNotes ? Colors.white : Colors.grey[400],
                fontStyle: hasNotes ? FontStyle.normal : FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // Hapus Aset
                  Get.defaultDialog(
                    title: 'Hapus Aset',
                    middleText: 'Apakah Anda yakin ingin menghapus aset ini?',
                    textCancel: 'Batal',
                    textConfirm: 'Hapus',
                    confirmTextColor: Colors.white,
                    buttonColor: Colors.red,
                    onConfirm: () {
                      Get.back();
                      controller.deleteAsset();
                    },
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed(Routes.ADD_ASSET, arguments: controller.asset.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Edit Aset', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
