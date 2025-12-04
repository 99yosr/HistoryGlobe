import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:history_globe/presentation/state/theme_provider.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';

import '../../../data/models/country_model.dart';
import '../../../presentation/state/country_provider.dart';
import '../../../data/models/historicalFact_model.dart';

const String kGlobeStyle = 'https://demotiles.maplibre.org/globe.json';

class GlobePage extends StatefulWidget {
  const GlobePage({super.key});

  @override
  State<GlobePage> createState() => _GlobePageState();
}

class _GlobePageState extends State<GlobePage> with TickerProviderStateMixin {
  MapLibreMapController? _controller;
  final Map<String, Country> _circleCountryMap = {};
  bool _markersAdded = false;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Consumer<CountryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading countries...',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.shade700.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: MapLibreMap(
                        styleString: kGlobeStyle,
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(20, 0),
                          zoom: 1.5,
                        ),
                        onMapCreated: _onMapCreated,
                        onStyleLoadedCallback: _onStyleLoaded,
                      ),
                    ),
                  ),
                ),
              ),

              // Top gradient overlay for better readability
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        primaryColor.withOpacity(isDark ? 0.4 : 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // App title
              Positioned(
                top: 50,
                left: 32,
                child: FadeTransition(
                  opacity: _fabAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'History Explorer',
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontSize: 28,
                          color: isDark ? Colors.white : theme.primaryColor,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap a country to explore',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 14,
                          color: isDark
                              ? Colors.white.withOpacity(0.9)
                              : Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Error message
              if (provider.error != null)
                Positioned(
                  top: 120,
                  left: 20,
                  right: 20,
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, -1),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _fabAnimationController,
                            curve: Curves.easeOut,
                          ),
                        ),
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade700,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Error: ${provider.error}",
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Floating Action Buttons
              Positioned(
                bottom: 40,
                right: 24,
                child: ScaleTransition(
                  scale: _fabAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildAnimatedFAB(
                        heroTag: 'themeToggle',
                        icon: context.watch<ThemeProvider>().getThemeIcon(),
                        label: 'mode',
                        onPressed: () {
                          context.read<ThemeProvider>().toggleTheme();
                        },
                        delay: 0,
                      ),
                      const SizedBox(height: 16),

                      _buildAnimatedFAB(
                        heroTag: 'historyFacts',
                        icon: Icons.history_edu,
                        label: 'Facts',
                        onPressed: _showHistoryFacts,
                        delay: 100,
                      ),
                      const SizedBox(height: 16),
                      _buildAnimatedFAB(
                        heroTag: 'quizHistory',
                        icon: Icons.school_outlined,
                        label: 'Quiz',
                        onPressed: () {
                          Navigator.pushNamed(context, '/quiz-history');
                        },
                        delay: 200,
                      ),
                      const SizedBox(height: 16),
                      _buildAnimatedFAB(
                        heroTag: 'logout',
                        icon: Icons.logout_rounded,
                        label: 'Logout',
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        },
                        delay: 300,
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimatedFAB({
    required String heroTag,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required int delay,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + delay),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutBack,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            color: isDestructive ? Colors.red.shade400 : primaryColor,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onMapCreated(MapLibreMapController controller) {
    debugPrint("Map created");
    _controller = controller;

    controller.onCircleTapped.add((circle) {
      _onCircleTapped(circle.id);
    });
  }

  void _onStyleLoaded() async {
    debugPrint("Map style loaded");

    final provider = context.read<CountryProvider>();

    if (!_markersAdded && !provider.isLoading) {
      await _addCountryMarkers();
      _markersAdded = true;
    }

    provider.addListener(() async {
      if (!_markersAdded && !provider.isLoading) {
        await _addCountryMarkers();
        _markersAdded = true;
      }
    });
  }

  Future<void> _addCountryMarkers() async {
    if (_controller == null) return;

    final provider = context.read<CountryProvider>();
    final countries = provider.countries;

    if (countries.isEmpty) return;

    debugPrint("Adding ${countries.length} country markers…");

    int added = 0;
    int skipped = 0;

    for (final country in countries) {
      if (country.latitude == 0.0 && country.longitude == 0.0) {
        skipped++;
        continue;
      }

      try {
        final circle = await _controller!.addCircle(
          CircleOptions(
            geometry: LatLng(country.latitude!, country.longitude!),
            circleRadius: 8,
            circleColor: "#8B4513", // brown color
            circleOpacity: 0.85,
            circleStrokeWidth: 2,
            circleStrokeColor: "#FFFFFF",
            circleStrokeOpacity: 0.8,
          ),
        );

        _circleCountryMap[circle.id] = country;
        added++;
      } catch (e) {
        debugPrint("❌ Failed to add circle for ${country.name}: $e");
        skipped++;
      }
    }

    debugPrint("✅ Markers added: $added | Skipped: $skipped");
  }

  void _onCircleTapped(String circleId) {
    final country = _circleCountryMap[circleId];
    if (country == null) return;

    Navigator.pushNamed(
      context,
      "/periods",
      arguments: {
        "countryId": country.id,
        "countryName": country.name ?? "Unknown Country",
      },
    );
  }

  Future<List<HistoryFact>> fetchHistoricalFacts() async {
    final url = Uri.parse('https://api.dayinhistory.dev/v1/today/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final events = data['events'] as List;
      return events.map((e) => HistoryFact.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch history facts');
    }
  }

  void _showHistoryFacts() async {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    try {
      final facts = await fetchHistoricalFacts();

      if (facts.isEmpty) return;

      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(24),
            child: Container(
              height: 450,
              decoration: BoxDecoration(
                color: scaffoldBg,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.history_edu, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Historical Facts Today",
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  // Carousel
                  Expanded(
                    child: CarouselSlider.builder(
                      itemCount: facts.length,
                      itemBuilder: (context, index, realIndex) {
                        final fact = facts[index];
                        return Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  fact.year,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                fact.title,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Text(
                                    fact.description,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      options: CarouselOptions(
                        enableInfiniteScroll: false,
                        enlargeCenterPage: true,
                        viewportFraction: 1.0,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  // Indicator
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      'Swipe to see more facts',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching facts: $e"),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
