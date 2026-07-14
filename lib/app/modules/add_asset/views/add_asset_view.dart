import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/add_asset_controller.dart';
import '../../../utils/rupiah_formatter.dart';
import '../../../utils/asset_helper.dart';
import '../../../data/providers/api_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AddAssetView extends GetView<AddAssetController> {
  const AddAssetView({Key? key}) : super(key: key);

  final Color primaryDark = const Color(0xFF0D2B33);
  final Color greenAccent = const Color(0xFF1F9975);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryDark),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Text(
          controller.isEdit.value ? 'Edit Aset' : 'Tambah Aset',
          style: TextStyle(
            color: primaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        )),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload Foto Utama
            Text('Foto Utama Aset (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, color: primaryDark)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showImageSourceDialog(context, isMain: true),
              child: Obx(() {
                final localPath = controller.mainPhotoPath.value;
                final existingUrl = controller.existingMainPhotoUrl.value;

                return Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E5E9)),
                  ),
                  child: localPath.isNotEmpty
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(File(localPath), fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => controller.removeMainPhoto(),
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.black.withOpacity(0.5),
                                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        )
                      : existingUrl.isNotEmpty
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: ApiProvider.getImageUrl(existingUrl), 
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[200],
                                      child: const Center(child: CircularProgressIndicator()),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.broken_image, color: Colors.grey),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => controller.removeMainPhoto(),
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.black.withOpacity(0.5),
                                      child: const Icon(Icons.close, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt_outlined, size: 36, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text('Tambah Foto Utama', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                              ],
                            ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Nama Aset
            Text('Nama Aset', style: TextStyle(fontWeight: FontWeight.bold, color: primaryDark)),
            const SizedBox(height: 8),
            TextField(
              controller: controller.nameController,
              decoration: InputDecoration(
                hintText: 'Contoh: Honda Brio 2020',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5E9)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5E9)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Harga / Nilai Aset — Dynamic: Rupiah or Gram mode
            Obx(() {
              // Force reactivity on category change
              final _ = controller.selectedCategoryId.value;
              final isGold = controller.isGoldCategory;

              if (isGold) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Berat Emas (Gram)', style: TextStyle(fontWeight: FontWeight.bold, color: primaryDark)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.gramController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => controller.update(),
                      decoration: InputDecoration(
                        hintText: 'Contoh: 5.0',
                        prefixIcon: Icon(Icons.hexagon_outlined, color: const Color(0xFFD4A843), size: 20),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE0E5E9)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE0E5E9)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: const Color(0xFF004D40), width: 1.5),
                        ),
                      ),
                    ),
                    // Live price estimation
                    Builder(builder: (_) {
                      final estimated = controller.estimatedGoldValue;
                      if (estimated > 0) {
                        final formatted = estimated.toStringAsFixed(0).replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]}.',
                        );
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF004D40).withOpacity(0.06),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF004D40)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '\u2248 Rp $formatted (estimasi harga beli hari ini)',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF004D40),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    const SizedBox(height: 16),
                    Text('Total Harga Beli / Modal Awal (Rp) (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, color: primaryDark)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.priceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [RupiahInputFormatter()],
                      decoration: InputDecoration(
                        hintText: 'Contoh: 7.000.000',
                        helperText: 'Kosongkan jika ingin auto-kalkulasi menggunakan harga beli emas hari ini.',
                        helperMaxLines: 2,
                        helperStyle: TextStyle(color: Colors.grey[600], fontSize: 10),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE0E5E9)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE0E5E9)),
                        ),
                      ),
                    ),
                  ],
                );
              }

              // Default: Rupiah input
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nilai Aset (Rp)', style: TextStyle(fontWeight: FontWeight.bold, color: primaryDark)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [RupiahInputFormatter()],
                    decoration: InputDecoration(
                      hintText: 'Contoh: 120.000.000',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E5E9)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E5E9)),
                      ),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 16),

            // Kategori
            Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold, color: primaryDark)),
            const SizedBox(height: 8),
            Obx(() {
              if (controller.isLoadingCategories.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E5E9)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: controller.selectedCategoryId.value,
                    hint: const Text('Pilih Kategori'),
                    items: controller.categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat.id,
                        child: Text(translateAssetCategory(cat.name)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) controller.selectedCategoryId.value = val;
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            // Kepemilikan
            Text('Kepemilikan', style: TextStyle(fontWeight: FontWeight.bold, color: primaryDark)),
            const SizedBox(height: 8),
            Obx(() => Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Pribadi', style: TextStyle(fontSize: 14)),
                    value: 'PERSONAL',
                    groupValue: controller.selectedOwnership.value,
                    onChanged: (val) {
                      if (val != null) controller.selectedOwnership.value = val;
                    },
                    contentPadding: EdgeInsets.zero,
                    activeColor: greenAccent,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Bersama', style: TextStyle(fontSize: 14)),
                    value: 'JOINT',
                    groupValue: controller.selectedOwnership.value,
                    onChanged: (val) {
                      if (val != null) controller.selectedOwnership.value = val;
                    },
                    contentPadding: EdgeInsets.zero,
                    activeColor: greenAccent,
                  ),
                ),
              ],
            )),
            const SizedBox(height: 16),
            
            // Tanggal Perolehan
             Text('Tanggal Pembelian (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, color: primaryDark)),
            const SizedBox(height: 8),
            TextField(
              controller: controller.dateController,
              readOnly: true,
              onTap: () => controller.pickDate(context),
              decoration: InputDecoration(
                hintText: 'Pilih Tanggal',
                filled: true,
                fillColor: Colors.white,
                suffixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5E9)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5E9)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Catatan
            Text('Catatan (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, color: primaryDark)),
            const SizedBox(height: 8),
            TextField(
              controller: controller.notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Contoh: Pembelian lunas, garansi s/d 2028',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5E9)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E5E9)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Dokumen / Bukti Lainnya
            Text('Dokumen / Bukti Lainnya (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, color: primaryDark)),
            const SizedBox(height: 8),
            Obx(() {
              final localDocs = controller.localDocPaths;
              final existingDocs = controller.existingDocUrls;
              final totalCount = localDocs.length + existingDocs.length;

              return Column(
                children: [
                  if (totalCount > 0)
                    Container(
                      height: 80,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: existingDocs.length + localDocs.length,
                        itemBuilder: (context, index) {
                          if (index < existingDocs.length) {
                            final idx = index;
                            final url = existingDocs[idx];
                            return Stack(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFE0E5E9)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: ApiProvider.getImageUrl(url), 
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[200],
                                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.broken_image, color: Colors.grey, size: 24),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 10,
                                  child: GestureDetector(
                                    onTap: () => controller.removeExistingDoc(idx),
                                    child: CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.black.withOpacity(0.6),
                                      child: const Icon(Icons.close, size: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            final idx = index - existingDocs.length;
                            final path = localDocs[idx];
                            return Stack(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFE0E5E9)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(File(path), fit: BoxFit.cover),
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 10,
                                  child: GestureDetector(
                                    onTap: () => controller.removeLocalDoc(idx),
                                    child: CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.black.withOpacity(0.6),
                                      child: const Icon(Icons.close, size: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  // Add document button
                  OutlinedButton.icon(
                    onPressed: () => _showImageSourceDialog(context, isMain: false),
                    icon: Icon(Icons.add_photo_alternate_outlined, color: greenAccent),
                    label: Text('Tambah Dokumen / Nota', style: TextStyle(color: greenAccent, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: greenAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(double.infinity, 44),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 40),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: controller.isLoading.value ? null : controller.submit,
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        controller.isEdit.value ? 'SIMPAN PERUBAHAN' : 'TAMBAH ASET',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
              )),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context, {required bool isMain}) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isMain ? 'Pilih Foto Utama' : 'Pilih Dokumen Tambahan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryDark),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.camera_alt, color: greenAccent),
              title: const Text('Ambil dari Kamera', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Get.back();
                if (isMain) {
                  controller.pickMainPhoto(ImageSource.camera);
                } else {
                  controller.pickDocPhoto(ImageSource.camera);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: greenAccent),
              title: const Text('Ambil dari Galeri', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Get.back();
                if (isMain) {
                  controller.pickMainPhoto(ImageSource.gallery);
                } else {
                  controller.pickDocPhoto(ImageSource.gallery);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
