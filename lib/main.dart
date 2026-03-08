import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'blocs/favorites/favorites_bloc.dart';
import 'blocs/search/search_bloc.dart';
import 'core/constants.dart';
import 'core/localization/app_localizations.dart';
import 'models/movie.dart';
import 'repositories/movie_repository.dart';
import 'screens/search_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    if (kDebugMode) {
      print('✅ Environment variables loaded successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ Failed to load .env file: $e');
    }
  }

  try {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MovieAdapter());
    }

    await Hive.openBox<String>('search_history');
    await Hive.openBox<Movie>('favorites');
    await Hive.openBox<Movie>('movie_cache');
    if (kDebugMode) {
      print('📦 Hive initialized and boxes opened');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ Hive initialization error: $e');
    }
  }

  runApp(
    RepositoryProvider(
      create: (context) => MovieRepository(Dio(BaseOptions(baseUrl: baseUrl))),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SearchBloc(
              context.read<MovieRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) =>
                FavoritesBloc(context.read<MovieRepository>())..loadFavorites(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) =>
          AppLocalizations.of(context).translate('app_title'),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SearchScreen(),
      supportedLocales: const [
        Locale('en'),
        Locale('he'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
