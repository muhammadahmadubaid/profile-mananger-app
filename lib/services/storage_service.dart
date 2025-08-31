import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload profile image
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      final String fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('profile_images/$fileName');
      
      final UploadTask uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw 'Failed to upload image: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred while uploading image.';
    }
  }

  // Upload document
  Future<String> uploadDocument(File documentFile, String userId) async {
    try {
      final String extension = path.extension(documentFile.path);
      final String fileName = 'document_${userId}_${DateTime.now().millisecondsSinceEpoch}$extension';
      final Reference ref = _storage.ref().child('documents/$fileName');
      
      String? contentType;
      if (extension.toLowerCase() == '.pdf') {
        contentType = 'application/pdf';
      } else if (['.jpg', '.jpeg', '.png'].contains(extension.toLowerCase())) {
        contentType = 'image/${extension.substring(1)}';
      }

      final UploadTask uploadTask = ref.putFile(
        documentFile,
        SettableMetadata(contentType: contentType),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw 'Failed to upload document: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred while uploading document.';
    }
  }

  // Delete file by URL
  Future<void> deleteFile(String downloadUrl) async {
    try {
      final Reference ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') {
        throw 'Failed to delete file: ${e.message}';
      }
    } catch (e) {
      throw 'An unexpected error occurred while deleting file.';
    }
  }

  // Get upload progress stream
  Stream<TaskSnapshot> getUploadProgressStream(UploadTask task) {
    return task.snapshotEvents;
  }
}
