import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: 1,
              duration: Duration(seconds: 2),
              child: Image.asset(
                "assets/images/world_map_bg.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: "app-logo",
                    child: Lottie.asset(
                      "assets/animations/globe.json",
                      height: 180,
                    ),
                  ),

                  SizedBox(height: 12),

                  Text(
                    "HistoryVerse",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "Travel through time. Discover the world.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),

                  SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, "/login"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFC9A86A),
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),

                  SizedBox(height: 12),

                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, "/register"),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white70),
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Register",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),

                  SizedBox(height: 20),

                  // GUEST
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Continue as guest",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
