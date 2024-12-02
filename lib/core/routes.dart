import 'package:flutter/material.dart';
import 'package:proj_management_project/core/error_page.dart';
import 'package:proj_management_project/pages/auth/login_screen.dart';
import 'package:proj_management_project/pages/auth/register_screen.dart';
import 'package:proj_management_project/pages/auth/verify_email_screen.dart';
import 'package:proj_management_project/pages/home_page.dart';
import 'package:proj_management_project/pages/streak_tracker_page.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/LoginScreen':
        return _materialRoute(const LoginPage());
      case '/RegisterScreen':
        return _materialRoute(const RegisterPage());
      case '/VerifyEmail':
        return _materialRoute(const VerifyEmailPage());
      case '/HomePage':
        return _materialRoute(const HomePage());
      case '/StreakTracker':
        final map = settings.arguments as Map<String,dynamic>;
        return _materialRoute(StreakTracker(userId: map['userId']));
      default:
        return _materialRoute(const ErrorPage());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(
      builder: (_) => view,
    );
  }
}