import 'dart:convert';
import 'dart:typed_data';

/// Helper pour décoder la photo depuis le backend
class ProductPhotoHelper {
  static Uint8List? decodePhoto(dynamic photoData) {
    try {
      if (photoData is String) {
        // Backend envoie base64 string
        return base64Decode(photoData);
      } else if (photoData is List) {
        // Backend envoie byte array
        return Uint8List.fromList(List<int>.from(photoData));
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
