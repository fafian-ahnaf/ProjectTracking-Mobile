// lib/app/modules/project_detail/views/project_detail_view.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;

import 'package:project_tracking/app/data/models/project_item.dart';

// controllers & widgets lokal
import '../controllers/phase_controller.dart';
import '../controllers/requirement_controller.dart';
import '../widgets/requirement_section.dart';
import '../widgets/planning_section.dart';
import '../widgets/design_section.dart';
import '../widgets/development_section.dart';
import '../widgets/testing_section.dart';
import '../widgets/deployment_section.dart';
import '../widgets/maintenance_section.dart'; // ✅ TAMBAHAN: MaintenanceSection

class ProjectDetailView extends StatefulWidget {
  final ProjectItem item;
  final Color brand;

  const ProjectDetailView({super.key, required this.item, required this.brand});

  @override
  State<ProjectDetailView> createState() => _ProjectDetailViewState();
}

class _ProjectDetailViewState extends State<ProjectDetailView> {
  static const List<String> _phases = [
    'Planning',
    'Requirement',
    'Design',
    'Development',
    'Testing',
    'Deployment',
    'Maintenance',
  ];

  late final PhaseController phaseC;
  late int _active;

  String _fmt(DateTime? d) => d == null
      ? '-'
      : '${d.day.toString().padLeft(2, '0')}/'
            '${d.month.toString().padLeft(2, '0')}/'
            '${d.year}';

  int _initialSdlcStep(ProjectItem it) {
    final s = (it.status).toLowerCase();
    if (s.contains('plan')) return 0;
    if (s.contains('requir')) return 1;
    if (s.contains('design')) return 2;
    if (s.contains('develop') || s.contains('progress')) return 3;
    if (s.contains('test') || s.contains('review')) return 4;
    if (s.contains('deploy')) return 5;
    if (s.contains('mainten') || s.contains('selesai') || s.contains('done')) {
      return 6;
    }

    final pgr = it.progress.clamp(0, 100);
    if (pgr < 5) return 0;
    if (pgr < 15) return 1;
    if (pgr < 30) return 2;
    if (pgr < 70) return 3;
    if (pgr < 85) return 4;
    if (pgr < 95) return 5;
    return 6;
  }

  @override
  void initState() {
    super.initState();
    _active = _initialSdlcStep(widget.item);

    // tag unik per project
    final phaseTag = 'phase-${widget.item.hashCode}';
    final reqTag = 'req-${widget.item.hashCode}';

    // Phase controller
    phaseC = Get.put(
      PhaseController(phases: _phases, defaultPic: widget.item.pic ?? ''),
      tag: phaseTag,
    );

    // Requirement controller
    Get.put(RequirementController(), tag: reqTag);
  }

