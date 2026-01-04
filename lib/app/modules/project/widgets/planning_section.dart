// lib/app/modules/project_detail/widgets/planning_section.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../controllers/phase_controller.dart';
import '../controllers/requirement_controller.dart';
import '../controllers/design_controller.dart';
import '../controllers/development_controller.dart';

/// ===========================================================
///  PLANNING SECTION (Dokumen Kontrak + Kartu Dokumen + Timeline)
/// ===========================================================
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
  });

  final Color brand;
  final PhaseController phaseC;
  final String phaseName;
  final String requirementTag;
  final List<String> phases;
  final DateTime? startAt;

  /// opsional: untuk prefill “Belum ada dokumen” → nama/path file
  final String? initialContractPath;

  /// opsional: dipanggil saat file diganti
  final void Function(String? path)? onContractChanged;

  @override
  State<PlanningSection> createState() => _PlanningSectionState();
}

class _PlanningSectionState extends State<PlanningSection> {
  /// path/nama kontrak yang sedang aktif di detail ini
  String? _contractPath;

  @override
  void initState() {
    super.initState();
    _contractPath = widget.initialContractPath;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===================================================
        // 0) DOKUMEN KONTRAK
        // ===================================================
        _SectionCard(
          title: 'Dokumen Kontrak',
          child: _ContractPicker(
            brand: widget.brand,
            initialPath: _contractPath,
            onChanged: (path) {
              setState(() => _contractPath = path);
              widget.onContractChanged?.call(path);
            },
          ),
        ),

        const SizedBox(height: 16),

        // ===================================================
        // 1) KARTU DOKUMEN PLANNING
        // ===================================================
        _SectionCard(
          title: 'Planning – Dokumen',
          child: Row(
            children: [
              Obx(() {
                final planningDocs =
                    widget.phaseC.of(widget.phaseName).docs.length;

                // hitung kontrak sebagai 1 file kalau ada nama/path
                final hasContract =
                    _contractPath != null && _contractPath!.isNotEmpty;

                final count = planningDocs + (hasContract ? 1 : 0);

                return Text(
                  '$count file',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.brand.withOpacity(.12),
                  border:
                      Border.all(color: widget.brand.withOpacity(.25)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.phaseName,
                  style: TextStyle(
                    color: widget.brand,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ===================================================
        // 2) TIMELINE PROJECT (AUTOMATIS DARI REQUIREMENT / DESIGN / DEVELOPMENT)
        // ===================================================
        const _SectionTitle('Timeline Project'),
        const SizedBox(height: 8),

        Obx(() {
          final markerProgress = <String, RxDouble>{
            'Planning': 0.10.obs,
            'Requirement': 0.18.obs,
            'Design': 0.23.obs,
            'Development': 0.28.obs,
            'Testing': 0.32.obs,
            'Deployment': 0.38.obs,
            'Maintenance': 0.60.obs,
          };

          // ===== ambil controller =====
          final RequirementController? reqC =
              Get.isRegistered<RequirementController>(
                      tag: widget.requirementTag)
                  ? Get.find<RequirementController>(
                      tag: widget.requirementTag)
                  : null;

          // designTag dari requirementTag
          final designTag = widget.requirementTag.startsWith('req-')
              ? 'design-${widget.requirementTag.substring(4)}'
              : widget.requirementTag.replaceFirst('req', 'design');

          final DesignController? designC =
              Get.isRegistered<DesignController>(tag: designTag)
                  ? Get.find<DesignController>(tag: designTag)
                  : null;

          // devTag dari requirementTag
          final devTag = widget.requirementTag.startsWith('req-')
              ? 'dev-${widget.requirementTag.substring(4)}'
              : widget.requirementTag.replaceFirst('req', 'dev');

          final DevelopmentController? devC =
              Get.isRegistered<DevelopmentController>(tag: devTag)
                  ? Get.find<DevelopmentController>(tag: devTag)
                  : null;

          // ===== helper date =====
          DateTime? _minDate(Iterable<DateTime?> src) {
            DateTime? r;
            for (final d in src) {
              if (d == null) continue;
              if (r == null || d.isBefore(r)) r = d;
            }
            return r;
          }

          DateTime? _maxDate(Iterable<DateTime?> src) {
            DateTime? r;
            for (final d in src) {
              if (d == null) continue;
              if (r == null || d.isAfter(r)) r = d;
            }
            return r;
          }

          DateTime? _midDate(DateTime? s, DateTime? e) {
            if (s == null && e == null) return null;
            if (s == null) return e;
            if (e == null) return s;
            final diff = e.difference(s).inDays;
            return s.add(Duration(days: diff ~/ 2));
          }

          // ===== kumpulkan semua tanggal mulai & selesai dari 3 fase =====
          final allStarts = <DateTime?>[];
          final allEnds = <DateTime?>[];

          if (reqC != null && reqC.items.isNotEmpty) {
            allStarts.addAll(reqC.items.map((e) => e.startDate));
            allEnds.addAll(reqC.items.map((e) => e.endDate));
          }
          if (designC != null && designC.items.isNotEmpty) {
            allStarts.addAll(designC.items.map((e) => e.startDate));
            allEnds.addAll(designC.items.map((e) => e.endDate));
          }
          if (devC != null && devC.items.isNotEmpty) {
            allStarts.addAll(devC.items.map((e) => e.startDate));
            allEnds.addAll(devC.items.map((e) => e.endDate));
          }

          final now = DateTime.now();
          DateTime baseStart;
          int colCount;

          final globalMin = _minDate(allStarts);
          final globalMax = _maxDate(allEnds);

          if (globalMin != null && globalMax != null) {
            // mulai dari tanggal paling awal
            baseStart =
                DateTime(globalMin.year, globalMin.month, globalMin.day);

            // span hari + buffer 7 hari
            final spanDays = globalMax.difference(baseStart).inDays;
            colCount = spanDays + 7;
            if (colCount < 30) colCount = 30; // minimal 30 hari
            if (colCount > 120) colCount = 120; // batasi supaya tidak terlalu panjang
          } else {
            // fallback: awal bulan ini atau startAt
            baseStart =
                widget.startAt ?? DateTime(now.year, now.month, 1);
            colCount = 30;
          }

          double _dateToProgress(DateTime d) {
            final end = baseStart.add(Duration(days: colCount - 1));
            final total = end.difference(baseStart).inDays;
            if (total <= 0) return 0.0;
            final passed = d.difference(baseStart).inDays;
            final v = passed / total;
            return v.clamp(0.0, 1.0);
          }

          // ===== geser marker Requirement =====
          if (reqC != null && reqC.items.isNotEmpty) {
            final s = _minDate(reqC.items.map((e) => e.startDate));
            final e = _maxDate(reqC.items.map((e) => e.endDate));
            final mid = _midDate(s, e);
            if (mid != null) {
              markerProgress['Requirement']!.value =
                  _dateToProgress(mid);
            }
          }

          // ===== geser marker Design =====
          if (designC != null && designC.items.isNotEmpty) {
            final s = _minDate(designC.items.map((e) => e.startDate));
            final e = _maxDate(designC.items.map((e) => e.endDate));
            final mid = _midDate(s, e);
            if (mid != null) {
              markerProgress['Design']!.value = _dateToProgress(mid);
            }
          }

          // ===== geser marker Development =====
          if (devC != null && devC.items.isNotEmpty) {
            final s = _minDate(devC.items.map((e) => e.startDate));
            final e = _maxDate(devC.items.map((e) => e.endDate));
            final mid = _midDate(s, e);
            if (mid != null &&
                markerProgress.containsKey('Development')) {
              markerProgress['Development']!.value =
                  _dateToProgress(mid);
            }
          }

          return TimelineProjectCard(
            brand: widget.brand,
            phases: widget.phases,
            markerProgress: markerProgress,
            startAt: baseStart,
            colCount: colCount,
            colWidth: 56, // kolom kecil supaya muat banyak hari
          );
        }),
      ],
    );
  }
}

/// ===========================================================
///  SUBWIDGET: Section Card
/// ===========================================================
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEF1F6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0B1325),
            blurRadius: 18,
            offset: Offset(0, 8),
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
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// ===========================================================
///  SUBWIDGET: Judul Section
/// ===========================================================
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: Color(0xFF5C6A82),
      ),
    );
  }
}

/// ===========================================================
///  WIDGET: Dokumen Kontrak (chip nama file + tombol ganti/buka)
/// ===========================================================
class _ContractPicker extends StatefulWidget {
  const _ContractPicker({
    required this.brand,
    this.initialPath,
    this.onChanged,
  });

