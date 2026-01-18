import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:file_picker/file_picker.dart';

class PdfService {
  /// Creates a PDF from a list of image paths and returns the PDF file path
  static Future<String?> createPdfFromImages(
    List<String> imagePaths, {
    required String documentName,
  }) async {
    if (imagePaths.isEmpty) return null;

    final pdf = pw.Document();

    for (final path in imagePaths) {
      final file = File(path);
      if (!await file.exists()) continue;

      final imageBytes = await file.readAsBytes();
      final image = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain));
          },
        ),
      );
    }

    // Save to app documents directory
    final appDir = await getApplicationDocumentsDirectory();
    final pdfDir = Directory('${appDir.path}/exported_pdfs');
    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }

    final sanitizedName = documentName.replaceAll(RegExp(r'[^\w\s-]'), '_');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final pdfPath = '${pdfDir.path}/${sanitizedName}_$timestamp.pdf';

    final pdfFile = File(pdfPath);
    await pdfFile.writeAsBytes(await pdf.save());

    return pdfPath;
  }

  /// Saves PDF to a user-selected location using file picker
  static Future<bool> savePdfToFiles(
    String pdfPath,
    String documentName,
  ) async {
    try {
      final file = File(pdfPath);
      if (!await file.exists()) return false;

      final bytes = await file.readAsBytes();
      final sanitizedName = documentName.replaceAll(RegExp(r'[^\w\s-]'), '_');

      // Use file picker to save
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save PDF to Files',
        fileName: '$sanitizedName.pdf',
        bytes: bytes,
      );

      return result != null;
    } catch (e) {
      print('Error saving PDF: $e');
      return false;
    }
  }

  /// Creates a PDF from images and saves it directly to user-selected location
  static Future<bool> exportImagesToPdf(
    List<String> imagePaths, {
    required String documentName,
  }) async {
    try {
      if (imagePaths.isEmpty) return false;

      final pdf = pw.Document();

      for (final path in imagePaths) {
        final file = File(path);
        if (!await file.exists()) continue;

        final imageBytes = await file.readAsBytes();
        final image = pw.MemoryImage(imageBytes);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(20),
            build: (context) {
              return pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain));
            },
          ),
        );
      }

      final pdfBytes = await pdf.save();
      final sanitizedName = documentName.replaceAll(RegExp(r'[^\w\s-]'), '_');

      // Use file picker to save
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Export as PDF',
        fileName: '$sanitizedName.pdf',
        bytes: Uint8List.fromList(pdfBytes),
      );

      return result != null;
    } catch (e) {
      print('Error exporting PDF: $e');
      return false;
    }
  }

  /// Print a PDF or images as PDF
  static Future<void> printImages(
    List<String> imagePaths, {
    required String documentName,
  }) async {
    if (imagePaths.isEmpty) return;

    final pdf = pw.Document();

    for (final path in imagePaths) {
      final file = File(path);
      if (!await file.exists()) continue;

      final imageBytes = await file.readAsBytes();
      final image = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (context) {
            return pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain));
          },
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: documentName,
    );
  }

  /// Share a PDF
  static Future<void> sharePdf(String pdfPath, String documentName) async {
    final file = File(pdfPath);
    if (!await file.exists()) return;

    await Printing.sharePdf(
      bytes: await file.readAsBytes(),
      filename: '$documentName.pdf',
    );
  }

  /// Pick a PDF file from device
  static Future<String?> pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        // Copy PDF to app documents directory for persistence
        final originalPath = result.files.single.path!;
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final newPath = '${appDir.path}/$fileName';

        await File(originalPath).copy(newPath);
        return newPath;
      }
      return null;
    } catch (e) {
      print('Error picking PDF: $e');
      return null;
    }
  }
}
