import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/disc_provider.dart';
import 'providers/track_provider.dart';
import 'screens/home_screen.dart';
import 'services/database_service.dart';

class CDCatalogApp extends StatelessWidget {
  const CDCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseService>(create: (_) => DatabaseService.instance),
        ChangeNotifierProxyProvider<DatabaseService, DiscProvider>(
          create: (context) => DiscProvider(context.read<DatabaseService>()),
          update: (context, databaseService, previous) =>
              previous ?? DiscProvider(databaseService),
        ),
        ChangeNotifierProxyProvider<DatabaseService, TrackProvider>(
          create: (context) => TrackProvider(context.read<DatabaseService>()),
          update: (context, databaseService, previous) =>
              previous ?? TrackProvider(databaseService),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Catalogue CD',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          textTheme: const TextTheme(
            titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
