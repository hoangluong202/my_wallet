import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../database/app_database.dart';
import '../../features/wallets/data/repositories/wallet_repository_impl.dart';
import '../../features/wallets/data/repositories/wallet_repository.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../features/users/data/repositories/user_repository_impl.dart';
import '../../features/users/data/repositories/user_repository.dart';
import '../../features/wallets/presentation/list/wallets_viewmodel.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core - Database
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Firebase
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // Auth Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(firebaseAuth: getIt<FirebaseAuth>()),
  );

  // User Repository
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt<AppDatabase>().userDao),
  );

  // View Model
  getIt.registerSingleton<AuthViewModel>(
    AuthViewModel(getIt<AuthRepository>(), getIt<AppDatabase>()),
  );

  getIt.registerFactory<WalletsViewModel>(
    () => WalletsViewModel(getIt<WalletRepository>()),
  );

  // Repositories
  getIt.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(getIt<AppDatabase>()),
  );
}
