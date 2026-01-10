import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../database/app_database.dart';
import '../../features/wallets/data/repositories/wallet_repository_impl.dart';
import '../../features/wallets/data/repositories/wallet_repository.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../features/auth/data/repositories/user_repository_impl.dart';
import '../../features/auth/data/repositories/user_repository.dart';
import '../../features/wallets/presentation/list/wallets_viewmodel.dart';
import '../../features/auth/presentation/viewmodels/user_viewmodel.dart';
import '../../features/transactions/presentation/viewmodel/transactions_viewmodel.dart';
import '../../features/categories/presentation/list/categories_viewmodel.dart';
import '../../features/transactions/data/repositories/transaction_repository.dart';
import '../../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../../features/categories/data/repositories/categories_repository.dart';
import '../../features/categories/data/repositories/categories_repository_impl.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // ============================================
  // LAYER 1: CORE - Infrastructure
  // ============================================

  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // ============================================
  // LAYER 2: DATA - Repositories
  // ============================================

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(firebaseAuth: getIt<FirebaseAuth>(), userRepository: getIt<UserRepository>()),
  );

  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt<AppDatabase>().userDao),
  );

  getIt.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepositoryImpl(getIt<AppDatabase>()),
  );

  // ============================================
  // LAYER 3: PRESENTATION - ViewModels
  // ============================================
  getIt.registerSingleton<AuthViewModel>(
    AuthViewModel(getIt<AuthRepository>(), getIt<AppDatabase>()),
  );

  getIt.registerFactory<WalletsViewModel>(
    () => WalletsViewModel(getIt<WalletRepository>()),
  );

  getIt.registerFactory<UserViewModel>(() => UserViewModel(getIt<UserRepository>(), getIt<AuthRepository>()));

  getIt.registerFactory<TransactionsViewModel>(
    () => TransactionsViewModel(getIt<TransactionRepository>()),
  );

  getIt.registerFactory<CategoriesViewModel>(
    () => CategoriesViewModel(getIt<CategoriesRepository>()),
  );
}
