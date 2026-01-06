import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:project_tracking/app/data/models/project_item.dart';
import 'package:project_tracking/app/modules/project/controllers/timeline_controller.dart';
import '../controllers/phase_controller.dart';
import '../controllers/planning_controller.dart';
import 'package:intl/intl.dart';

class PlanningSection extends StatefulWidget {
  const PlanningSection({
    super.key,
    required this.brand,
    required this.phaseC,
    this.phaseName = 'Planning',
    required this.requirementTag,
    required this.phases,
    this.startAt,
    this.initialContractPath,
    this.onContractChanged,
    required this.projectId,
  });

  final Color brand;
  final PhaseController phaseC;
  final String phaseName;
  final String requirementTag;
  final List<String> phases;
  final DateTime? startAt;
  final String? initialContractPath;
  final void Function(String? path)? onContractChanged;
  final int projectId;

  @override
  State<PlanningSection> createState() => _PlanningSectionState();
}

class _PlanningSectionState extends State<PlanningSection> {
  late PlanningController controller;

  // Controller untuk Input
  final TextEditingController _noteC = TextEditingController();
  final TextEditingController _activityC =
      TextEditingController(); // Untuk Judul

  late TimelineController timelineC;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      PlanningController(widget.projectId),
      tag: 'planning-${widget.projectId}',
    );

    // Sync data dari Server ke TextField saat data masuk
    ever(controller.planningNote, (val) {
      if (_noteC.text != val) _noteC.text = val;
    });

    ever(controller.planningActivity, (val) {
      if (_activityC.text != val) _activityC.text = val;
    });

    timelineC = Get.put(
      TimelineController(widget.projectId),
      tag: 'timeline-${widget.projectId}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Dokumen Kontrak Utama (Sesuai kode lama)
        _SectionCard(
          title: 'Dokumen Kontrak Utama',
          child: Text(
            widget.initialContractPath != null
                ? "File: ${widget.initialContractPath!.split('/').last}"
                : "Belum ada kontrak utama (Edit di menu Project)",
            style: const TextStyle(color: Colors.black54),
          ),
        ),

        const SizedBox(height: 16),

        // ===================================================
        // 2. FORM AKTIVITAS & CATATAN (UPDATE DISINI)
        // ===================================================
        _SectionCard(
          title: 'Kegiatan & Analisa',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // INPUT 1: JUDUL KEGIATAN (ACTIVITY)
              const Text(
                "Judul Kegiatan / Aktivitas",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _activityC,
                decoration: InputDecoration(
                  hintText: 'Contoh: Kickoff Meeting dengan Client',
                  filled: true,
                  fillColor: const Color(0xFFF9FAFC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // INPUT 2: CATATAN DETAIL (NOTE)
              const Text(
                "Catatan Detail",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _noteC,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'Tulis hasil analisa atau catatan penting di sini...',
                  filled: true,
                  fillColor: const Color(0xFFF9FAFC),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // TOMBOL SIMPAN
              Align(
                alignment: Alignment.centerRight,
                child: Obx(
                  () => ElevatedButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            // Panggil saveChanges dengan Activity & Note
                            controller.saveChanges(
                              newActivity: _activityC.text,
                              newNote: _noteC.text,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.brand,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: controller.isLoading.value
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Simpan Update'),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 3. File Pendukung Planning
        _SectionCard(
          title: 'File Pendukung Planning',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                if (controller.files.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Belum ada file pendukung.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                }
                return Column(
                  children: controller.files.map((file) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.insert_drive_file,
                            color: Colors.orangeAccent,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  file['original_name'] ?? 'File',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'ID: ${file['id']}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.visibility,
                              size: 18,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              if (file['url'] != null)
                                OpenFilex.open(file['url']);
                            },
                            tooltip: 'Buka',
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red,
                            ),
                            onPressed: () => controller.deleteFile(file['id']),
                            tooltip: 'Hapus',
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => OutlinedButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.pickAndUploadFiles,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: widget.brand,
                      side: BorderSide(color: widget.brand),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload File Tambahan'),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 4. Timeline (Placeholder / Widget lama)
        const Text(
          'Timeline Aktivitas',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFF5C6A82),
          ),
        ),
        const SizedBox(height: 12),

        Obx(() {
          if (timelineC.isLoading.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (timelineC.activities.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEF1F6)),
              ),
              child: const Center(
                child: Text(
                  "Belum ada riwayat aktivitas.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEF1F6)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: timelineC.activities.map((act) {
                return _buildTimelineItem(act, widget.brand);
              }).toList(),
            ),
          );
        }),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEF1F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF5C6A82),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

Widget _buildTimelineItem(ActivityItem item, Color brand) {
  // Format Tanggal: "5 Jan 2026"
  final dateStr = item.occurredAt != null
      ? DateFormat('d MMM yyyy').format(item.occurredAt!)
      : '-';

  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Garis & Dot
        Column(
          children: [
            Icon(Icons.circle, size: 12, color: brand),
            Container(
              width: 2,
              height: 40, // Tinggi garis penghubung
              color: Colors.grey.shade200,
            ),
          ],
        ),
        const SizedBox(width: 12),
        // Konten
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateStr,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (item.description != null && item.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    item.description!,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
