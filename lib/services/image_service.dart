import 'dart:io';
import 'dart:typed_data';
import 'dart:developer' as developer;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      developer.log('Error picking image: $e', name: 'ImageService');
      return null;
    }
  }

  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      developer.log('Error taking photo: $e', name: 'ImageService');
      return null;
    }
  }

  static Future<Uint8List> compressImage(File imageFile,
      {int maxSizeKB = 200}) async {
    try {
      final bytes = await imageFile.readAsBytes();

      if (bytes.length <= maxSizeKB * 1024) {
        return bytes;
      }

      final img.Image? decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) {
        return bytes;
      }

      int quality = 85;
      Uint8List? compressedBytes;
      img.Image image = decodedImage;

      while (quality > 20) {
        if (image.width > 800 || image.height > 800) {
          final resized = img.copyResize(
            image,
            width: image.width > image.height ? 800 : null,
            height: image.height > image.width ? 800 : null,
          );
          image = resized;
        }

        compressedBytes = Uint8List.fromList(
          img.encodeJpg(image, quality: quality),
        );

        if (compressedBytes.length <= maxSizeKB * 1024) {
          developer.log(
            'Compressed image from ${bytes.length ~/ 1024}KB to ${compressedBytes.length ~/ 1024}KB',
            name: 'ImageService',
          );
          return compressedBytes;
        }

        quality -= 10;
      }

      return compressedBytes ?? bytes;
    } catch (e) {
      developer.log('Error compressing image: $e', name: 'ImageService');
      return await imageFile.readAsBytes();
    }
  }

  static Future<String?> uploadProfileImage(
    String userId,
    File imageFile,
  ) async {
    try {
      final compressedBytes = await compressImage(imageFile);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = '$userId/profile_$timestamp.jpg';

      developer.log('Uploading to filename: $filename', name: 'ImageService');
      developer.log('Compressed size: ${compressedBytes.length ~/ 1024}KB',
          name: 'ImageService');

      final uploadedPath = await _supabase.storage.from('avatars').uploadBinary(
            filename,
            compressedBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      developer.log('Upload returned path: $uploadedPath',
          name: 'ImageService');

      final publicUrl =
          _supabase.storage.from('avatars').getPublicUrl(filename);

      developer.log('Generated public URL: $publicUrl', name: 'ImageService');

      try {
        final files =
            await _supabase.storage.from('avatars').list(path: userId);
        developer.log(
            'Files in user folder: ${files.map((f) => f.name).join(", ")}',
            name: 'ImageService');
      } catch (listError) {
        developer.log('Could not list files: $listError', name: 'ImageService');
      }

      return publicUrl;
    } catch (e) {
      developer.log('Error uploading image: $e', name: 'ImageService');
      return null;
    }
  }

  static Future<void> deleteProfileImage(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final path = uri.pathSegments
          .sublist(uri.pathSegments.indexOf('avatars') + 1)
          .join('/');

      await _supabase.storage.from('avatars').remove([path]);
      developer.log('Deleted old profile image: $path', name: 'ImageService');
    } catch (e) {
      developer.log('Error deleting image: $e', name: 'ImageService');
    }
  }
}
