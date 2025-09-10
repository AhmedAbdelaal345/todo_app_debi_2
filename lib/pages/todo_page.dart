import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo_app_debi/cubit/todo_cubit.dart';
import 'package:todo_app_debi/cubit/todo_state.dart';
import 'package:todo_app_debi/pages/details_page.dart';
import 'package:todo_app_debi/utils/show_dialog_widget.dart';
import 'package:todo_app_debi/utils/show_logout_widget.dart';
import 'package:todo_app_debi/utils/subtitle_widget.dart';
import 'dart:math' as math;

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});
  static String id = "/todo";

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> with TickerProviderStateMixin {
  Map<int, bool> _todoCheckedState = {};

  // Animation controllers
  late AnimationController _headerController;
  late AnimationController _fabController;
  late AnimationController _listController;
  late AnimationController _refreshController;
  late AnimationController _backgroundController;

  // Animations
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _fabRotationAnimation;
  late Animation<double> _listFadeAnimation;
  late Animation<double> _refreshAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _listController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    // Initialize animations
    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    ));

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutBack,
    ));

    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    ));

    _fabRotationAnimation = Tween<double>(
      begin: -0.5,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeOutBack,
    ));

    _listFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listController,
      curve: Curves.easeOut,
    ));

    _refreshAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _refreshController,
      curve: Curves.easeInOut,
    ));

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_backgroundController);

    // Load todos and start animations
    context.read<TodoCubit>().loadTodos();
    _startAnimations();
  }

  void _startAnimations() async {
    _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _fabController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _listController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _fabController.dispose();
    _listController.dispose();
    _refreshController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _showUserMenu() {
    final todoCubit = context.read<TodoCubit>();
    final currentUser = todoCubit.email ?? 'User';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAnimatedBottomSheet(todoCubit, currentUser),
    );
  }

  // The rest of your TodoPage code remains the same...

