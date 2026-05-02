import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/disc_provider.dart';
import 'providers/track_provider.dart';
import 'screens/home_screen.dart';
import 'services/database_service.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseService>.value(value: DatabaseService.instance),
        ChangeNotifierProxyProvider<DatabaseService, DiscProvider>(
          create: (ctx) => DiscProvider(ctx.read<DatabaseService>()),
          update: (_, db, prev) => prev ?? DiscProvider(db),
        ),
        ChangeNotifierProxyProvider<DatabaseService, TrackProvider>(
          create: (ctx) => TrackProvider(ctx.read<DatabaseService>()),
          update: (_, db, prev) => prev ?? TrackProvider(db),
        ),
      ],
      child: MaterialApp(
        title: 'Mes Disques',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
          textTheme: const TextTheme(
            titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            bodyLarge: TextStyle(fontSize: 16),
            bodyMedium: TextStyle(fontSize: 14),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
