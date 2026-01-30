import 'dart:typed_data';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';

class CloudService {
  static final cloudinary = CloudinaryPublic(
    'dtr5fzqji',
    'Studymate',
    cache: false,
  );

  static Future<String?> upload(dynamic file, String fileType) async {
    try {
      if (kIsWeb) {
        return _uploadFromBytes(file as Uint8List, fileType);
      } else {
        return _uploadFromFile(file, fileType);
      }
    } catch (e) {
      debugPrint("Cloudinary upload error: $e");
      return null;
    }
  }

  // 📱 Android / iOS
  static Future<String?> _uploadFromFile(dynamic file, String fileType) async {
    final response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        file.path,
        resourceType: fileType == 'pdf'
            ? CloudinaryResourceType.Raw
            : CloudinaryResourceType.Image,
      ),
    );
    return response.secureUrl;
  }

  // 🌐 Web
  static Future<String?> _uploadFromBytes(
      Uint8List bytes,
      String fileType,
      ) async {
    final response = await cloudinary.uploadFile(
      CloudinaryFile.fromBytesData(
        bytes,
        identifier: "upload_${DateTime.now().millisecondsSinceEpoch}",
        resourceType: fileType == 'pdf'
            ? CloudinaryResourceType.Raw
            : CloudinaryResourceType.Image,
      ),
    );
    return response.secureUrl;
  }
}
