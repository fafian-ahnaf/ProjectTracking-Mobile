import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ProfileController());
    final brand = c.brand;

    InputDecoration _dec(String hint, IconData icon) => InputDecoration(
          labelText: hint,
          prefixIcon: Icon(icon, size: 20),
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
          ),
        );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        actions: [
          Obx(() => IconButton(
                onPressed: () => c.toggleEdit(),
                icon: Icon(c.isEditing.value ? Icons.close_rounded : Icons.edit_rounded),
                tooltip: c.isEditing.value ? 'Batal' : 'Edit',
              )),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Obx(() {
            if (c.isLoading.value) return const Center(child: CircularProgressIndicator());
            
            return Form(
              key: c.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== Header (Avatar + nama) =====
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: brand,
                          child: Text(
                            (c.user.value?.name.isNotEmpty == true ? c.user.value!.name[0] : 'U').toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          c.user.value?.name ?? 'Loading...',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          c.user.value?.email ?? '',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ===== Form Data Akun =====
                  const Text('Info Dasar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  
                  // Nama
                  TextFormField(
                    controller: c.nameC,
                    enabled: c.isEditing.value,
                    decoration: _dec('Nama Lengkap', Icons.badge_rounded),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),

                  // Email
                  TextFormField(
                    controller: c.emailC,
                    enabled: c.isEditing.value,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _dec('Email', Icons.alternate_email_rounded),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                      if (!GetUtils.isEmail(v)) return 'Format email salah';
                      return null;
                    },
                  ),
                  
                  // ===== Section Ganti Password (Hanya muncul saat Edit) =====
                  if (c.isEditing.value) ...[
                    const SizedBox(height: 24),
                    const Text('Ganti Password (Opsional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: c.currentPassC,
                            obscureText: true,
                            decoration: _dec('Password Saat Ini', Icons.lock_outline),
                            validator: (v) {
                              if (c.newPassC.text.isNotEmpty && (v == null || v.isEmpty)) {
                                return 'Masukkan password lama untuk konfirmasi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: c.newPassC,
                            obscureText: true,
                            decoration: _dec('Password Baru', Icons.key),
                            validator: (v) {
                              if (v != null && v.isNotEmpty && v.length < 6) return 'Minimal 6 karakter';
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: c.confirmPassC,
                            obscureText: true,
                            decoration: _dec('Konfirmasi Password Baru', Icons.check_circle_outline),
                            validator: (v) {
                              if (c.newPassC.text.isNotEmpty && v != c.newPassC.text) {
                                return 'Password baru tidak cocok';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Button Update
                  if (c.isEditing.value)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: c.isSaving.value ? null : c.save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brand,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: c.isSaving.value
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}