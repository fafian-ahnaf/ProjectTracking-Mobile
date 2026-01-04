import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_tracking/app/modules/dasboard/controllers/dasboard_controller.dart';
import 'package:project_tracking/app/routes/app_pages.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  Color get brand => const Color(0xFFF69220);

  @override
  Widget build(BuildContext context) {
    // Inject Controller
    final c = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: Colors.white,

      // ... bottomNavigationBar tetap sama ...
      body: SafeArea(
        // Tambahkan RefreshIndicator agar user bisa swipe-down untuk reload data
        child: RefreshIndicator(
          onRefresh: () async {
            await c.fetchDashboard();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Update Header dengan Controller
                _Header(brand: brand, controller: c),

                const SizedBox(height: 18),

                // ... Akses Cepat & Quick Action tetap sama ...
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Akses Cepat',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                // ... (lanjutan kode separator dan quick action kamu) ...
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Divider(color: Color(0xFFCBCAD1), thickness: 1),
                ),
                const SizedBox(height: 14),

                // ===== Quick Action (Biarkan kode lama) =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _QuickAction(
                        imagePath: 'assets/project_icon.png',
                        label: 'Project',
                        onTap: () => Get.toNamed(Routes.PROJECT),
                      ),
                      _QuickAction(
                        imagePath: 'assets/report_icon.png',
                        label: 'Report',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ===== Stat Kartu (UPDATE BAGIAN INI) =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Obx(() {
                    // Jika loading, mungkin bisa tampilkan skeleton atau loader
                    // Tapi di sini kita biarkan angka update real-time
                    return GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.35,
                      children: [
                        _StatCard(
                          title: 'Total Project',
                          value: c.isLoading.value
                              ? '...'
                              : c.totalProject.value.toString(),
                          onDetail: () {},
                        ),
                        _StatCard(
                          title: 'In Progress',
                          value: c.isLoading.value
                              ? '...'
                              : c.totalInProgress.value.toString(),
                          onDetail: () {},
                        ),
                        _StatCard(
                          title: 'Review',
                          value: c.isLoading.value
                              ? '...'
                              : c.totalReview.value.toString(),
                          onDetail: () {},
                        ),
                        _StatCard(
                          title: 'Selesai',
                          value: c.isLoading.value
                              ? '...'
                              : c.totalDone.value.toString(),
                          onDetail: () {},
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ========== HEADER UPDATE ==========
class _Header extends StatelessWidget {
  const _Header({required this.brand, required this.controller});

  final Color brand;
  final DashboardController controller; // Terima controller

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: brand,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... (Bagian Tracking & Setting biarkan sama) ...
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.location_on, size: 18, color: Color(0xFF2EC5FF)),
                  SizedBox(width: 6),
                  Text(
                    'Tracking',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => Get.toNamed(Routes.SETTING),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ===== Sapaan (DINAMIS) =====
          Obx(
            () => Text(
              'Halo ${controller.userName.value},', // Ambil dari Controller
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Text(
            'Selamat Datang',
            style: TextStyle(color: Colors.white70, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

// ========== QUICK ACTION ==========
class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.imagePath,
    required this.label,
    this.onTap,
  });

  final String imagePath;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap ?? () {},
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3F7),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset(imagePath, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

// ========== BOTTOM ITEM ==========
class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final Color ic = Colors.white.withOpacity(active ? 1.0 : 0.85);
    final Color tx = Colors.white.withOpacity(active ? 1.0 : 0.9);

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: ic),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: tx,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ========== STAT CARD ==========
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.onDetail,
  });

  final String title;
  final String value;
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E8EE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 30,
              height: 1,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
