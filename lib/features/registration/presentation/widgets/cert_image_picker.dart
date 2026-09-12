import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/camera_screen.dart';

/// Widget that lets the user pick or capture a certificate image.
///
/// * On **Web**: only shows the file-picker option (no camera).
/// * On **Android / iOS**: shows a bottom-sheet with two choices —
///   - *Gallery* → uses [ImagePicker] (unchanged, reliable).
///   - *Camera*  → opens the in-app [CameraScreen] (avoids OEM system-camera
///     activity crashes on MIUI / MediaTek devices).
///
/// The captured image is kept as an [XFile] and is NOT loaded into memory
/// eagerly; bytes are only read at upload time.
class CertImagePicker extends StatefulWidget {
  final String label;
  final String subLabel;
  final XFile? selectedFile;
  final ValueChanged<XFile?> onImageSelected;
  final String? errorText;
  final bool isRequired;

  const CertImagePicker({
    super.key,
    required this.label,
    required this.subLabel,
    required this.selectedFile,
    required this.onImageSelected,
    this.errorText,
    this.isRequired = false,
  });

  @override
  State<CertImagePicker> createState() => _CertImagePickerState();
}

class _CertImagePickerState extends State<CertImagePicker> {
  final ImagePicker _picker = ImagePicker();

  // ─── Gallery (image_picker) ───────────────────────────────────────────────
  Future<void> _pickFromGallery() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (picked != null) {
        widget.onImageSelected(picked);
      }
    } catch (e) {
      debugPrint('Gallery picker error: $e');
      _showError('تعذر اختيار صورة من المعرض: $e');
    }
  }

  // ─── In-app Camera (camera package) ──────────────────────────────────────
  Future<void> _openCameraScreen() async {
    // Verify at least one camera is available before pushing the route.
    List<CameraDescription> cameras = [];
    try {
      cameras = await availableCameras();
    } catch (e) {
      debugPrint('availableCameras() error: $e');
    }

    if (cameras.isEmpty) {
      _showError('لم يتم العثور على كاميرا في هذا الجهاز');
      return;
    }

    if (!mounted) return;

    final XFile? result = await Navigator.of(context).push<XFile>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const CameraScreen(),
      ),
    );

    if (result != null) {
      widget.onImageSelected(result);
    }
  }

  // ─── Source chooser ───────────────────────────────────────────────────────
  void _showSourceDialog() {
    if (kIsWeb) {
      // Web: only gallery / file picker is supported.
      _pickFromGallery();
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryContainer,
                  child: Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.primary,
                  ),
                ),
                title: const Text('اختيار من المعرض'),
                subtitle: const Text('JPG, PNG, WEBP'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryContainer,
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.primary,
                  ),
                ),
                title: const Text('تصوير بالكاميرا'),
                subtitle: const Text('التقط صورة الشهادة مباشرة'),
                onTap: () {
                  Navigator.pop(ctx);
                  _openCameraScreen();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Error helper ─────────────────────────────────────────────────────────
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── Image preview ────────────────────────────────────────────────────────
  Widget _buildPreviewImage(XFile file) {
    if (kIsWeb) {
      return Image.network(
        file.path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, e) => _buildFallbackIcon(),
      );
    }
    return Image.file(
      File(file.path),
      fit: BoxFit.cover,
      errorBuilder: (_, __, e) => _buildFallbackIcon(),
    );
  }

  Widget _buildFallbackIcon() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_drive_file_outlined,
              size: 36, color: AppColors.textMuted),
          SizedBox(height: 4),
          Text(
            'تم اختيار الصورة',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final hasImage = widget.selectedFile != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Text(
              widget.label,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            if (widget.isRequired)
              const Text(
                ' *',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 6),

        // Tap area
        InkWell(
          onTap: _showSourceDialog,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.errorText != null
                    ? AppColors.error
                    : hasImage
                        ? AppColors.primary
                        : AppColors.border,
                width: hasImage ? 2 : 1,
              ),
            ),
            child: hasImage
                ? Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 160,
                          width: double.infinity,
                          color: AppColors.surfaceVariant,
                          child: _buildPreviewImage(widget.selectedFile!),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('تغيير الصورة'),
                            onPressed: _showSourceDialog,
                          ),
                          const SizedBox(width: 12),
                          TextButton.icon(
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.error, size: 18),
                            label: const Text('حذف',
                                style: TextStyle(color: AppColors.error)),
                            onPressed: () => widget.onImageSelected(null),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cloud_upload_outlined,
                          size: 32,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'انقر لرفع ${widget.label}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subLabel,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ),

        // Error text
        if (widget.errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: const TextStyle(color: AppColors.error, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
