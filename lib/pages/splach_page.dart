import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:todo_app_debi/pages/login_page.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _particleController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _textController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();

    // Logo animations
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotationAnimation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    // Text animations
    _textSlideAnimation = Tween<Offset>(begin: Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    // Progress animation
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Particle animation
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_particleController);

    _startAnimations();
  }

  void _startAnimations() async {
    await _logoController.forward();

    await Future.delayed(Duration(milliseconds: 500));
    _textController.forward();

    await Future.delayed(Duration(milliseconds: 800));
    _progressController.forward();

    // Navigate to home after all animations complete
    await Future.delayed(Duration(milliseconds: 2000));
    _navigateToHome();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1976D2), Color(0xFF42A5F5), Color(0xFF64B5F6)],
          ),
        ),
        child: Stack(
          children: [
            // Animated particles background
            _buildParticles(),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated logo
                  _buildAnimatedLogo(),

                  SizedBox(height: 40),

                  // Animated title
                  _buildAnimatedTitle(),

                  SizedBox(height: 15),

                  // Animated subtitle
                  _buildAnimatedSubtitle(),

                  SizedBox(height: 60),

                  // Animated progress bar
                  _buildAnimatedProgress(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value,
          child: Transform.rotate(
            angle: _logoRotationAnimation.value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF54F5FF), Color(0xFFFFFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.check_box_rounded,
                size: 100,
                color: Colors.blue,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTitle() {
    return SlideTransition(
      position: _textSlideAnimation,
      child: FadeTransition(
        opacity: _textFadeAnimation,
        child: Text(
          'Todo App',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSubtitle() {
    return SlideTransition(
      position: _textSlideAnimation,
      child: FadeTransition(
        opacity: _textFadeAnimation,
        child: Text(
          'Manage your tasks efficiently',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedProgress() {
    return Column(
      children: [
        Container(
          width: 200,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(2),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF54C5F8), Color(0xFF02569B)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20),
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return Opacity(
              opacity:
                  (0.7 +
                  0.3 *
                      (1 + math.cos(_particleAnimation.value * 2 * math.pi)) /
                      2),
              child: Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(15, (index) {
            double progress = (_particleAnimation.value + index * 0.1) % 1.0;
            double x = (index * 73.0) % MediaQuery.of(context).size.width;
            double y = MediaQuery.of(context).size.height * (1 - progress);

            return Positioned(
              left: x,
              top: y,
              child: Opacity(
                opacity: progress < 0.1 || progress > 0.9 ? 0.0 : 0.6,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// Import for math functions
