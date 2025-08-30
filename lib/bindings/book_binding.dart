import '../controllers/book_controller.dart';
import '../services/remote/firebase_book_service.dart';
import '../services/local/local_book_service.dart';
import '../services/service_locator.dart';

class BookBinding {
  static final BookController bookController = BookController(
    get<FirebaseBookService>(),
    get<LocalBookService>(),
  );

  static void init() {
    // Initialize any book-related services here
  }

  static void dispose() {
    // Clean up any book-related resources here
  }
}
