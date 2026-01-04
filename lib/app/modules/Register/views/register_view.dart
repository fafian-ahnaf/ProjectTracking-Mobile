import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  InputDecoration _input(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Colors.black38),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF69220), // oranye brand
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Hilangkan brand kiri atas =====
              const SizedBox(height: 20),

              // ===== Judul =====
              const Center(
                child: Text(
                  'DAFTAR AKUN',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ===== Username =====
              TextField(
                controller: controller.usernameC,
                textInputAction: TextInputAction.next,
                style: const TextStyle(color: Colors.black87),
                decoration: _input('Username'),
              ),
              const SizedBox(height: 12),

              // ===== Email =====
              TextField(
                controller: controller.emailC,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: const TextStyle(color: Colors.black87),
                decoration: _input('Email'),
              ),
              const SizedBox(height: 12),

              // ===== Password =====
              Obx(() => TextField(
                    controller: controller.passC,
                    obscureText: controller.obscure1.value,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(color: Colors.black87),
                    decoration: _input('Password').copyWith(
                      suffixIcon: IconButton(
                        onPressed: controller.toggle1,
                        icon: Icon(
                          controller.obscure1.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  )),
              const SizedBox(height: 12),

              // ===== Confirm Password =====
              Obx(() => TextField(
                    controller: controller.confirmC,
                    obscureText: controller.obscure2.value,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(color: Colors.black87),
                    decoration: _input('Confirm password').copyWith(
                      suffixIcon: IconButton(
                        onPressed: controller.toggle2,
                        icon: Icon(
                          controller.obscure2.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  )),
              const SizedBox(height: 16),

              // ===== Tombol Register =====
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA9BA9D),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: controller.onRegister,
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // ===== Divider “Or Register with” =====
              const SizedBox(height: 20),
              Row(
                children: const [
                  Expanded(
                      child: Divider(color: Colors.black26, thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Or Register with',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  Expanded(
                      child: Divider(color: Colors.black26, thickness: 1)),
                ],
              ),

              // ===== Tombol Google =====
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.transparent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: controller.registerWithGoogle,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/logo_google.webp',
                          width: 22, height: 22),
                      const SizedBox(width: 10),
                      const Text(
                        'Login Dengan Google',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
