import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:proj_management_project/features/auth/repositories/authentication_repository.dart';
import 'package:proj_management_project/services/remote/authentication_service.dart';
import 'package:proj_management_project/services/remote/firestore_service.dart';
import 'package:proj_management_project/services/remote/firebase_messaging_service.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  // Register Firebase instances
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);

  // Register services
  sl.registerLazySingleton<AuthenticationService>(() => AuthenticationService(sl<FirebaseAuth>()));
  sl.registerLazySingleton<FirestoreService>(() => FirestoreService(sl(),sl(),sl()));
  sl.registerLazySingleton<FirebaseMessagingService>(() => FirebaseMessagingService(sl(),sl()));

  // Register repositories
  sl.registerLazySingleton<AuthenticationRepository>(() => AuthenticationRepository(sl<AuthenticationService>(), sl<FirestoreService>()));
}