  @override
  void dispose() {
    Get.delete<PhaseController>(
      tag: 'phase-${widget.item.hashCode}',
      force: true,
    );
    Get.delete<RequirementController>(
      tag: 'req-${widget.item.hashCode}',
      force: true,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final brand = widget.brand;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Detail Project'),
        backgroundColor: brand,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // ===== Header: nama + deskripsi + status pill (TETAP) =====
          _DetailCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (item.activity ?? '').isEmpty
                            ? ((item.pic ?? '').isEmpty
                                  ? '-'
                                  : (item.pic ?? '-'))
                            : (item.activity ?? '-'),
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                _StatusPill(text: item.status, brand: brand),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ===== 3 KARTU MINI (UPDATE BAGIAN PROGRES) =====
          Row(
            children: [
              Expanded(
                child: _MiniStatCard(
                  title: 'Overall Progres', // Label diganti
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔥 GANTI: Pakai item.overallProgress dari API
                      Text(
                        '${item.overallProgress}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Bar visual
                      _ProgressBar(
                        percent: item.overallProgress.toDouble(),
                        knobColor: brand,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Kartu Dokumen Planning (TETAP)
              Expanded(
                child: Obx(() {
                  final docs = phaseC.of('Planning').docs.length;
                  return _MiniStatCard(
                    title: 'Dokumen Plan',
                    child: Text(
                      '$docs',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 12),
              // Kartu Requirement (TETAP)
              Expanded(
                child: Obx(() {
                  final reqC = Get.find<RequirementController>(
                    tag: 'req-${widget.item.hashCode}',
                  );
                  final pct = (reqC.progress.value * 100).round();
                  return _MiniStatCard(
                    title: 'Req. Progress',
                    child: Text(
                      '$pct%',
                      style: const TextStyle(
                        fontSize: 20, // Samakan size biar rapi
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 🔥🔥🔥 BARU: BREAKDOWN SDLC PROGRESS (DARI API) 🔥🔥🔥
          if (item.sdlcProgress != null && item.sdlcProgress!.isNotEmpty) ...[
            _DetailCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Progres Fase (SDLC)',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  // Loop data dari Map sdlcProgress
                  ...item.sdlcProgress!.entries.map((e) {
                    final label = e.key
                        .toUpperCase(); // Requirement, Design, dll
                    final val = (e.value is int) ? e.value : 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                '$val%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: val / 100.0,
                            backgroundColor: const Color(0xFFF0F0F0),
                            color: brand, // Warna oranye brand
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // ===== Tabs SDLC + Section per fase + Ringkasan/Timeline Aktivitas
          _DetailCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tabs SDLC
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_phases.length, (i) {
                      final selected = i == _active;
                      return Padding(
                        padding: EdgeInsets.only(
                          right: i == _phases.length - 1 ? 0 : 8,
                        ),
                        child: InkWell(
                          onTap: () => setState(() => _active = i),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? widget.brand
                                  : const Color(0xFFEDE8E8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _phases[i],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF1C1C1C),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 12),

                // === Planning Section
                if (_phases[_active] == 'Planning') ...[
                  PlanningSection(
                    brand: widget.brand,
                    phaseC: phaseC,
                    phases: _phases,
                    requirementTag: 'req-${widget.item.hashCode}',
                    phaseName: 'Planning',
                    // 🔥 TAMBAHKAN INI:
                    projectId: widget.item.id!,
                    initialContractPath: widget.item.documentPath,
                  ),
                  const SizedBox(height: 12),
                ],

                // === Requirement Section
                if (_phases[_active] == 'Requirement') ...[
                  RequirementSection(
                    brand: widget.brand,
                    controllerTag: 'req-${widget.item.hashCode}',
                    projectId: widget.item.id!,
                  ),
                  const SizedBox(height: 12),
                ],

                // === Design Section
                if (_phases[_active] == 'Design') ...[
                  DesignSection(
                    brand: widget.brand,
                    controllerTag: 'design-${widget.item.hashCode}',
                    requirementTag: 'req-${widget.item.hashCode}',
                    // 🔥🔥 WAJIB DITAMBAHKAN AGAR TIDAK ERROR 🔥🔥
                    projectId: widget.item.id!,
                  ),
                  const SizedBox(height: 12),
                ],

                // === Development Section
                // ...
                if (_phases[_active] == 'Development') ...[
                  DevelopmentSection(
                    brand: widget.brand,
                    controllerTag: 'dev-${widget.item.hashCode}',
                    designTag: 'design-${widget.item.hashCode}',
                    // 🔥 JANGAN LUPA:
                    projectId: widget.item.id!,
                  ),
                  const SizedBox(height: 12),
                ],
                // ...

                // === Testing Section
                if (_phases[_active] == 'Testing') ...[
                  TestingSection(
                    brand: widget.brand,
                    controllerTag: 'test-${widget.item.hashCode}',
                    requirementTag: 'req-${widget.item.hashCode}',
                    designTag: 'design-${widget.item.hashCode}',
                    // 🔥 WAJIB:
                    projectId: widget.item.id!,
                  ),
                  const SizedBox(height: 12),
                ],

                // === Deployment Section
                if (_phases[_active] == 'Deployment') ...[
                  DeploymentSection(
                    brand: widget.brand,
                    controllerTag: 'deploy-${widget.item.hashCode}',
                    // 🔥 WAJIB:
                    projectId: widget.item.id!,
                  ),
                  const SizedBox(height: 12),
                ],

                // === Maintenance Section ✅
                if (_phases[_active] == 'Maintenance') ...[
                  MaintenanceSection(
                    brand: widget.brand,
                    controllerTag: 'maint-${widget.item.hashCode}',
                    // 🔥 WAJIB:
                    projectId: widget.item.id!,
                  ),
                  const SizedBox(height: 12),
                ],

                // Ringkasan & Timeline Aktivitas
                LayoutBuilder(
                  builder: (context, c) {
                    final isWide = c.maxWidth >= 720;

                    final left = _CardSection(
                      title: 'Ringkasan',
                      child: Column(
                        children: [
                          _KVRow(label: 'Nama Proyek', value: item.name),
                          _KVRow(
                            label: 'PIC',
                            value: (item.pic ?? '').isEmpty
                                ? '-'
                                : (item.pic ?? '-'),
                          ),
                          _KVRow(label: 'Status', value: item.status),
                          _KVRow(label: 'Mulai', value: _fmt(item.startDate)),
                          _KVRow(label: 'Selesai', value: _fmt(item.endDate)),
                          _KVRow(
                            label: 'Kegiatan',
                            value: (item.activity ?? '').isEmpty
                                ? '-'
                                : (item.activity ?? '-'),
                          ),
                        ],
                      ),
                    );

                    final right = _CardSection(
                      title: 'Timeline Project',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ActivityDot(
                            brand: widget.brand,
                            text: 'Project dibuat',
                            date: item.startDate,
                          ),
                          const SizedBox(height: 6),
                          Obx(() {
                            final notes = phaseC
                                .of(_phases[_active])
                                .notes
                                .trim();
                            if (notes.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  'Belum ada catatan untuk fase ini.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              );
                            }
                            return _ActivityDot(
                              brand: widget.brand,
                              text: notes,
                              date: null,
                              filled: false,
                            );
                          }),
                        ],
                      ),
                    );

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: left),
                          const SizedBox(width: 12),
                          Expanded(child: right),
                        ],
                      );
                    }
                    return Column(
                      children: [left, const SizedBox(height: 12), right],
                    );
                  },
                ),

                const SizedBox(height: 12),

                // caption fase aktif
                Obx(() {
                  final d = phaseC.of(_phases[_active]);
                  return Text(
                    'Fase aktif: ${_phases[_active]}. '
                    '${d.notes.isEmpty ? "Tambahkan catatan atau checklist untuk fase ini." : d.notes}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF444444),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ===== Dokumen / Catatan
          // _DetailCard(
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       const Text(
          //         'Dokumen / Catatan',
          //         style: TextStyle(fontWeight: FontWeight.w700),
          //       ),
          //       const SizedBox(height: 8),
          //       Obx(() {
          //         final notes = phaseC.of(_phases[_active]).notes.trim();
          //         return Text(
          //           notes.isEmpty
          //               ? ((item.activity ?? '').isEmpty
          //                     ? '-'
          //                     : (item.activity ?? '-'))
          //               : notes,
          //         );
          //       }),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

/* ---------------- Widgets kecil ---------------- */

class _StatusPill extends StatelessWidget {
  final String text;
  final Color brand;

  const _StatusPill({required this.text, required this.brand});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: brand.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _MiniStatCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double percent;
  final Color knobColor;

  const _ProgressBar({required this.percent, required this.knobColor});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final p = (percent.clamp(0, 100)) / 100.0;
        final w = c.maxWidth;
        final knobX = (w - 12) * p; // 12 = diameter knob
        return Stack(
          children: [
            Container(
              height: 4,
              decoration: const BoxDecoration(color: Color(0xFFDDDDDD)),
            ),
            Positioned(
              left: 0,
              right: w - (w * p),
              child: Container(height: 4, color: Colors.black26),
            ),
            Positioned(
              left: knobX,
              top: -6,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: knobColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ActivityDot extends StatelessWidget {
  final Color brand;
  final String text;
  final DateTime? date;
  final bool filled;

  const _ActivityDot({
    required this.brand,
    required this.text,
    this.date,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    final d = date;
    final ts = d == null
        ? ''
        : 'buat pada ${d.day.toString().padLeft(2, '0')} '
              '${_monthName(d.month)} ${d.year}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          filled ? Icons.circle : Icons.radio_button_checked,
          size: 14,
          color: brand,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ts.isNotEmpty)
                Text(
                  ts,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              Text(text),
            ],
          ),
        ),
      ],
    );
  }
}

String _monthName(int m) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return months[(m - 1).clamp(0, 11)];
}

// Masih sama seperti versi sebelumnya
class _DetailCard extends StatelessWidget {
  final Widget child;

  const _DetailCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E6)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _CardSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _KVRow extends StatelessWidget {
  final String label;
  final String value;

  const _KVRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEAEAEA))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// Preview dokumen
class _DocPreviewCard extends StatelessWidget {
  final String path;
  final Color brand;

  const _DocPreviewCard({required this.path, required this.brand});

  bool _isImage(String pth) {
    final ext = p.extension(pth).toLowerCase();
    return {'.png', '.jpg', '.jpeg', '.webp', '.gif'}.contains(ext);
  }

  bool _isPdf(String pth) => p.extension(pth).toLowerCase() == '.pdf';

  @override
  Widget build(BuildContext context) {
    final exists = File(path).existsSync();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E6)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: !exists
          ? Row(
              children: [
                const Icon(Icons.error_outline),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'File tidak ditemukan: ${p.basename(path)}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          : _isImage(path)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(path),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        p.basename(path),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => OpenFilex.open(path),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('Buka'),
                      style: TextButton.styleFrom(foregroundColor: brand),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Icon(
                  _isPdf(path)
                      ? Icons.picture_as_pdf
                      : Icons.description_outlined,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    p.basename(path),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => OpenFilex.open(path),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('Buka Dokumen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brand,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                ),
              ],
            ),
    );
  }
}
