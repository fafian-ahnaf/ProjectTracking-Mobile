import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/setting_controller.dart';

class SettingView extends GetView<SettingController> {
  const SettingView({super.key});

  Color get brand => const Color(0xFFF69220);

  @override
  Widget build(BuildContext context) {
    Get.put(SettingController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        centerTitle: true,
        backgroundColor: brand,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF6F7FB),
      body: Obx(() => ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              // ===== Umum =====
              _SectionTitle('Umum'),
              _Tile(
                icon: Icons.notifications_active_outlined,
                title: 'Aktifkan Notifikasi',
                trailing: Switch(
                  value: controller.notifEnabled.value,
                  onChanged: controller.toggleNotif,
                ),
              ),

              const SizedBox(height: 8),

              // ===== Tampilan =====
              _SectionTitle('Tampilan'),
              _Tile(
                icon: Icons.dark_mode_outlined,
                title: 'Mode Gelap',
                trailing: Switch(
                  value: controller.darkMode.value,
                  onChanged: controller.toggleDark,
                ),
              ),

              const SizedBox(height: 8),

              // ===== Kontak Kami =====
              _SectionTitle('Bantuan'),
              _Tile(
                icon: Icons.support_agent_outlined,
                title: 'Kontak Kami',
                subtitle: 'Hubungi tim dukungan Project Tracking',
                onTap: () {
                  Get.defaultDialog(
                    title: 'Kontak Kami',
                    titleStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    content: Column(
                      children: const [
                        SizedBox(height: 8),
                        Text(
                          '📧 Email: support@projecttracking.id\n'
                          '📞 Telepon: +62 812 3456 7890\n'
                          '💬 WhatsApp: +62 812 3456 7890',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                    confirm: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF69220),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Tutup'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // ===== Tombol Logout =====
              ElevatedButton.icon(
                onPressed: controller.logout,
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: brand,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}

/* ---------- Widget Kecil ---------- */
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFF69220)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12.5,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
