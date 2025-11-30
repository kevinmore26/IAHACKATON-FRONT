// Archivo: video_review_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_thumbnail/video_thumbnail.dart'; // Para generar la miniatura
import 'package:path_provider/path_provider.dart'; // Para gestionar la miniatura temporal
import '../services/api_service.dart';
import 'package:path/path.dart' as p; // Para obtener el nombre del archivo

class VideoReviewScreen extends StatefulWidget {
  final String videoPath; // La ruta temporal local
  final String ideaId;
  final String organizationId;

  const VideoReviewScreen({
    super.key,
    required this.videoPath,
    required this.ideaId,
    required this.organizationId,
  });

  @override
  State<VideoReviewScreen> createState() => _VideoReviewScreenState();
}

class _VideoReviewScreenState extends State<VideoReviewScreen> {
  bool _isSharing = false;
  bool _isUploading = false;
  Future<String?>?
      _thumbnailFuture; // Future que contendrá la ruta de la miniatura

  @override
  void initState() {
    super.initState();
    _thumbnailFuture = _generateThumbnail(widget.videoPath);
  }

  Future<String?> _generateThumbnail(String path) async {
    final tempDir = await getTemporaryDirectory();
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: path,
      thumbnailPath: tempDir.path,
      imageFormat: ImageFormat.WEBP, // Formato ligero
      quality: 75,
    );
    return thumbnailPath;
  }

  // Si el usuario descarta, borramos el archivo temporal
  void _handleDiscard() {
    try {
      File(widget.videoPath).deleteSync();
      // Si existía miniatura, la borramos también
      _thumbnailFuture?.then((thumbPath) {
        if (thumbPath != null) File(thumbPath).deleteSync();
      });
    } catch (e) {
      print("Error al borrar archivos temporales: $e");
    }
    Navigator.pop(context); // Pop para salir de ReviewScreen
    Navigator.pop(context); // Pop para salir de MissionDetailScreen
  }

  Future<void> _handleSaveToGallery() async {
    setState(() => _isUploading = true);

    final file = File(widget.videoPath);

    // Debug local del archivo
    final exists = await file.exists();
    print("📁 Video path: ${widget.videoPath}");
    print("📁 El archivo existe? $exists");

    bool success = false;

    if (!exists) {
      print("❌ El archivo de video NO existe en esa ruta");
    } else {
      success = await ApiService.uploadGalleryItem(
        organizationId: widget.organizationId,
        file: file,
      );
    }

    if (!mounted) return;

    setState(() => _isUploading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "✅ Video subido a tu Galería Online!"
              : "❌ Error al subir a la Galería.",
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
    Navigator.pushNamed(context, '/Proyectos');
  }

  Future<void> _handleShare() async {
    setState(() => _isSharing = true);

    try {
      // Compartir el archivo MP4 temporal
      await Share.shareXFiles([XFile(widget.videoPath)],
          text: '¡Video listo para CapCut!');
    } catch (e) {
      print("Error al compartir: $e");
    } finally {
      setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title:
            const Text("Revisar Video", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: _handleDiscard,
        ),
      ),
      body: Stack(
        children: [
          // 1. Visor de Miniatura (Thumbnail)
          Center(
            child: FutureBuilder<String?>(
              future: _thumbnailFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data != null) {
                    // Miniatura lista (El flujo funcional)
                    return Image.file(
                      File(snapshot.data!),
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const Icon(Icons.videocam_off,
                          color: Colors.white, size: 80),
                    );
                  } else {
                    // Fallo al generar miniatura (el usuario solo ve texto)
                    return const Text(
                        "No hay previsualización disponible.\nEl archivo MP4 se grabó correctamente.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70));
                  }
                }
                // Cargando
                return const CircularProgressIndicator(color: Colors.white);
              },
            ),
          ),

          // 2. Botones de acción
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Botones principales (Repetir / Exportar)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _handleDiscard,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white70),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Repetir / Descartar",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSharing ? null : _handleShare,
                        icon: _isSharing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.ios_share, size: 18),
                        label: Text(
                            _isSharing
                                ? "Compartiendo..."
                                : "Exportar a CapCut",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4461F2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Botón Galería (Subida a la Nube)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isUploading ? null : _handleSaveToGallery,
                    icon: _isUploading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Color(0xFF4461F2), strokeWidth: 2))
                        : const Icon(Icons.cloud_upload_outlined,
                            color: Color(0xFF4461F2), size: 18),
                    label: Text(
                        _isUploading
                            ? "Subiendo a Nube..."
                            : "Guardar en Galería Online",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _isUploading
                                ? Colors.grey
                                : const Color(0xFF4461F2))),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF4461F2)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
