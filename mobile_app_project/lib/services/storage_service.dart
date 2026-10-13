import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

/// Wraps Firebase Storage uploads for Chord Nerd. Currently just avatars,
/// stored at avatars/{uid}.jpg — one file per user, so a new upload
/// simply overwrites the last one rather than piling up old photos.
///
/// Uploads raw bytes (putData) rather than a dart:io File (putFile) —
/// dart:io's File/Platform APIs don't exist on Flutter Web, so putFile
/// throws "Unsupported operation: Platform._operatingSystem" there.
/// putData works identically on web, Android, iOS, and desktop.
class StorageService {
  StorageService._();

  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads [bytes] as the signed-in user's avatar and returns its
  /// public download URL, ready to save on the profile via
  /// DatabaseService.updateAvatarUrl.
  static Future<String> uploadAvatar({
    required String uid,
    required Uint8List bytes,
  }) async {
    final ref = _storage.ref('avatars/$uid.jpg');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }
}
