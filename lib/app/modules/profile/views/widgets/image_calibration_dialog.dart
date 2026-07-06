import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImageCalibrationDialog extends StatefulWidget {
  final Uint8List imageBytes;
  final GlobalKey cropperKey;
  final VoidCallback onApply;
  final RxBool isLoading;

  const ImageCalibrationDialog({
    Key? key,
    required this.imageBytes,
    required this.cropperKey,
    required this.onApply,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<ImageCalibrationDialog> createState() => _ImageCalibrationDialogState();
}

class _ImageCalibrationDialogState extends State<ImageCalibrationDialog> {
  double _aspectRatio = 1.0;
  bool _dimensionsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadImageDimensions();
  }

  void _loadImageDimensions() {
    ui.decodeImageFromList(widget.imageBytes, (ui.Image img) {
      if (mounted) {
        setState(() {
          _aspectRatio = img.width / img.height;
          _dimensionsLoaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0D2B33),
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Kalibrasi Foto',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Geser dan cubit untuk menyesuaikan foto dalam lingkaran. Pastikan wajah berada di tengah.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 300,
              height: 300,
              child: Stack(
                children: [
                  // Latar belakang putih & InteractiveViewer (yang akan dicapture)
                  RepaintBoundary(
                    key: widget.cropperKey,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: InteractiveViewer(
                        panEnabled: true,
                        minScale: 1.0,
                        maxScale: 5.0,
                        boundaryMargin: EdgeInsets.zero,
                        child: _dimensionsLoaded
                            ? SizedBox(
                                width: _aspectRatio > 1.0 ? 300 * _aspectRatio : 300,
                                height: _aspectRatio > 1.0 ? 300 : 300 / _aspectRatio,
                                child: Image.memory(
                                  widget.imageBytes,
                                  fit: BoxFit.fill,
                                ),
                              )
                            : const SizedBox(
                                width: 300,
                                height: 300,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF1F9975),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  // Garis tepi lingkaran
                  IgnorePointer(
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF1F9975), width: 3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => ElevatedButton(
                    onPressed: widget.isLoading.value ? null : widget.onApply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F9975),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: widget.isLoading.value 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Terapkan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
