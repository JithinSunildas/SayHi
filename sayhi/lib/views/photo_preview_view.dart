import 'package:flutter/material.dart';
import '../models/photo.dart';

class PhotoPreviewView extends StatelessWidget {
  final Photo photo;

  const PhotoPreviewView({Key? key, required this.photo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(photo.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Download functionality
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Download started')));
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            photo.url,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.broken_image, size: 100);
            },
          ),
        ),
      ),
    );
  }
}
