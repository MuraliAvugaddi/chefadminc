// Import your screen
import 'package:chefadmin/screens/homeScreen.dart';
import 'package:chefadmin/services/Api_token_history.dart';
// Import Flutter and GetX
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  // Ensure that Flutter bindings are initialized before running the app.
  WidgetsFlutterBinding.ensureInitialized();
  Get.put<ApiService>(ApiService());
  // -------------------------

  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use GetMaterialApp as you are using GetX for state management.
    return GetMaterialApp(
      title: 'Chef Services Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal, // Changed color for better UI consistency
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(
            0xffFFC800,
          ), // Keeping your brand color for AppBar
          elevation: 1,
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black87),
        ),
      ),
      // The app now starts directly at the HomeScreen.
      home: const Homescreen(),
    );
  }
}