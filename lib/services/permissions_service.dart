import 'package:permission_handler/permission_handler.dart';

/// Represents the result of asking the user for a permission.
enum AppPermissionResult {
  /// The user allowed access.
  granted,

  /// The user declined access this time, but we can ask again.
  denied,

  /// The user declined access permanently ("Don't ask again"),
  /// so they need to open device settings to turn it on.
  permanentlyDenied,
}

/// A service that handles checking and requesting permissions in the app.
class PermissionsService {
  /// Checks if camera access is already granted, or prompts the user for it.
  ///
  /// Returns [AppPermissionResult.granted] if allowed,
  /// [AppPermissionResult.permanentlyDenied] if blocked by the user,
  /// or [AppPermissionResult.denied] for any denial or unexpected error.
  Future<AppPermissionResult> requestCamera() async {
    try {
      // Check if camera permission is already granted before asking again.
      final status = await Permission.camera.status;
      if (status.isGranted) {
        return AppPermissionResult.granted;
      }

      // If not granted, request the permission from the user.
      final result = await Permission.camera.request();
      if (result.isGranted) {
        return AppPermissionResult.granted;
      } else if (result.isPermanentlyDenied) {
        return AppPermissionResult.permanentlyDenied;
      } else {
        return AppPermissionResult.denied;
      }
    } catch (_) {
      // If any error occurs, safely fall back to denied instead of crashing.
      return AppPermissionResult.denied;
    }
  }

  /// Opens the phone's settings page for this app so the user can manually enable permissions.
  Future<bool> openSettings() {
    return openAppSettings();
  }
}
