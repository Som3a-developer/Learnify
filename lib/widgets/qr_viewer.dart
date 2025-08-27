import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learnify/Helpers/dio_helper.dart';
import 'package:learnify/Helpers/hive_helper.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/foundation.dart';

class QrViewer extends StatefulWidget {
  const QrViewer({
    super.key,
    required this.points,
    required this.courseId,
    required this.userId,
    required this.onResult,
  });

  final int points;
  final int courseId;
  final String userId;
  final void Function(bool success) onResult;

  @override
  State<QrViewer> createState() => _QrViewerState();
}

class _QrViewerState extends State<QrViewer> {
  String? qrCode;
  bool _isProcessing = false;
  bool _completed = false; // يمنع تكرار النتيجة
  late final MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR')),
      body: _buildScannerView(),
    );
  }

  Widget _buildScannerView() {
    return Stack(
      children: [
        MobileScanner(
          fit: BoxFit.cover,
          controller: _controller,
          onDetect: _handleQrDetection,
        ),
        if (qrCode != null)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black54,
              child: Text(
                'Scanned: $qrCode',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        if (_isProcessing)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Future<void> _handleQrDetection(BarcodeCapture capture) async {
    if (_completed || _isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final raw = barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;

    setState(() {
      qrCode = raw;
      _isProcessing = true;
    });

    // أوقف الماسح لتفادي تعدد الاستدعاءات
    await _controller.stop();

    try {
      await _processQrCode(raw);
    } catch (e, s) {
      debugPrint('Process error: $e\n$s');
      _showErrorAndReturn('An error occurred while processing QR code');
    } finally {
      if (mounted && !_completed) {
        setState(() => _isProcessing = false);
        // لو العملية ما اكتملتش بنجاح شغل الماسح تاني
        await _controller.start();
      }
    }
  }

  Future<void> _processQrCode(String rawValue) async {
    final sanitized = rawValue.trim();
    final parts = sanitized.split('/');

    if (parts.length < 3 || parts[0].toLowerCase() != 'myqr') {
      _showErrorAndReturn('Invalid QR code');
      return;
    }

    final pointsInQr = int.tryParse(parts[1]);
    if (pointsInQr == null || pointsInQr != widget.points) {
      _showErrorAndReturn("This QR doesn't match the required points");
      return;
    }

    final qrId = int.tryParse(parts[2]);
    if (qrId == null) {
      _showErrorAndReturn('Invalid QR code ID');
      return;
    }

    try {
      final response = await DioHelper.postData(
        path: 'rpc/enroll_with_qr',
        body: {
          'p_qr_code': qrId,
          'p_user_id': widget.userId,
          'p_course_id': widget.courseId,
        },
      );

      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');

      final status = response.statusCode ?? 0;
      final isSuccess = status >= 200 && status < 300;

      if (isSuccess) {
        await HiveHelper.setEnrolledCourses(enrolledcourse: widget.courseId);

        if (!mounted) return;
        _completed = true; // قفل أي محاولة تانية

        Get.closeAllSnackbars();
        Get.snackbar(
          'Success',
          'Course enrolled successfully!',
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        );

        // رجّع النتيجة مرة واحدة وبعدين اقفل
        widget.onResult(true);
        if (mounted) Navigator.of(context).pop();
      } else {
        _showErrorAndReturn('Failed to enroll in course');
      }
    } catch (e, s) {
      debugPrint('Enroll error: $e\n$s');
      _showErrorAndReturn(_extractDioMessage(e));
    }
  }

  String _extractDioMessage(dynamic e) {
    // يدعم Dio 4 و Dio 5
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] is String) return data['message'] as String;
      if (data is Map && data['error_description'] is String) {
        return data['error_description'] as String;
      }
      if (data is String && data.trim().isNotEmpty) return data.trim();
      return e.message ?? 'Server error';
    }
    if (e is DioError) {
      final data = e.response?.data;
      if (data is Map && data['message'] is String) return data['message'] as String;
      if (data is String && data.trim().isNotEmpty) return data.trim();
      return e.message ?? 'Server error';
    }
    return 'An error occurred';
  }

  void _showErrorAndReturn(String message) {
    if (!mounted || _completed) return;

    Get.closeAllSnackbars();
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 2),
    );

    // رجّع false مرة واحدة فقط
    widget.onResult(false);
    if (mounted) Navigator.of(context).pop();
    _completed = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
