import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../database/app_database.dart';
import '../../features/wallets/data/repositories/wallet_repository_impl.dart';
import '../../features/wallets/data/repositories/wallet_repository.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../features/users/data/datasources/user_firebase_service.dart';
import '../../features/users/data/repositories/user_repository_impl.dart';
import '../../features/users/data/repositories/user_repository.dart';
import '../../features/users/domain/services/user_service.dart';
import '../../features/users/presentation/viewmodels/user_viewmodel.dart';
import '../../features/wallets/presentation/list/wallets_viewmodel.dart';
import '../../features/categories/data/services/category_local_service.dart';
import '../../features/categories/data/services/category_firebase_service.dart';
import '../../features/categories/data/repositories/categories_repository_impl.dart';
import '../../features/categories/data/repositories/categories_repository.dart';
import '../../features/categories/domain/usecases/get_categories_usecase.dart';
import '../../features/categories/domain/usecases/get_categories_by_type_usecase.dart';
import '../../features/categories/domain/usecases/get_category_by_id_usecase.dart';
import '../../features/categories/domain/usecases/add_category_usecase.dart';
import '../../features/categories/domain/usecases/update_category_usecase.dart';
import '../../features/categories/domain/usecases/delete_category_usecase.dart';
import '../../features/categories/domain/usecases/sync_categories_usecase.dart';
import '../../features/categories/presentation/list/categories_viewmodel.dart';
import '../../features/transactions/data/services/transaction_local_service.dart';
import '../../features/transactions/data/services/transaction_firebase_service.dart';
import '../../features/transactions/presentation/list/transactions_viewmodel.dart';

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

  // User Firebase Service
  getIt.registerLazySingleton<UserFirebaseService>(
    () => UserFirebaseServiceImpl(
      getIt<FirebaseFirestore>(),
      getIt<AppDatabase>().userDao,
      getIt<FirebaseAuth>(),
    ),
  );

  // User Repository
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      getIt<AppDatabase>().userDao,
      getIt<UserFirebaseService>(),
    ),
  );

  // User Service
  getIt.registerLazySingleton<UserService>(
    () => UserService(getIt<UserRepository>()),
  );

  // View Model
  getIt.registerSingleton<AuthViewModel>(
    AuthViewModel(
      getIt<AuthRepository>(),
      getIt<UserService>(),
      getIt<AppDatabase>(),
    ),
  );
  getIt.registerLazySingleton<UserViewModel>(
    () => UserViewModel(getIt<UserRepository>()),
  );
  getIt.registerFactory<TransactionsViewModel>(
    () => TransactionsViewModel(
      getIt<TransactionLocalService>(),
      getIt<TransactionFirebaseService>(),
    ),
  );
  getIt.registerFactory<CategoriesViewModel>(
    () => CategoriesViewModel(
      getIt<GetCategoriesUseCase>(),
      getIt<AddCategoryUseCase>(),
      getIt<UpdateCategoryUseCase>(),
      getIt<DeleteCategoryUseCase>(),
      getIt<SyncCategoriesUseCase>(),
    ),
  );
    getIt.registerFactory<WalletsViewModel>(
    () => WalletsViewModel(
      getIt<WalletRepository>(),
    ),
  );

  // Repositories
  getIt.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(getIt<AppDatabase>()),
  );

  // Categories - Services
  getIt.registerLazySingleton<CategoryLocalService>(
    () => CategoryLocalServiceImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<CategoryFirebaseService>(
    () => CategoryFirebaseServiceImpl(
      getIt<FirebaseFirestore>(),
      getIt<AppDatabase>().categoryDao,
      getIt<FirebaseAuth>(),
    ),
  );

  // Categories - Repositories
  getIt.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepositoryImpl(
      getIt<CategoryLocalService>(),
      getIt<CategoryFirebaseService>(),
    ),
  );

  // Categories - Use Cases
  getIt.registerLazySingleton<GetCategoriesUseCase>(
    () => GetCategoriesUseCase(getIt<CategoriesRepository>()),
  );
  getIt.registerLazySingleton<GetCategoriesByTypeUseCase>(
    () => GetCategoriesByTypeUseCase(getIt<CategoriesRepository>()),
  );
  getIt.registerLazySingleton<GetCategoryByIdUseCase>(
    () => GetCategoryByIdUseCase(getIt<CategoriesRepository>()),
  );
  getIt.registerLazySingleton<AddCategoryUseCase>(
    () => AddCategoryUseCase(getIt<CategoriesRepository>()),
  );
  getIt.registerLazySingleton<UpdateCategoryUseCase>(
    () => UpdateCategoryUseCase(getIt<CategoriesRepository>()),
  );
  getIt.registerLazySingleton<DeleteCategoryUseCase>(
    () => DeleteCategoryUseCase(getIt<CategoriesRepository>()),
  );
  getIt.registerLazySingleton<SyncCategoriesUseCase>(
    () => SyncCategoriesUseCase(getIt<CategoriesRepository>()),
  );



  // Transactions - Services
  getIt.registerLazySingleton<TransactionLocalService>(
    () => TransactionLocalServiceImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<TransactionFirebaseService>(
    () => TransactionFirebaseServiceImpl(
      getIt<FirebaseFirestore>(),
      getIt<AppDatabase>().transactionDao,
      getIt<FirebaseAuth>(),
    ),
  );
}
