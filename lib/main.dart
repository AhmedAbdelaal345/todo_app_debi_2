import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app_debi/cubit/todo_cubit.dart';
import 'package:todo_app_debi/pages/details_page.dart';
import 'package:todo_app_debi/pages/login_page.dart';
import 'package:todo_app_debi/pages/splach_page.dart';
import 'package:todo_app_debi/pages/todo_page.dart';
import 'package:todo_app_debi/pages/wrapper_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodoCubit(),
      child: MaterialApp(
        home: SplashPage(),
        routes: {
          LoginPage.id: (context) => const LoginPage(),
          TodoPage.id: (context) => const TodoPage(),
          WrapperPage.id: (context) => const WrapperPage(),
          DetailsPage.id: (context) => const DetailsPage(),
        },
      ),
    );
  }
}
