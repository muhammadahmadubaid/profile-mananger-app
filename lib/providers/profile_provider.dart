import 'dart:io';

import 'package:flutter/material.dart';
import 'package:profile_manager_app/models/profile_model.dart';
import 'package:profile_manager_app/services/firestore_service.dart';
import 'package:profile_manager_app/services/storage_service.dart';

class ProfileProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  ProfileModel? _profile;
  bool _isLoading = false;
  String? _error;
  double _uploadProgress = 0.0;

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get uploadProgress => _uploadProgress;

  // Load profile
  Future<void> loadProfile(String userId) async {
    try {
      _setLoading(true);
      _error = null;
      
      _profile = await _firestoreService.getProfile(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Create or update profile
  Future<void> saveProfile({
    required String userId,
    required String name,
    required String email,
    required int age,
    File? profileImage,
    File? document,
    String? documentName,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      String? profileImageUrl = _profile?.profileImageUrl;
      String? documentUrl = _profile?.documentUrl;
      String? finalDocumentName = _profile?.documentName;

      // Upload profile image if provided
      if (profileImage != null) {
        _uploadProgress = 0.0;
        notifyListeners();
        
        // Delete old image if exists
        if (profileImageUrl != null) {
          try {
            await _storageService.deleteFile(profileImageUrl);
          } catch (e) {
            // Ignore delete errors
          }
        }
        
        profileImageUrl = await _storageService.uploadProfileImage(profileImage, userId);
        _uploadProgress = 0.5;
        notifyListeners();
      }

      // Upload document if provided
      if (document != null) {
        _uploadProgress = 0.5;
        notifyListeners();
        
        // Delete old document if exists
        if (documentUrl != null) {
          try {
            await _storageService.deleteFile(documentUrl);
          } catch (e) {
            // Ignore delete errors
          }
        }
        
        documentUrl = await _storageService.uploadDocument(document, userId);
        finalDocumentName = documentName ?? document.path.split('/').last;
        _uploadProgress = 1.0;
        notifyListeners();
      }

      // Create or update profile
      final now = DateTime.now();
      final profile = ProfileModel(
        id: userId,
        name: name,
        email: email,
        age: age,
        profileImageUrl: profileImageUrl,
        documentUrl: documentUrl,
        documentName: finalDocumentName,
        createdAt: _profile?.createdAt ?? now,
        updatedAt: now,
      );

      await _firestoreService.saveProfile(profile);
      _profile = profile;
      _uploadProgress = 0.0;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _uploadProgress = 0.0;
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update profile without files
  Future<void> updateProfileInfo({
    required String userId,
    required String name,
    required String email,
    required int age,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      if (_profile != null) {
        final updatedProfile = _profile!.copyWith(
          name: name,
          email: email,
          age: age,
        );

        await _firestoreService.updateProfile(updatedProfile);
        _profile = updatedProfile;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Delete profile
  Future<void> deleteProfile(String userId) async {
    try {
      _setLoading(true);
      _error = null;

      // Delete files from storage
      if (_profile?.profileImageUrl != null) {
        try {
          await _storageService.deleteFile(_profile!.profileImageUrl!);
        } catch (e) {
          // Ignore delete errors
        }
      }

      if (_profile?.documentUrl != null) {
        try {
          await _storageService.deleteFile(_profile!.documentUrl!);
        } catch (e) {
          // Ignore delete errors
        }
      }

      // Delete from Firestore
      await _firestoreService.deleteProfile(userId);
      _profile = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearProfile() {
    _profile = null;
    _uploadProgress = 0.0;
    notifyListeners();
  }
}
