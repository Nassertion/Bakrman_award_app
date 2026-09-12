import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// A full-screen, in-app camera experience built on the official [camera]
/// package.
///
/// Returns an [XFile] via [Navigator.pop] when the user accepts the photo,
/// or [null] when the user cancels.
///
/// Usage:
/// ```dart
/// final XFile? result = await Navigator.push<XFile>(
///   context,
///   MaterialPageRoute(builder: (_) => const CameraScreen()),
/// );
/// ```
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  // ─── State ────────────────────────────────────────────────────────────────
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _selectedCameraIndex = 0;
  FlashMode _flashMode = FlashMode.auto;

  bool _isInitializing = true;
  bool _isCapturing = false;
  String? _initError;

  /// Captured photo waiting for accept/retake decision.
  XFile? _capturedFile;

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCameras();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  /// Pause / resume the preview when the app goes to background / foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      ctrl.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Re-initialise the same camera after resume.
      _initCamera(_cameras[_selectedCameraIndex]);
    }
  }

  // ─── Init ─────────────────────────────────────────────────────────────────
  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _initError = 'لم يتم العثور على كاميرا في هذا الجهاز';
            _isInitializing = false;
          });
        }
        return;
      }
      // Prefer back camera as the default.
      _selectedCameraIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      if (_selectedCameraIndex == -1) _selectedCameraIndex = 0;

      await _initCamera(_cameras[_selectedCameraIndex]);
    } on CameraException catch (e) {
      if (mounted) {
        setState(() {
          _initError = _formatCameraError(e);
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initError = 'حدث خطأ غير متوقع أثناء تهيئة الكاميرا';
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _initCamera(CameraDescription camera) async {
    // Dispose the previous controller before creating a new one.
    final old = _controller;
    if (old != null) {
      await old.dispose();
    }

    final ctrl = CameraController(
      camera,
      // High resolution to support max 1920×1920 resizing later.
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _controller = ctrl;

    try {
      await ctrl.initialize();
      // Apply the current flash mode after init.
      await ctrl.setFlashMode(_flashMode);
    } on CameraException catch (e) {
      if (mounted) {
        setState(() {
          _initError = _formatCameraError(e);
          _isInitializing = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isInitializing = false;
        _initError = null;
      });
    }
  }

  // ─── Camera Actions ───────────────────────────────────────────────────────
  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    setState(() => _isInitializing = true);
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _initCamera(_cameras[_selectedCameraIndex]);
  }

  Future<void> _cycleFlash() async {
    final next = _nextFlashMode(_flashMode);
    setState(() => _flashMode = next);
    try {
      await _controller?.setFlashMode(next);
    } catch (_) {
      // Some devices don't support flash; ignore silently.
    }
  }

  FlashMode _nextFlashMode(FlashMode current) {
    switch (current) {
      case FlashMode.auto:
        return FlashMode.always;
      case FlashMode.always:
        return FlashMode.off;
      case FlashMode.off:
        return FlashMode.auto;
      case FlashMode.torch:
        return FlashMode.auto;
    }
  }

  Future<void> _capturePhoto() async {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized || _isCapturing) return;

    setState(() => _isCapturing = true);

    // Brief haptic feedback.
    HapticFeedback.lightImpact();

    try {
      final XFile file = await ctrl.takePicture();
      if (mounted) {
        setState(() {
          _capturedFile = file;
          _isCapturing = false;
        });
      }
    } on CameraException catch (e) {
      debugPrint('CameraException during capture: $e');
      if (mounted) {
        setState(() => _isCapturing = false);
        _showError(_formatCameraError(e));
      }
    } catch (e) {
      debugPrint('Unexpected error during capture: $e');
      if (mounted) {
        setState(() => _isCapturing = false);
        _showError('تعذر التقاط الصورة');
      }
    }
  }

  void _retakePhoto() {
    setState(() => _capturedFile = null);
  }

  void _acceptPhoto() {
    Navigator.of(context).pop(_capturedFile);
  }

  void _cancel() {
    Navigator.of(context).pop(null);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  String _formatCameraError(CameraException e) {
    switch (e.code) {
      case 'CameraAccessDenied':
      case 'cameraPermission':
        return 'لم يتم منح إذن الكاميرا. يرجى السماح بالوصول في الإعدادات.';
      case 'AudioAccessDenied':
        return 'لم يتم منح إذن الصوت.';
      default:
        return 'خطأ في الكاميرا: ${e.description ?? e.code}';
    }
  }

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

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _capturedFile != null
          ? _buildPreviewPage()
          : _buildCameraPage(),
    );
  }

  // ── Camera live-preview page ──────────────────────────────────────────────
  Widget _buildCameraPage() {
    return SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Live preview or loading/error state.
          if (_isInitializing)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          else if (_initError != null)
            _buildErrorState()
          else
            _buildCameraPreview(),

          // Top bar (cancel + flash + flip).
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(),
          ),

          // Bottom bar (shutter).
          if (!_isInitializing && _initError == null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Fill the available space while maintaining camera aspect ratio.
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxWidth * ctrl.value.aspectRatio,
                child: CameraPreview(ctrl),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xAA000000), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _cancel,
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            tooltip: 'إلغاء',
          ),
          const Spacer(),
          // Flash toggle
          if (!_isInitializing && _initError == null)
            IconButton(
              onPressed: _cycleFlash,
              icon: Icon(
                _flashIcon(_flashMode),
                color: Colors.white,
                size: 26,
              ),
              tooltip: 'تبديل الفلاش',
            ),
          // Camera flip
          if (_cameras.length > 1 && !_isInitializing && _initError == null)
            IconButton(
              onPressed: _switchCamera,
              icon: const Icon(
                Icons.flip_camera_ios_outlined,
                color: Colors.white,
                size: 26,
              ),
              tooltip: 'تبديل الكاميرا',
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xAA000000), Colors.transparent],
        ),
      ),
      child: Center(
        child: _buildShutterButton(),
      ),
    );
  }

  Widget _buildShutterButton() {
    return GestureDetector(
      onTap: _capturePhoto,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: _isCapturing ? 62 : 70,
        height: _isCapturing ? 62 : 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isCapturing ? Colors.grey[300] : Colors.white,
          border: Border.all(color: Colors.white38, width: 4),
          boxShadow: const [
            BoxShadow(color: Colors.black38, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: _isCapturing
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black54,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography_outlined,
                color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            Text(
              _initError ?? 'خطأ غير معروف',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
              onPressed: () {
                setState(() {
                  _isInitializing = true;
                  _initError = null;
                });
                _initCameras();
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _flashIcon(FlashMode mode) {
    switch (mode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.torch:
        return Icons.highlight;
    }
  }

  // ── Photo preview / review page ───────────────────────────────────────────
  Widget _buildPreviewPage() {
    final file = _capturedFile!;

    return SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen photo preview.
          Image.file(
            File(file.path),
            fit: BoxFit.contain,
          ),
          // Top gradient overlay + label.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xCC000000), Colors.transparent],
                ),
              ),
              child: const Text(
                'معاينة الصورة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Bottom action buttons.
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xCC000000), Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Retake
                  _buildActionButton(
                    icon: Icons.refresh_rounded,
                    label: 'إعادة التصوير',
                    onTap: _retakePhoto,
                    color: Colors.white,
                    background: Colors.black45,
                  ),
                  // Use photo
                  _buildActionButton(
                    icon: Icons.check_rounded,
                    label: 'استخدام الصورة',
                    onTap: _acceptPhoto,
                    color: Colors.white,
                    background: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    required Color background,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 8),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
