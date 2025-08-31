import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:profile_manager_app/models/profile_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _profilesCollection = 'profiles';

  // Create or update profile
  Future<void> saveProfile(ProfileModel profile) async {
    try {
      await _firestore
          .collection(_profilesCollection)
          .doc(profile.id)
          .set(profile.toMap(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw 'Failed to save profile: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred while saving profile.';
    }
  }

  // Get profile by user ID
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection(_profilesCollection)
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        return ProfileModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } on FirebaseException catch (e) {
      throw 'Failed to fetch profile: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred while fetching profile.';
    }
  }

  // Update profile
  Future<void> updateProfile(ProfileModel profile) async {
    try {
      await _firestore
          .collection(_profilesCollection)
          .doc(profile.id)
          .update(profile.toMap());
    } on FirebaseException catch (e) {
      throw 'Failed to update profile: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred while updating profile.';
    }
  }

  // Delete profile
  Future<void> deleteProfile(String userId) async {
    try {
      await _firestore
          .collection(_profilesCollection)
          .doc(userId)
          .delete();
    } on FirebaseException catch (e) {
      throw 'Failed to delete profile: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred while deleting profile.';
    }
  }

  // Listen to profile changes
  Stream<ProfileModel?> profileStream(String userId) {
    return _firestore
        .collection(_profilesCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return ProfileModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }
}