  final Color brand;
  final String? initialPath;
  final void Function(String? path)? onChanged;

  @override
  State<_ContractPicker> createState() => _ContractPickerState();
}

class _ContractPickerState extends State<_ContractPicker> {
  String? _path;
  Uint8List? _bytes;
  String? _name;
  String? _mime;

  @override
  void initState() {
    super.initState();
    _path = widget.initialPath;
    if (_path != null && _path!.isNotEmpty) {
      _name = p.basename(_path!);
    }
  }

  Future<String?> _savePickedFile(PlatformFile f) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = f.name.isNotEmpty
        ? f.name
        : 'contract_${DateTime.now().millisecondsSinceEpoch}${p.extension(f.path ?? f.name)}';
    final dest = File(p.join(dir.path, fileName));

    try {
      if (f.bytes != null) {
        await dest.writeAsBytes(f.bytes!, flush: true);
      } else if (f.path != null) {
        await File(f.path!).copy(dest.path);
      } else {
        return null;
      }
      return dest.path;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDoc = (_path != null && _path!.isNotEmpty) || _bytes != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // bar atas: label chip / placeholder
        Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F7),
                  border: Border.all(color: const Color(0xFFE6E8EE)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    if (_name == null || _name!.isEmpty)
                      const Text(
                        'Belum ada dokumen',
                        style: TextStyle(color: Color(0xFF6D7480)),
                      )
                    else
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.insert_drive_file, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _name!,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _path = null;
                                  _bytes = null;
                                  _name = null;
                                  _mime = null;
                                });
                                widget.onChanged?.call(null);
                              },
                              child: const Icon(Icons.close, size: 18),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // bar tombol
        Row(
          children: [
            // Ganti Dokumen
            ElevatedButton.icon(
              onPressed: () async {
                final res = await FilePicker.platform.pickFiles(
                  type: FileType.any,
                  withData: true,
                );
                final f = res?.files.single;
                if (f == null) return;

                _name = f.name;
                _mime =
                    lookupMimeType(f.name) ?? lookupMimeType(f.path ?? '');

                String? saved;
                if (!kIsWeb) {
                  saved = await _savePickedFile(f);
                }

                setState(() {
                  _path = saved; // null di web
                  _bytes = f.bytes; // untuk preview web
                });

                // parent selalu dapat nilai != null (kalau di web : nama file)
                final exposed = saved ?? _name;
                widget.onChanged?.call(exposed);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Dokumen dipilih: $_name')),
                  );
                }
              },
              icon: const Icon(Icons.attach_file),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.brand,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              label: const Text('Ganti Dokumen'),
            ),

            const SizedBox(width: 10),

            // Buka Dokumen
            OutlinedButton.icon(
              onPressed: hasDoc && (_path != null && _path!.isNotEmpty)
                  ? () => OpenFilex.open(_path!)
                  : null,
              icon: const Icon(Icons.open_in_new),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    hasDoc ? const Color(0xFF6D7480) : const Color(0xFFB8BDC8),
                side: BorderSide(
                  color: hasDoc
                      ? const Color(0xFFE6E8EE)
                      : const Color(0xFFEDEFF4),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              label: const Text('Buka Dokumen'),
            ),

            const SizedBox(width: 12),
            const Text('-', style: TextStyle(color: Color(0xFF6D7480))),
          ],
        ),

        // Preview sederhana
        if (hasDoc) ...[
          const SizedBox(height: 10),
          _DocPreviewInline(path: _path, bytes: _bytes, mime: _mime),
        ],
      ],
    );
  }
}

