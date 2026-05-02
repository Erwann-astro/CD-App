import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/disc_provider.dart';
import 'providers/theme_provider.dart';
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
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()..load()),
        ChangeNotifierProxyProvider<DatabaseService, TrackProvider>(
          create: (context) => TrackProvider(context.read<DatabaseService>()),
          update: (context, databaseService, previous) =>
              previous ?? TrackProvider(databaseService),
        ),
      ],
      child: Consumer<ThemeProvider>(builder: (context, themeProvider, _) => MaterialApp(
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
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
        ),
        themeMode: themeProvider.themeMode,
        home: const HomeScreen(),
      )),
    );
  }
}
