// wrapper_page.dart
import 'package:flutter/material.dart';
import 'package:todo_app_debi/pages/profile_page.dart';
import 'package:todo_app_debi/pages/todo_page.dart';

class WrapperPage extends StatefulWidget {
  const WrapperPage({super.key});
  static const String id = "/wrapper_page";

  @override
  State<WrapperPage> createState() => _WrapperPageState();
}

class _WrapperPageState extends State<WrapperPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const TodoPage(),
    const ProfilePage(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], 
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onTap, 
        type: BottomNavigationBarType.shifting,
        selectedItemColor: Colors.blue,
        selectedLabelStyle: const TextStyle(color: Colors.black, fontSize: 14),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex, 
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inbox), label: "Todos"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}