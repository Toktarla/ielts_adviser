import 'package:flutter/material.dart';
import 'package:proj_management_project/features/auth/views/login_screen.dart';
import 'package:proj_management_project/features/auth/views/register_screen.dart';
import 'package:proj_management_project/features/auth/views/verify_email_screen.dart';
import 'package:proj_management_project/utils/error/error_page.dart';
import 'package:proj_management_project/features/home/views/home_page.dart';
import 'package:proj_management_project/features/streak/views/streak_tracker_page.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/Login':
        return _materialRoute(const LoginPage());
      case '/Register':
        return _materialRoute(const RegisterPage());
      case '/VerifyEmail':
        return _materialRoute(const VerifyEmailPage());
      case '/HomePage':
        final map = settings.arguments as Map<String,dynamic>;
        return _materialRoute(HomePage(userId: map['userId'],));
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