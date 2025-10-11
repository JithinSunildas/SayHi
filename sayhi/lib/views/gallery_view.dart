import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/gallery_controller.dart';
import '../models/photo.dart';
import 'package:sayhi/views/photo_preview_view.dart';

class GalleryView extends StatefulWidget {
  final String serverUrl;

  const GalleryView({Key? key, required this.serverUrl}) : super(key: key);

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  late GalleryController _galleryController;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _galleryController = GalleryController(widget.serverUrl);
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() => _isLoading = true);
    await _galleryController.fetchPhotos();
    setState(() => _isLoading = false);
  }

  Future<void> _uploadPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _isLoading = true);
      final success = await _galleryController.uploadPhoto(
        image.path,
        image.name,
      );
      if (success) {
        await _loadPhotos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo uploaded successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Upload failed')));
        }
      }
      setState(() => _isLoading = false);
    }
  }

  void _previewPhoto(Photo photo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoPreviewView(
          photo: photo,
          galleryController: _galleryController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Gallery'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadPhotos),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _galleryController.photos.isEmpty
          ? const Center(child: Text('No photos found'))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _galleryController.photos.length,
              itemBuilder: (context, index) {
                final photo = _galleryController.photos[index];
                return GestureDetector(
                  onTap: () => _previewPhoto(photo),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      photo.thumbnailUrl ?? photo.url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadPhoto,
        child: const Icon(Icons.add_photo_alternate),
      ),
    );
  }
}
