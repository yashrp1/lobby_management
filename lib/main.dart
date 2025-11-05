import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/logger.dart';
import 'core/utils/performance_monitor.dart';
import 'core/utils/validators.dart';
import 'core/utils/image_cache_config.dart';
import 'core/di/injector.dart';
import 'data/repository/event_repository.dart';
import 'presentation/bloc/event_detail/event_detail_cubit.dart';
import 'presentation/screens/event_detail_screen.dart';
import 'presentation/widgets/connectivity_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  AppLogger.info('App initializing...');
  PerformanceMonitor.startTimer('app_initialization');
  
  // Configure image cache for optimal memory usage
  ImageCacheConfig.configure();
  
  // Set system UI overlay style to match reference (dark status bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  
  // Initialize DI container
  Injector.init();
  final repository = getIt.get<EventRepository>();
  
  PerformanceMonitor.endTimer('app_initialization');
  AppLogger.info('App initialized successfully');
  PerformanceMonitor.logMemoryUsage();
  
  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final EventRepository repository;

  const MyApp({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Lobby',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: ConnectivityGate(
        child: BlocProvider(
          create: (context) => EventDetailCubit(repository: repository),
          child: EventDetailScreen(
            eventId: Validators.isValidEventId(AppConstants.defaultEventId)
                ? AppConstants.defaultEventId
                : AppConstants.defaultEventId, // Will be validated in data source
            token: null, // Token should be loaded from secure storage in production
          ),
        ),
      ),
    );
  }
}
