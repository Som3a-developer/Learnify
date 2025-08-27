import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import '../Helpers/dio_helper.dart';
import '../Helpers/hive_helper.dart';

class QRGeneratorPage extends StatefulWidget {
  const QRGeneratorPage({Key? key}) : super(key: key);

  @override
  State<QRGeneratorPage> createState() => _QRGeneratorPageState();
}

class _QRGeneratorPageState extends State<QRGeneratorPage> {
  final TextEditingController _countController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();
  bool isLoading = false;

  Future<String> getDownloadPath() async {
    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory("/storage/emulated/0/Download");
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      return directory!.path;
    } catch (e) {
      return (await getApplicationDocumentsDirectory()).path;
    }
  }

  Future<void> generateFiles(int count, int point) async {
    setState(() => isLoading = true);
    List<Map<String, dynamic>> data = [];
    try {
      final start = await HiveHelper.getQrCounter();
      final finish = start + count;

      for (int i = start; i < finish; i++) {
        await DioHelper.postData(path: "qr", body: {"qr": i});
        data.add({"qr": i});
      }
      await HiveHelper.setQrCounter(qr: finish) ;
      await exportToPDF(data, point);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ خطأ: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> exportToPDF(List<Map<String, dynamic>> data, int points) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.GridView(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                for (var row in data)
                  pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text("QR: ${row['qr']}"),
                      pw.Text("Points: $points"),
                      pw.SizedBox(height: 5),
                      pw.BarcodeWidget(
                        data: "myqr/$points/${row['qr']}",
                        barcode: pw.Barcode.qrCode(),
                        width: 100,
                        height: 100,
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      );

      final downloadPath = await getDownloadPath();
      final filePath = "$downloadPath/qr_codes.pdf";
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ PDF تم حفظه في $filePath")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ فشل حفظ PDF: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("QR Generator")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _countController,
              decoration: InputDecoration(labelText: "ادخل عدد QR"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _pointsController,
              decoration: InputDecoration(labelText: "ادخل points"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final count = int.tryParse(_countController.text) ?? 0;
                final point = int.tryParse(_pointsController.text) ?? 0;
                if (count > 0 && point > 0) {
                  generateFiles(count, point);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("❌ ادخل قيم صحيحة للـ count والـ points")),
                  );
                }
              },
              child: const Text("توليد PDF"),
            ),
          ],
        ),
      ),
    );
  }
}
