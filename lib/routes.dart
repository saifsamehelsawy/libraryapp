import 'package:flutter/material.dart';
import 'views/screens/splash_screen.dart';
import 'views/screens/login_screen.dart';
import 'views/screens/register_screen.dart';
import 'views/screens/home_screen.dart';
import 'views/screens/profile_screen.dart';
import 'views/screens/purchases_screen.dart';
import 'views/screens/book_details_screen.dart';
import 'views/screens/favorites_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String purchases = '/purchases';
  static const String bookDetails = '/book-details';
  static const String favorites = '/favorites';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        home: (context) => const HomeScreen(),
        profile: (context) => const ProfileScreen(),
        purchases: (context) => const PurchasesScreen(),
        bookDetails: (context) => const BookDetailsScreen(),
        favorites: (context) => const FavoritesScreen(),
      };
}
