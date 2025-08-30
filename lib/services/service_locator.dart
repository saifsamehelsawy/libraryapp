import 'package:get_it/get_it.dart';
import 'auth_service.dart';
import 'book_service.dart';
import 'purchase_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Services
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<BookService>(() => BookService());
  getIt.registerLazySingleton<PurchaseService>(() => PurchaseService());
}

T get<T extends Object>() => getIt.get<T>();
