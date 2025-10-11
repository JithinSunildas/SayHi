import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/photo.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class GalleryController {
  final String serverUrl;
  List<Photo> _photos = [];

  GalleryController(this.serverUrl);

  List<Photo> get photos => _photos;

  Future<bool> fetchPhotos() async {
    try {
      final response = await http.get(
        Uri.parse('$serverUrl/api/photos'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _photos = data.map((json) => Photo.fromJson(json)).toList();
        return true;
      }
      return false;
    } catch (e) {
      print('Error fetching photos: $e');
      return false;
    }
  }

  Future<bool> uploadPhoto(String filePath, String fileName) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$serverUrl/api/photos/upload'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send();
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error uploading photo: $e');
      return false;
    }
  }

  Future<String?> downloadPhoto(Photo photo) async {
    try {
      // Use the download URL which has proper content-disposition header
      String downloadUrl = photo.url.replaceAll('/view', '/download');
      final response = await http.get(Uri.parse(downloadUrl));

      if (response.statusCode == 200) {
        // Get the downloads directory
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/${photo.name}';

        // Write the file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        return filePath;
      }
      return null;
    } catch (e) {
      print('Error downloading photo: $e');
      return null;
    }
  }
}
