import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  // Request camera permission
  static Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('Error requesting camera permission: $e');
      return false;
    }
  }

  // Request photo library permission
  static Future<bool> requestPhotoPermission() async {
    try {
      final status = await Permission.photos.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('Error requesting photo permission: $e');
      return false;
    }
  }

  // Request storage permission
  static Future<bool> requestStoragePermission() async {
    try {
      final status = await Permission.storage.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('Error requesting storage permission: $e');
      return false;
    }
  }

  // Check if permission is granted
  static Future<bool> checkPermission(Permission permission) async {
    try {
      final status = await permission.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('Error checking permission: $e');
      return false;
    }
  }

  // Show permission denied dialog
  static void showPermissionDeniedDialog(BuildContext context, String permissionType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionType Permission Required', style: GoogleFonts.poppins(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w700),),
        content: Text('This app needs $permissionType permission to function properly. Please grant permission in app settings.', style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
