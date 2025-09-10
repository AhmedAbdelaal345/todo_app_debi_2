import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app_debi/cubit/todo_cubit.dart';
import 'package:todo_app_debi/pages/login_page.dart';
import 'dart:math' as math;

class ShowLogoutWidget {
  static void show(BuildContext context) {
    _showAnimatedLogoutDialog(context);
  }

  static void _showAnimatedLogoutDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Logout Dialog",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const AnimatedLogoutDialog();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          )),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            )),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class AnimatedLogoutDialog extends StatefulWidget {
  const AnimatedLogoutDialog({Key? key}) : super(key: key);

  @override
  _AnimatedLogoutDialogState createState() => _AnimatedLogoutDialogState();
}

class _AnimatedLogoutDialogState extends State<AnimatedLogoutDialog>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _buttonController;
  late AnimationController _shakeController;
  late AnimationController _backgroundController;

  late Animation<double> _iconRotationAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _buttonHoverAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _backgroundAnimation;

  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _iconRotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeInOut,
    ));

    _iconScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    ));

    _buttonHoverAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundController);

    // Start initial animations
    _iconController.forward();
  }

  @override
  void dispose() {
    _iconController.dispose();
    _buttonController.dispose();
    _shakeController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _handleLogout() async {
    // Shake animation for emphasis
    _shakeController.forward().then((_) => _shakeController.reverse());
    
    setState(() {
      _isLoggingOut = true;
    });

    try {
      // Close dialog first
      Navigator.of(context).pop();
      
      // Perform logout
      await context.read<TodoCubit>().logout();
      
      // Small delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        // Navigate to login with animation
        Navigator.pushNamedAndRemoveUntil(
          context,
          LoginPage.id,
          (route) => false,
        );
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAnimatedButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback? onPressed,
    required bool isSecondary,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: AnimatedBuilder(
              animation: isSecondary ? _buttonController : _shakeController,
              builder: (context, child) {
                double shakeOffset = 0;
                if (!isSecondary) {
                  shakeOffset = math.sin(_shakeAnimation.value * math.pi * 2) * 2;
                }
                
                return Transform.translate(
                  offset: Offset(shakeOffset, 0),
                  child: Transform.scale(
                    scale: isSecondary ? _buttonHoverAnimation.value : 1.0,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: backgroundColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: onPressed,
                          onTapDown: isSecondary ? (_) => _buttonController.forward() : null,
                          onTapUp: isSecondary ? (_) => _buttonController.reverse() : null,
                          onTapCancel: isSecondary ? () => _buttonController.reverse() : null,
                          child: Center(
                            child: _isLoggingOut && !isSecondary
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    text,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
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
        );
      },
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: CustomPaint(
              painter: BackgroundParticlesPainter(_backgroundAnimation.value),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Animated logout icon
          AnimatedBuilder(
            animation: _iconController,
            builder: (context, child) {
              return Transform.scale(
                scale: _iconScaleAnimation.value,
                child: Transform.rotate(
                  angle: _iconRotationAnimation.value,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Animated title
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDialogContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 800),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: Column(
                children: [
                  const Text(
                    'Are you sure you want to logout?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 60, 60, 60),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You will need to login again to access your tasks.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 120, 120, 120),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Cancel button
          Expanded(
            child: _buildAnimatedButton(
              text: 'Cancel',
              backgroundColor: Colors.grey.shade200,
              textColor: Colors.grey.shade700,
              onPressed: () => Navigator.of(context).pop(),
              isSecondary: true,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Logout button
          Expanded(
            child: _buildAnimatedButton(
              text: _isLoggingOut ? 'Logging out...' : 'Logout',
              backgroundColor: const Color(0xFFFF6B6B),
              textColor: Colors.white,
              onPressed: _isLoggingOut ? null : _handleLogout,
              isSecondary: false,
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // Animated background effect
          _buildAnimatedBackground(),
          
          // Main dialog content
          Container(
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with animated icon
                _buildDialogHeader(),
                
                // Content
                _buildDialogContent(),
                
                // Action buttons
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for background particle effects
class BackgroundParticlesPainter extends CustomPainter {
  final double animationValue;

  const BackgroundParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      double progress = (animationValue + i * 0.125) % 1.0;
      double x = size.width * (i * 0.15) % size.width;
      double y = size.height * (1 - progress);
      double radius = 2 + (progress * 3);
      
      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(BackgroundParticlesPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}