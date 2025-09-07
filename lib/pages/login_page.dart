import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app_debi/cubit/todo_cubit.dart';
import 'package:todo_app_debi/pages/todo_page.dart';
import 'package:todo_app_debi/pages/wrapper_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  static String id = "LoginPage";
  static const emailvaild = r"^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$";

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    TextEditingController email = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Login Page')),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Icon(Icons.check_box_rounded, size: 100, color: Colors.blue),
            const Center(
              child: Text(
                'Welcome Back!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const Center(
              child: Text(
                'Log in to manage your to-do lists',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: email,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "You must enter the email";
                  }
                  if (!RegExp(emailvaild).hasMatch(value.trim())) {
                    return "The email isn't correct";
                  }
                  return null;
                },
                style: const TextStyle(color: Colors.grey),
                cursorColor: Colors.grey,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xffF3F3F5),
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.black),
                  hintText: "Enter your email",
                  prefixIcon: const Icon(Icons.email),
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Color(0xffF3F3F5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xffF3F3F5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Color(0xffF3F3F5)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<TodoCubit>().email = email;
                    Navigator.pushNamed(context, WrapperPage.id);
                  }
                },
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all(
                    const Size(double.infinity, 50),
                  ),
                  backgroundColor: WidgetStateProperty.all(Colors.blue),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
