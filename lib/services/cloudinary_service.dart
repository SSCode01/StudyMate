import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudService {
  static final cloudinary = CloudinaryPublic(
    'dtr5fzqji',
    'Studymate',
    cache: false,
  );

  static Future<String?> uploadFile(File file, String fileType) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: fileType == "pdf"
              ? CloudinaryResourceType.Raw
              : CloudinaryResourceType.Image,
        ),
      );

      return response.secureUrl;
    } catch (e) {
      print("Cloudinary upload error: $e");
      return null;
    }
  }
}
