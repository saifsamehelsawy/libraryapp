import '../controllers/auth_controller.dart';

class AuthBinding {
  static final AuthController authController = AuthController();

  static void init() {
    // Initialize any auth-related services here
  }

  static void dispose() {
    // Clean up any auth-related resources here
  }
}
