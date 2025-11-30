import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:flutter/material.dart';

class _VideoThumbnailTile extends StatelessWidget {
  final String videoUrl;

  const _VideoThumbnailTile({
    Key? key,
    required this.videoUrl,
  }) : super(key: key);

  Future<Uint8List?> _generateThumbnail() {
    return VideoThumbnail.thumbnailData(
      video: videoUrl,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 512, // tamaño razonable
      quality: 75,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _generateThumbnail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        if (!snapshot.hasData) {
          // fallback si falla generar thumbnail
          return _buildPlaceholder();
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
              ),
            ),
            // Overlay para indicar que es video
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                size: 40,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black12,
      ),
      child: const Center(
        child: Icon(Icons.videocam, size: 32),
      ),
    );
  }
}
