// lib/config/router.dart
import 'package:flutter/material.dart';
import '../presentation/pages/landing/landing.dart';
import '../presentation/pages/auth/login.dart';
import '../presentation/pages/auth/register.dart';
import '../presentation/pages/home/home_map_page.dart';
import '../presentation/pages/timeline/period_timeline_page.dart';
import '../presentation/pages/timeline/events_page.dart';
import '../presentation/pages/timeline/event_details_page.dart';
import '../presentation/pages/timeline/character_details_page.dart'; // ✅ Fixed import path
import '../presentation/pages/quiz/quiz_history_page.dart';

import '../data/models/period_model.dart';
import '../data/models/character_model.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => LandingPage());

      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case '/home':
        return MaterialPageRoute(builder: (_) => const GlobePage());

      case '/periods':
        final args = settings.arguments as Map<String, dynamic>;
        final countryId = args['countryId'] as String;
        final countryName = args['countryName'] as String;

        return MaterialPageRoute(
          builder: (context) => PeriodTimelinePage(
            countryId: countryId,
            countryName: countryName,
          ),
        );

      case '/period-details':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PeriodDetailsPage(
            period: args['period'] as Period,
            countryName: args['countryName'] as String,
          ),
        );

      case '/event-details':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => EventDetailsPage(
            event: args['event'] as Event,
            countryName: args['countryName'] as String,
            periodName: args['periodName'] as String,
            eventTitle: args['eventTitle'] as String,
          ),
        );

      case '/character-details':
        // ✅ Added proper null check and error handling
        final character = settings.arguments as Character?;
        if (character == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('Invalid character data')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => CharacterDetailsPage(character: character),
        );

      case '/quiz-history':
        return MaterialPageRoute(builder: (_) => const QuizHistoryPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
