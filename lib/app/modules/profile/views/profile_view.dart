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
          hintText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
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
          child: Obx(
            () => Form(
              key: c.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== Header (Avatar + nama + email) =====
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0ECEC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: brand,
                          child: Text(
                            (c.nameC.text.isNotEmpty ? c.nameC.text[0] : 'U').toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.nameC.text.isEmpty ? '—' : c.nameC.text,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                c.emailC.text.isEmpty ? '—' : c.emailC.text,
                                style: const TextStyle(color: Colors.black54),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ===== Card Data Akun =====
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0ECEC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Data Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),

                        // Nama
                        const Text('Nama', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: c.nameC,
                          enabled: c.isEditing.value,
                          decoration: _dec('Nama pengguna', Icons.badge_rounded),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Nama tidak boleh kosong' : null,
                          onChanged: (_) => {}, // biar Obx header refresh via setState luar
                        ),
                        const SizedBox(height: 14),

                        // Email
                        const Text('Email', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: c.emailC,
                          enabled: c.isEditing.value,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _dec('Email', Icons.alternate_email_rounded),
                          validator: (v) {
                            final text = (v ?? '').trim();
                            final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text);
                            if (text.isEmpty) return 'Email tidak boleh kosong';
                            if (!ok) return 'Format email tidak valid';
                            return null;
                          },
                          onChanged: (_) => {},
                        ),
                        const SizedBox(height: 18),

                        // Button Update
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: c.isEditing.value && !c.isSaving.value ? c.save : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brand,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: c.isSaving.value
                                ? const SizedBox(
                                    height: 18, width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Update Profil', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
