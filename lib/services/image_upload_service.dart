import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

/// Uploads an image to Cloudinary and returns its secure URL.
class ImageUploadService {
  Future<String> upload(File file) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = AppConstants.cloudinaryPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response =
        await request.send().timeout(const Duration(seconds: 30));
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Image upload failed (${response.statusCode}): $body');
    }
    final url = jsonDecode(body)['secure_url'] as String?;
    if (url == null) throw Exception('Upload response had no URL');
    return url;
  }
}