/// Kartu preview kecil (gambar → thumbnail, lainnya → bar info)
class _DocPreviewInline extends StatelessWidget {
  const _DocPreviewInline({this.path, this.bytes, this.mime});
  final String? path;
  final Uint8List? bytes;
  final String? mime;

  bool _isImage() {
    final lower = (mime ?? '').toLowerCase();
    if (lower.startsWith('image/')) return true;
    final name = path ?? '';
    final ext = p.extension(name).toLowerCase();
    return {'.png', '.jpg', '.jpeg', '.webp', '.gif'}.contains(ext);
  }

  @override
  Widget build(BuildContext context) {
    final hasPath = path != null && path!.isNotEmpty;
    final exists = hasPath ? File(path!).existsSync() : false;

    if (_isImage()) {
      if (hasPath && exists) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(path!),
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      }
      if (bytes != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            bytes!,
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      }
    }

    // default info bar
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E8EE)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasPath ? p.basename(path!) : 'Dokumen terpilih',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===========================================================
///  TIMELINE PROJECT (per hari, dinamis dengan tanggal input)
/// ===========================================================
class TimelineProjectCard extends StatefulWidget {
  const TimelineProjectCard({
    super.key,
    required this.brand,
    required this.phases,
    required this.markerProgress, // Map<String, RxDouble> 0..1
    this.startAt,
    this.colCount = 30, // default 30 hari
    this.colWidth = 56, // kolom kecil
  });

  final Color brand;
  final List<String> phases;
  final Map<String, RxDouble> markerProgress;

  final DateTime? startAt;
  final int colCount;
  final double colWidth;

  @override
  State<TimelineProjectCard> createState() => _TimelineProjectCardState();
}

class _TimelineProjectCardState extends State<TimelineProjectCard> {
  static const double _rowH = 56.0;
  static const double _leftW = 180.0;

