import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/dummy_data.dart';

class LoginController extends GetxController {
  var isPasswordHidden = true.obs;
  var errorMessage = ''.obs;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void login() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validate input
    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = "Email and password cannot be empty.";
      return;
    }

    // Check dummy data
    final user = DummyData.users.firstWhereOrNull(
        (user) => user.email == email && user.password == password);

    if (user != null) {
      errorMessage.value = '';
      Get.snackbar(
        'Login Success',
        'Welcome ${user.name}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      errorMessage.value = 'Invalid email or password.';
    }
  }
}
