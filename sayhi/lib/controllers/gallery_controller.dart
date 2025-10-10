import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/photo.dart';

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

  Future<bool> downloadPhoto(String photoUrl, String savePath) async {
    try {
      final response = await http.get(Uri.parse(photoUrl));
      if (response.statusCode == 200) {
        // Save file logic here
        return true;
      }
      return false;
    } catch (e) {
      print('Error downloading photo: $e');
      return false;
    }
  }
}
