import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/themes.dart';
import 'config/router.dart';
import 'presentation/state/auth_provider.dart';
import 'presentation/state/country_provider.dart';
import 'presentation/state/timeline_provider.dart';
import 'presentation/state/theme_provider.dart';
import 'data/repositories/user_repo.dart';
import 'data/services/firebase_auth_service.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = FirebaseAuthService();
    final userRepository = UserRepository(authService);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(userRepository)),
        ChangeNotifierProvider(create: (_) => CountryProvider()),
        ChangeNotifierProvider(create: (_) => TimelineProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        // Wrap with Consumer
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'HistoryVerse',
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeProvider.themeMode,
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: '/',
          );
        },
      ),
    );
  }
}
