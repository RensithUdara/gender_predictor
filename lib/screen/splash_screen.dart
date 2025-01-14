import 'package:flutter/material.dart';
import 'package:gender_predictor/screen/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimationLeft;
  late Animation<Offset> _slideAnimationRight;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize AnimationController and Animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Slide animations for the images
    _slideAnimationLeft = Tween<Offset>(
      begin: const Offset(-1.5, 0), // Slide from left
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _slideAnimationRight = Tween<Offset>(
      begin: const Offset(1.5, 0), // Slide from right
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    // Fade animation for images
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Scale animation for the logo
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation
    _animationController.forward();

    // Navigate to HomeScreen after a delay
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade100, Colors.cyan.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo at the top with scale animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.teal, Colors.cyan],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Icon(
                        Icons.person_search_rounded,
                        size: 150,
                        color: Colors.white, // Base color to apply gradient
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Animated images with slide and fade effect
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Male Image (slides in from the left)
                      SlideTransition(
                        position: _slideAnimationLeft,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildGenderImage('male'),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Animated Female Image (slides in from the right)
                      SlideTransition(
                        position: _slideAnimationRight,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildGenderImage('female'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Animated Gradient Text
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.teal, Colors.cyan],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: const Text(
                            'Gender Genie',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Base color for gradient
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Animated "Please wait..." Gradient Text
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.teal, Colors.cyan],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds),
                          child: const Text(
                            'Loading...',
                            style: TextStyle(
                              color: Colors.white, // Base color for gradient
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGenderImage(String gender) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: gender == 'male' ? Colors.blueAccent : Colors.pinkAccent,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: (gender == 'male' ? Colors.blueAccent : Colors.pinkAccent)
                .withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/$gender.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
