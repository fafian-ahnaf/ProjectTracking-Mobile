import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reports_controller.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  Color get brand => const Color(0xFFF69220); // Oranye Brand

  @override
  Widget build(BuildContext context) {
    // Inject Controller
    Get.put(ReportsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Laporan & Statistik'),
        backgroundColor: brand,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export CSV',
            onPressed: () => controller.exportToCsv(),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.fetchReport,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ===== 1. Filter Section =====
              _buildFilterSection(context),
              const SizedBox(height: 16),

              // ===== 2. Statistik Cards =====
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Total Project',
                      value: '${controller.totalProjects.value}',
                      icon: Icons.folder,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Rata-rata Progress',
                      value: '${controller.avgProgress.value}%',
                      icon: Icons.trending_up,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Status Breakdown (Todo, In Progress, etc)
              _buildStatusBreakdown(),
              
              const SizedBox(height: 20),

              // ===== 3. Bar Chart (Project per Bulan) =====
              _buildBarChartSection(),

              const SizedBox(height: 20),

              // ===== 4. List Project Terkait =====
              const Text(
                'Daftar Project',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF5C6A82)),
              ),
              const SizedBox(height: 10),
              
              if (controller.projects.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: Text("Tidak ada data project pada periode ini.")),
                )
              else
                ...controller.projects.map((p) => Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey.shade200)
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${p.status} • PIC: ${p.pic ?? "-"}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: brand.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6)
                      ),
                      child: Text('${p.overallProgress}%', style: TextStyle(fontWeight: FontWeight.bold, color: brand)),
                    ),
                  ),
                )).toList(),
                
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final start = controller.startDate.value;
    final end = controller.endDate.value;
    final label = (start != null && end != null)
        ? '${_fmt(start)} - ${_fmt(end)}'
        : 'Filter Tanggal (Semua)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: () => controller.pickDateRange(context),
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
          ),
          if (start != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: controller.clearFilter,
            )
          else
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdown() {
    final data = controller.statusBreakdown;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Status Project', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatusItem('Todo', data['todo'] ?? 0, Colors.grey),
              _StatusItem('Progress', data['in_progress'] ?? 0, Colors.blue),
              _StatusItem('Review', data['review'] ?? 0, Colors.orange),
              _StatusItem('Done', data['done'] ?? 0, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartSection() {
    final labels = controller.chartLabels;
    final values = controller.chartValues;
    
    // Jika data kosong
    if (labels.isEmpty) return const SizedBox.shrink();

    // Cari nilai max untuk skala chart
    int maxValue = 1;
    if (values.isNotEmpty) {
      maxValue = values.reduce((curr, next) => curr > next ? curr : next);
    }
    if (maxValue == 0) maxValue = 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Project Baru per Bulan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(labels.length, (i) {
                final count = values[i];
                final heightFactor = count / maxValue;
                final barHeight = 150.0 * heightFactor; // Max height 150

                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Column(
                    children: [
                      Text('$count', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      Container(
                        width: 30,
                        height: barHeight == 0 ? 2 : barHeight, // Minimal 2px biar kelihatan garisnya
                        decoration: BoxDecoration(
                          color: barHeight == 0 ? Colors.grey.shade200 : brand,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        labels[i], // Jan 2025
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

// Widget Kecil untuk Kartu Statistik
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        ],
      ),
    );
  }
}

// Widget Item Status
class _StatusItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatusItem(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$count', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}