import 'package:flutter/material.dart';
import '../controllers/gallery_controller.dart';
import '../models/photo.dart';

class PhotoPreviewView extends StatefulWidget {
  final Photo photo;
  final GalleryController galleryController;

  const PhotoPreviewView({
    Key? key,
    required this.photo,
    required this.galleryController,
  }) : super(key: key);

  @override
  State<PhotoPreviewView> createState() => _PhotoPreviewViewState();
}

class _PhotoPreviewViewState extends State<PhotoPreviewView> {
  bool _isDownloading = false;

  Future<void> _downloadPhoto() async {
    setState(() => _isDownloading = true);

    final filePath = await widget.galleryController.downloadPhoto(widget.photo);

    setState(() => _isDownloading = false);

    if (filePath != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Photo saved to: $filePath')));
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Download failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.photo.name),
        actions: [
          IconButton(
            icon: _isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.download),
            onPressed: _isDownloading ? null : _downloadPhoto,
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            widget.photo.url,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 100, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Failed to load image'),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