Widget _buildAnimatedBottomSheet(TodoCubit todoCubit, String currentUser) {
  return TweenAnimationBuilder<double>(
    duration: const Duration(milliseconds: 400),
    tween: Tween(begin: 0.0, end: 1.0),
    builder: (context, value, child) {
      return Transform.translate(
        offset: Offset(0, 100 * (1 - value)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey.shade50],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView( // Wrap the Column in a SingleChildScrollView
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle indicator
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                
                _buildAnimatedMenuItem(
                  icon: Icons.person,
                  iconColor: Colors.blue,
                  title: 'Logged in as: $currentUser',
                  subtitle: '${todoCubit.todos.length} todos',
                  onTap: null,
                  delay: 0,
                ),
                
                Divider(color: Colors.grey.shade200),
                
                _buildAnimatedMenuItem(
                  icon: Icons.refresh,
                  iconColor: Colors.green,
                  title: 'Refresh Todos',
                  subtitle: null,
                  onTap: () {
                    Navigator.pop(context);
                    _refreshController.forward().then((_) {
                      _refreshController.reverse();
                    });
                    context.read<TodoCubit>().loadTodos();
                    Fluttertoast.showToast(
                      msg: "Todos refreshed",
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                    );
                  },
                  delay: 100,
                ),
                
                _buildAnimatedMenuItem(
                  icon: Icons.delete_sweep,
                  iconColor: Colors.red,
                  title: 'Clear All My Todos',
                  subtitle: null,
                  onTap: () {
                    Navigator.pop(context);
                    _showClearAllDialog(context);
                  },
                  delay: 200,
                ),
                
                _buildAnimatedMenuItem(
                  icon: Icons.logout,
                  iconColor: Colors.orange,
                  title: 'Logout',
                  subtitle: null,
                  onTap: () {
                    Navigator.pop(context);
                    ShowLogoutWidget.show(context);
                  },
                  delay: 300,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// The rest of your TodoPage code remains the same...
  Widget _buildAnimatedMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: subtitle != null ? Text(subtitle) : null,
                onTap: onTap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Clear All Dialog",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
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
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.delete_sweep,
                      size: 30,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Clear All Todos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This will delete all your todos. This action cannot be undone.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await context.read<TodoCubit>().clearUserTodos();
                            Fluttertoast.showToast(
                              msg: "All todos cleared",
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Clear All'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodoCubit, TodoState>(
      builder: (context, state) {
        final todoCubit = context.read<TodoCubit>();
        final todos = todoCubit.todos;
        final currentUser = todoCubit.email ?? 'User';

        for (final todo in todos) {
          if (!_todoCheckedState.containsKey(todo.id)) {
            _todoCheckedState[todo.id] = false;
          }
        }
        _todoCheckedState.removeWhere(
          (todoId, _) => !todos.any((todo) => todo.id == todoId),
        );

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF8F9FA),
                  Colors.white,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated background particles
                _buildBackgroundParticles(),
                
                // Main content
                Column(
                  children: [
                    // Animated app bar
                    _buildAnimatedAppBar(currentUser),
                    
                    // Body
                    Expanded(
                      child: _buildBody(state, todos),
                    ),
                  ],
                ),
              ],
            ),
          ),
          floatingActionButton: _buildAnimatedFAB(),
        );
      },
      listener: (context, state) {
        if (state is TodoDeletedSuccessfully) {
          Fluttertoast.showToast(
            msg: "Todo deleted successfully",
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 14,
            gravity: ToastGravity.BOTTOM,
          );
        } else if (state is ErrorState) {
          Fluttertoast.showToast(
            msg: state.message,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 14,
            gravity: ToastGravity.BOTTOM,
          );
        }
      },
    );
  }

  Widget _buildBackgroundParticles() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Stack(
            children: List.generate(15, (index) {
              double progress = (_backgroundAnimation.value + index * 0.1) % 1.0;
              double x = (index * 80.0) % MediaQuery.of(context).size.width;
              double y = MediaQuery.of(context).size.height * (1 - progress);
              double opacity = progress < 0.1 || progress > 0.9 ? 0.0 : 0.1;
              
              return Positioned(
                left: x,
                top: y,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade200,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedAppBar(String currentUser) {
    return SlideTransition(
      position: _headerSlideAnimation,
      child: FadeTransition(
        opacity: _headerFadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1976D2),
                Color(0xFF42A5F5),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Todos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currentUser,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildAnimatedIconButton(
                    icon: Icons.search,
                    onPressed: () {
                      Fluttertoast.showToast(
                        msg: "Search feature coming soon!",
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildAnimatedIconButton(
                    icon: Icons.account_circle,
                    onPressed: _showUserMenu,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: onPressed,
                icon: Icon(icon, color: Colors.white),
                iconSize: 24,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedFAB() {
    return AnimatedBuilder(
      animation: _fabController,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabScaleAnimation.value,
          child: Transform.rotate(
            angle: _fabRotationAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, DetailsPage.id);
                  if (result == true) {
                    context.read<TodoCubit>().loadTodos();
                  }
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(TodoState state, List todos) {
    return FadeTransition(
      opacity: _listFadeAnimation,
      child: AnimatedBuilder(
        animation: _refreshController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _refreshAnimation.value * 2 * math.pi,
            child: _buildBodyContent(state, todos),
          );
        },
      ),
    );
  }

  Widget _buildBodyContent(TodoState state, List todos) {
    if (state is LoadingTodos) {
      return _buildLoadingState();
    }

    if (state is ErrorState) {
      return _buildErrorState(state);
    }

    if (todos.isEmpty) {
      return _buildEmptyState();
    }

    return _buildTodoList(todos);
  }

  Widget _buildLoadingState() {
    return Center(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 1000),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000), // Equivalent to black with 10% opacity
                        blurRadius: 20,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Loading your todos...",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(ErrorState state) {
    return Center(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 800),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(Icons.error_outline, size: 40, color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Oops! Something went wrong",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 60, 60, 60),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.read<TodoCubit>().loadTodos(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 1200),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: value,
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      child: const Icon(
                        Icons.checklist_outlined,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "No todos yet",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 60, 60, 60),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Tap the + button to add your first todo",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodoList(List todos) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<TodoCubit>().loadTodos();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          final isChecked = _todoCheckedState[todo.id] ?? false;

          return TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(100 * (1 - value), 0),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        todo.title,
                        style: TextStyle(
                          color: isChecked ? Colors.grey : Colors.black,
                          decoration: isChecked ? TextDecoration.lineThrough : null,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SubtitleWidget(todo, isChecked),
                      ),
                      leading: Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          activeColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          value: isChecked,
                          onChanged: (bool? check) {
                            setState(() {
                              _todoCheckedState[todo.id] = check ?? false;
                            });
                             // Assuming 'toggleTodoStatus' exists in your cubit.
                            context.read<TodoCubit>().toggleTodoStatus(todo.id);
                          },
                        ),
                      ),
                      onTap: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          DetailsPage.id,
                          arguments: todo,
                        );
                        if (result == true) {
                          context.read<TodoCubit>().loadTodos();
                        }
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => ShowDialogWidget(todo.title, () {
                                  context.read<TodoCubit>().deleteTodo(todo.id);
                                  Navigator.of(context).pop();
                                }),
                              );
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}