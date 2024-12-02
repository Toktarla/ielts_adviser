import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:proj_management_project/core/routes.dart';
import 'package:proj_management_project/pages/auth/register_screen.dart';
import 'package:proj_management_project/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'services/firebase_messaging_service.dart';
import 'config/firebase_options.dart';
import 'services/local_notifications_service.dart';
import 'services/snackbar_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  LocalNotificationService.initialize();
  FirebaseMessagingService.initialize();

  LocalNotificationService.scheduleDailyMotivationalMessage();


  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider(FirebaseAuth.instance, FirebaseFirestore.instance))
      ],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRoutes.onGenerateRoutes,
        title: 'IELTS Adviser',
        home: const RegisterPage(),
        scaffoldMessengerKey: SnackbarService.scaffoldMessengerKey,
      ),
    );
  }
}