  final _hCtrl = ScrollController();

  late DateTime _start;
  late List<DateTime> _ticks; // tanggal per kolom (HARI)
  late List<_MonthSpan> _monthSpans;

  @override
  void initState() {
    super.initState();
    _rebuildTicks();
  }

  @override
  void didUpdateWidget(covariant TimelineProjectCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startAt != widget.startAt ||
        oldWidget.colCount != widget.colCount) {
      _rebuildTicks();
    }
  }

  void _rebuildTicks() {
    _start = widget.startAt ?? DateTime(2025, 10, 1);

    // tiap kolom = 1 hari
    _ticks = List.generate(
      widget.colCount,
      (i) => _start.add(Duration(days: i)),
    );
    _monthSpans = _buildMonthSpans(_ticks);
  }

  List<_MonthSpan> _buildMonthSpans(List<DateTime> ticks) {
    final spans = <_MonthSpan>[];
    if (ticks.isEmpty) return spans;

    var curMonth = ticks.first.month;
    var startIdx = 0;

    for (var i = 1; i < ticks.length; i++) {
      if (ticks[i].month != curMonth) {
        spans.add(_MonthSpan(
          label: _monthName(curMonth),
          count: i - startIdx,
          startIndex: startIdx,
        ));
        curMonth = ticks[i].month;
        startIdx = i;
      }
    }
    spans.add(_MonthSpan(
      label: _monthName(curMonth),
      count: ticks.length - startIdx,
      startIndex: startIdx,
    ));
    return spans;
  }

  String _monthName(int m) {
    const en = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return en[m];
  }

  String _dateLabel(DateTime d, {bool withMonth = false}) {
    final dd = d.day.toString().padLeft(2, '0');
    return withMonth ? '$dd ${_monthName(d.month)}' : dd;
  }

  @override
  Widget build(BuildContext context) {
    final line = const Color(0xFFE9EDF3);
    final zebra = const Color(0xFFF7F9FC);
    final gridW = widget.colCount * widget.colWidth;

    Widget monthHeader() {
      return Row(
        children: [
          const SizedBox(width: _leftW),
          SizedBox(
            width: gridW,
            child: Row(
              children: _monthSpans.map((m) {
                return SizedBox(
                  width: m.count * widget.colWidth,
                  child: Center(
                    child: Text(
                      m.label,
                      style: const TextStyle(
                        color: Color(0xFF6D7480),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    }

    Widget dateHeader() {
      return Row(
        children: [
          const SizedBox(width: _leftW),
          SizedBox(
            width: gridW,
            child: Row(
              children: List.generate(widget.colCount, (i) {
                final withMonth =
                    (i == 0) || (_ticks[i].month != _ticks[i - 1].month);
                return SizedBox(
                  width: widget.colWidth,
                  child: Center(
                    child: Text(
                      _dateLabel(_ticks[i], withMonth: withMonth),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF6D7480),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      );
    }

    Widget gridRow(String label, int row) {
      final shaded = row.isEven;
      final rxProg = widget.markerProgress[label] ?? 0.0.obs;

      return SizedBox(
        height: _rowH,
        child: Row(
          children: [
            Container(
              width: _leftW,
              color: shaded ? zebra : Colors.white,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF545E6D),
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(
              width: gridW,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: shaded ? zebra : Colors.white,
                    ),
                  ),
                  Row(
                    children: List.generate(widget.colCount, (i) {
                      return SizedBox(
                        width: widget.colWidth,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: i == 0 ? Colors.transparent : line,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  Obx(() {
                    final col = ((rxProg.value.clamp(0.0, 1.0)) *
                            (widget.colCount - 1))
                        .round()
                        .clamp(0, widget.colCount - 1);
                    final left = col * widget.colWidth +
                        (widget.colWidth / 2) -
                        10;

                    return Positioned(
                      top: (_rowH - 22) / 2,
                      left: left,
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: widget.brand,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.10),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEF1F6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0B1325),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              'Timeline Project',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF5C6A82),
              ),
            ),
          ),
          Scrollbar(
            controller: _hCtrl,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _hCtrl,
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  monthHeader(),
                  Container(height: 1, color: line),
                  dateHeader(),
                  const SizedBox(height: 4),
                  Container(height: 1, color: line),
                  ...List.generate(widget.phases.length, (i) => Column(
                        children: [
                          gridRow(widget.phases[i], i),
                          Container(
                            margin:
                                const EdgeInsets.only(left: _leftW),
                            height: 1,
                            color: line,
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthSpan {
  _MonthSpan({
    required this.label,
    required this.count,
    required this.startIndex,
  });

  final String label;
  final int count;
  final int startIndex;
}
