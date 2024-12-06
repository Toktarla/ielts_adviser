import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:proj_management_project/config/di/injection_container.dart';
import 'package:proj_management_project/config/routes.dart';
import 'package:proj_management_project/features/auth/providers/authentication_provider.dart';
import 'package:proj_management_project/features/auth/views/register_screen.dart';
import 'package:provider/provider.dart';
import 'services/remote/firebase_messaging_service.dart';
import 'config/firebase/firebase_options.dart';
import 'services/local/local_notifications_service.dart';
import 'utils/helpers/snackbar_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setupServiceLocator();

  final firebaseMessagingService = sl<FirebaseMessagingService>();

  LocalNotificationService.initialize();
  firebaseMessagingService.initialize();

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
        ChangeNotifierProvider(create: (_) => AuthenticationProvider(sl()))
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
        scaffoldMessengerKey: SnackbarHelper.scaffoldMessengerKey,
      ),
    );
  }
}
