import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app_debi/cubit/todo_cubit.dart';
import 'package:todo_app_debi/pages/wrapper_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static String id = "LoginPage";
  static const emailvaild = r"^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$";

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {
  
  late AnimationController _mainController;
  late AnimationController _logoController;
  late AnimationController _formController;
  late AnimationController _backgroundController;
  late AnimationController _buttonController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _formFadeAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _buttonScaleAnimation;

  final formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _mainController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _formController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _buttonController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOutCubic,
    ));

    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoRotationAnimation = Tween<double>(
      begin: -0.2,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    ));

    _formSlideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutCubic,
    ));

    _formFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeIn,
    ));

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundController);

    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    // Start main animation
    _mainController.forward();
    
    // Start logo animation with slight delay
    await Future.delayed(Duration(milliseconds: 200));
    _logoController.forward();
    
    // Start form animation
    await Future.delayed(Duration(milliseconds: 400));
    _formController.forward();
  }

  void _animateButton() async {
    await _buttonController.forward();
    _buttonController.reverse();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _logoController.dispose();
    _formController.dispose();
    _backgroundController.dispose();
    _buttonController.dispose();
    email.dispose();
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
            colors: [
              Color(0xFF1976D2),
              Color(0xFF42A5F5),
              Color(0xFF64B5F6),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            _buildAnimatedBackground(),
            
            // Main content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Animated logo
                        _buildAnimatedLogo(),
                        
                        // Welcome text section
                        _buildWelcomeSection(),
                        
                        // Form section
                        _buildFormSection(),
                        
                        // Login button
                        _buildLoginButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Loading overlay
            if (_isLoading) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(20, (index) {
            double progress = (_backgroundAnimation.value + index * 0.05) % 1.0;
            double x = (index * 50.0) % MediaQuery.of(context).size.width;
            double y = MediaQuery.of(context).size.height * (1 - progress);
            double opacity = progress < 0.1 || progress > 0.9 ? 0.0 : 0.3;
            
            return Positioned(
              left: x,
              top: y,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 3,
                  height: 3,
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

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value,
          child: Transform.rotate(
            angle: _logoRotationAnimation.value,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF54F5FF), Color(0xFFFFFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.check_box_rounded,
                size: 60,
                color: Colors.blue,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection() {
    return SlideTransition(
      position: _formSlideAnimation,
      child: FadeTransition(
        opacity: _formFadeAnimation,
        child: Column(
          children: [
            Text(
              'Welcome Back!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Log in to manage your to-do lists',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return SlideTransition(
      position: _formSlideAnimation,
      child: FadeTransition(
        opacity: _formFadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                _buildAnimatedTextField(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField() {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: TextFormField(
              controller: email,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "You must enter the email";
                }
                if (!RegExp(LoginPage.emailvaild).hasMatch(value.trim())) {
                  return "The email isn't correct";
                }
                return null;
              },
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                labelText: 'Email',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: "Enter your email",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: Icon(Icons.email, color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(color: Colors.white, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(color: Colors.red.shade300),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(color: Colors.red.shade300, width: 2),
                ),
                errorStyle: TextStyle(color: Colors.red.shade200),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginButton() {
    return SlideTransition(
      position: _formSlideAnimation,
      child: FadeTransition(
        opacity: _formFadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: AnimatedBuilder(
            animation: _buttonController,
            builder: (context, child) {
              return Transform.scale(
                scale: _buttonScaleAnimation.value,
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF54C5F8), Color(0xFF02569B)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: _isLoading ? null : _handleLogin,
                      child: Center(
                        child: _isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
              ),
              SizedBox(height: 16),
              Text('Logging in...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (formKey.currentState!.validate()) {
      _animateButton();
      
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(Duration(milliseconds: 1500));

      if (mounted) {
        context.read<TodoCubit>().email = email;
        
        await _mainController.reverse();
        
        Navigator.pushReplacementNamed(context, WrapperPage.id);
      }
    }
  }
}