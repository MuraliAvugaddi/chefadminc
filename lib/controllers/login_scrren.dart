import 'package:chefadmin/screens/homeScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class LoginController extends GetxController {
  // Controllers to get text from the TextFields
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // This function is called when the login button is pressed
  void login() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // --- THIS IS THE HARDCODED CHECK ---
    if (email == '12345' && password == '12345') {
      // If login is successful, show a success message
      Get.snackbar(
        'Success',
        'Login successful!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Navigate to the dashboard and remove the login screen from history
      Get.offAll(() =>Homescreen());

    } else {
      // If login fails, show an error message
      Get.snackbar(
        'Login Failed',
        'Invalid email or password.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Clean up the controllers when the screen is closed
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}