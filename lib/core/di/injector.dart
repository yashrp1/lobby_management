import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../data/datasources/event_remote_datasource.dart';
import '../../data/repository/event_repository.dart';
import '../../services/connectivity_service.dart';

final GetIt getIt = GetIt.instance;

class Injector {
  static void init() {
    if (getIt.isRegistered<Dio>()) return; // idempotent

    // Dio
    getIt.registerLazySingleton<Dio>(() => Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 10),
            headers: {
              'Cache-Control': 'public, max-age=60',
            },
          ),
        ));

    // Data sources
    getIt.registerLazySingleton<EventRemoteDataSource>(() =>
        EventRemoteDataSourceImpl(dio: getIt.get<Dio>()));

    // Repository
    getIt.registerLazySingleton<EventRepository>(() => EventRepositoryImpl(
          remoteDataSource: getIt.get<EventRemoteDataSource>(),
        ));

    // Services
    getIt.registerLazySingleton<ConnectivityService>(
        () => ConnectivityServiceImpl());
  }
}


