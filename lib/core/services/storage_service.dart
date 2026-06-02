import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StorageService {
  StorageService._();

  static final CloudinaryPublic _cloudinary = CloudinaryPublic(
    dotenv.env['CLOUDINARY_CLOUD_NAME']!,
    dotenv.env['CLOUDINARY_UPLOAD_PRESET']!,
  );


  static Future<String> uploadImage({
    required File file,
    required String publicId,
    required String folder,
  }) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          publicId: publicId,
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      debugPrint("Error uploading image: ${e.message}");
      debugPrint("Request: ${e.request}");
      rethrow;
    }
  }
}
