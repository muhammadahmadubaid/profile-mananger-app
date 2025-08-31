import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:profile_manager_app/utils/permission_helper.dart';

class FileHelper {
  static final ImagePicker _imagePicker = ImagePicker();

  // Pick image from gallery
  static Future<File?> pickImageFromGallery(BuildContext context) async {
    try {
      final hasPermission = await PermissionHelper.requestPhotoPermission();
      if (!hasPermission) {
        if (context.mounted) {
          PermissionHelper.showPermissionDeniedDialog(context, 'Photo Library');
        }
        return null;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      return image != null ? File(image.path) : null;
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to pick image from gallery');
      }
      return null;
    }
  }

  // Take photo with camera
  static Future<File?> takePhotoWithCamera(BuildContext context) async {
    try {
      final hasPermission = await PermissionHelper.requestCameraPermission();
      if (!hasPermission) {
        if (context.mounted) {
          PermissionHelper.showPermissionDeniedDialog(context, 'Camera');
        }
        return null;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      return image != null ? File(image.path) : null;
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to take photo');
      }
      return null;
    }
  }

  // Pick document file
  static Future<File?> pickDocument(BuildContext context) async {
    try {
      final hasPermission = await PermissionHelper.requestStoragePermission();
      if (!hasPermission) {
        if (context.mounted) {
          PermissionHelper.showPermissionDeniedDialog(context, 'Storage');
        }
        return null;
      }

      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        
        // Check file size (max 5MB)
        final fileSizeInBytes = await file.length();
        final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
        
        if (fileSizeInMB > 5) {
          if (context.mounted) {
            _showErrorSnackBar(context, 'File size must be less than 5MB');
          }
          return null;
        }
        
        return file;
      }

      return null;
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to pick document');
      }
      return null;
    }
  }

  // Show image picker options
  static void showImagePickerOptions(BuildContext context, Function(File?) onImageSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Profile Picture',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 20
              )
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  context,
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () async {
                    Navigator.pop(context);
                    final image = await takePhotoWithCamera(context);
                    onImageSelected(image);
                  },
                ),
                _buildImageOption(
                  context,
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () async {
                    Navigator.pop(context);
                    final image = await pickImageFromGallery(context);
                    onImageSelected(image);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _buildImageOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
