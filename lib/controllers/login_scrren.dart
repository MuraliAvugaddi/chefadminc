import 'package:chefadmin/screens/homeScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var isLoading = false.obs; // ✅ Reactive loading state

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Input Required', 'Please fill in both fields', 
        backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    
    // Simulate a small network delay for better UX
    await Future.delayed(const Duration(milliseconds: 800));

    if (email == '123321' && password == '321123') {
      Get.snackbar('Success', 'Welcome back, Admin!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
      Get.offAll(() =>  Homescreen());
    } else {
      Get.snackbar('Access Denied', 'Invalid credentials.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
    isLoading.value = false;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}