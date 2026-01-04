import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameC;
  late final TextEditingController _emailC;
  late final TextEditingController _phoneC;

  final brand = const Color(0xFFF69220);

  @override
  void initState() {
    super.initState();
    final c = Get.find<ProfileController>();
    _nameC  = TextEditingController(text: c.name.value);
    _emailC = TextEditingController(text: c.email.value);
    _phoneC = TextEditingController(text: c.phone.value);
  }

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _phoneC.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, {IconData? icon}) => InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FA),
      appBar: AppBar(
        backgroundColor: brand,
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Avatar preview (placeholder)
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFEFF3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 52, color: Colors.black54),
                ),
                const SizedBox(height: 18),

                TextFormField(
                  controller: _nameC,
                  textInputAction: TextInputAction.next,
                  decoration: _dec('Full Name', icon: Icons.badge_outlined),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _emailC,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: _dec('Email', icon: Icons.alternate_email),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
                    return ok ? null : 'Email tidak valid';
                  },
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _phoneC,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  decoration: _dec('Phone', icon: Icons.phone_outlined),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nomor telepon wajib diisi' : null,
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brand,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      // TODO: panggil API update di sini kalau pakai backend
                      c.updateProfile(
                        newName: _nameC.text,
                        newEmail: _emailC.text,
                        newPhone: _phoneC.text,
                      );

                      Get.back(); // kembali ke Profile
                      Get.snackbar('Berhasil', 'Profil telah diperbarui',
                          snackPosition: SnackPosition.BOTTOM);
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
