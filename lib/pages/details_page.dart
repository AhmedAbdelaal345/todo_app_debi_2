import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app_debi/cubit/todo_cubit.dart';
import 'package:todo_app_debi/utils/text_filed_widget.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});
  static String id = "/details_page";

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  // Move controllers to StatefulWidget to prevent recreation
  final TextEditingController title = TextEditingController();
  final TextEditingController desc = TextEditingController();
  final TextEditingController deadLine = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Clean up controllers when widget is disposed
    title.dispose();
    desc.dispose();
    deadLine.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.blue, // Header background color
            onPrimary: Colors.white, // Header text color
            onSurface: Colors.black, // Body text color
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue, // Button text color
            ),
          ),
        ),
        child: child!,
      ),
    );

    if (pickedDate != null) {
      setState(() {
        deadLine.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  Future<void> _saveTodo() async {
    if (_formKey.currentState!.validate()) {
      final titleText = title.text.trim();
      final descText = desc.text.trim();
      final deadlineText = deadLine.text.trim();

      print("DEBUG: Save button pressed");
      print("DEBUG: Title: '$titleText'");
      print("DEBUG: Description: '$descText'");
      print("DEBUG: Deadline: '$deadlineText'");

      try {
        await context.read<TodoCubit>().addTodo(
          titleText,
          description: descText.isNotEmpty ? descText : null,
          deadline: deadlineText.isNotEmpty ? deadlineText : null,
        );

        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Todo saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back with success result
          Navigator.pop(context, true);
        }
      } catch (e) {
        print("DEBUG: Error saving todo: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving todo: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      print("DEBUG: Form validation failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Todo Details",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextFiledWidget(
                controller: title,
                hintText: "Enter your Todo Title",
                labelText: "Todo Title",
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFiledWidget(
                controller: desc,
                hintText: "Enter your Todo description",
                labelText: "Todo Description",
                contentPadding: const EdgeInsets.all(15),
                maxLines: 3,
                validator: (value) {
                  // ✅ FIXED: Made description optional - remove validation
                  // Description is now optional, so no validation needed
                  return null;
                },
              ),
              TextFiledWidget(
                controller: deadLine,
                hintText: "Select deadline",
                labelText: "Deadline",
                readOnly: true,
                onTap: _selectDate,
                suffixIcon: const Icon(Icons.calendar_today),
                validator: (value) {
                  // ✅ FIXED: Made deadline optional - remove validation
                  // Deadline is now optional, so no validation needed
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _saveTodo,
                  child: const Text(
                    "Save",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
