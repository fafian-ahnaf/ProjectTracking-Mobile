import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/design_controller.dart';
import 'package:project_tracking/app/modules/project/controllers/requirement_controller.dart';

class DesignSection extends StatefulWidget {
  const DesignSection({
    super.key,
    required this.brand,
    required this.controllerTag,   // contoh: 'design-${project.hashCode}'
    required this.requirementTag,  // contoh: 'req-${project.hashCode}'
  });

  final Color brand;
  final String controllerTag;
  final String requirementTag;

  @override
  State<DesignSection> createState() => _DesignSectionState();
}

class _DesignSectionState extends State<DesignSection> {
  late final DesignController c;

  // form state
  String? _selectedReq;
  String _selectedType = 'UI';
  String _selectedStatus = 'Planned';

  final _artifactCtrl = TextEditingController();
  final _linkCtrl     = TextEditingController();
  final _notesCtrl    = TextEditingController();
  final _metaCtrl     = TextEditingController();

  // PIC + tanggal mulai / selesai untuk design
  final _picCtrl   = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl   = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();

    // DesignController untuk section ini
    if (!Get.isRegistered<DesignController>(tag: widget.controllerTag)) {
      Get.put(
        DesignController(tagId: widget.controllerTag),
        tag: widget.controllerTag,
      );
    }
    c = Get.find<DesignController>(tag: widget.controllerTag);
  }

  /// Selalu ambil RequirementController terbaru
  RequirementController? get reqC {
    if (Get.isRegistered<RequirementController>(tag: widget.requirementTag)) {
      return Get.find<RequirementController>(tag: widget.requirementTag);
    }
    return null;
  }

  @override
  void dispose() {
    _artifactCtrl.dispose();
    _linkCtrl.dispose();
    _notesCtrl.dispose();
    _metaCtrl.dispose();
    _picCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '-';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return '$dd/$mm/$yy';
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final current = isStart ? (_startDate ?? now) : (_endDate ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _startCtrl.text = _fmtDate(picked);
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = picked;
            _endCtrl.text = _fmtDate(picked);
          }
        } else {
          _endDate = picked;
          _endCtrl.text = _fmtDate(picked);
        }
      });
    }
  }

  void _submit() {
    final req  = _selectedReq ?? '';
    final name = _artifactCtrl.text.trim();

    if (req.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih requirement dan isi nama artefak.')),
      );
      return;
    }

    c.add(
      requirement: req,
      type: _selectedType,
      artifactName: name,
      status: _selectedStatus,
      reference: _linkCtrl.text.trim().isEmpty ? null : _linkCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      meta: _metaCtrl.text.trim().isEmpty ? null : _metaCtrl.text.trim(),
      pic: _picCtrl.text.trim().isEmpty ? null : _picCtrl.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
    );

    _artifactCtrl.clear();
    _linkCtrl.clear();
    _notesCtrl.clear();
    _metaCtrl.clear();
    _picCtrl.clear();
    _startCtrl.clear();
    _endCtrl.clear();
    _startDate = null;
    _endDate = null;

    setState(() {
      _selectedStatus = 'Planned';
      _selectedType   = 'UI';
    });
  }

  @override
  Widget build(BuildContext context) {
    const border = Color(0xFFEEF1F6);
    const zebra  = Color(0xFFF7F9FC);

    // opsi requirement (aman kalau controller belum ada)
    final List<String> reqOptions =
        reqC == null ? <String>[] : reqC!.items.map((e) => e.title).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(18),
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
          // 🔹 TITLE + PROGRESS BAR
          const _SectionTitle(
            'Design Specification (terhubung ke Requirement)',
          ),
          const SizedBox(height: 4),
          Obx(() {
            final pct = (c.progress.value * 100).round();
            return _ProgressLine(
              value: c.progress.value,    // 0..1 dari DesignController
              brand: widget.brand,
              label: '$pct%',
            );
          }),
          const SizedBox(height: 16),

          // ===== Row input
          Wrap(
            runSpacing: 12,
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Requirement
              _Box(
                width: 280,
                child: DropdownButtonFormField<String>(
                  value: _selectedReq,
                  isExpanded: true,
                  hint: const Text('— Pilih Requirement —'),
                  items: reqOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedReq = v),
                  decoration: _fieldDecoration(),
                ),
              ),

              // PIC design
              _Box(
                width: 180,
                child: TextField(
                  controller: _picCtrl,
                  decoration: _fieldDecoration(hint: 'PIC design'),
                ),
              ),

              // Tanggal mulai design
              _Box(
                width: 160,
                child: GestureDetector(
                  onTap: () => _pickDate(isStart: true),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _startCtrl,
                      decoration: _fieldDecoration(hint: 'Tanggal mulai'),
                    ),
                  ),
                ),
              ),

              // Tanggal selesai design
              _Box(
                width: 160,
                child: GestureDetector(
                  onTap: () => _pickDate(isStart: false),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _endCtrl,
                      decoration: _fieldDecoration(hint: 'Tanggal selesai'),
                    ),
                  ),
                ),
              ),

              // Tipe
              _Box(
                width: 150,
                child: DropdownButtonFormField<String>(
                  value: _selectedType,
                  isExpanded: true,
                  items: c.types
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedType = v ?? 'UI'),
                  decoration: _fieldDecoration(),
                ),
              ),

              // Nama artefak
              _Box(
                width: 280,
                child: TextField(
                  controller: _artifactCtrl,
                  decoration: _fieldDecoration(
                    hint: 'Nama komponen / endpoint / tabel',
                  ),
                ),
              ),

              // Status
              _Box(
                width: 160,
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  isExpanded: true,
                  items: c.statuses
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _selectedStatus = v ?? 'Planned'),
                  decoration: _fieldDecoration(),
                ),
              ),

              // Link referensi
              _Box(
                width: 360,
                child: TextField(
                  controller: _linkCtrl,
                  decoration: _fieldDecoration(
                    hint: 'Link Figma / Postman / ERD (opsional)',
                  ),
                ),
              ),

              // Notes
              _Box(
                width: 420,
                child: TextField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  decoration: _fieldDecoration(
                    hint: 'Alasan desain / catatan teknis (opsional)',
                  ),
                ),
              ),

              // Meta kecil opsional
              _Box(
                width: 160,
                child: TextField(
                  controller: _metaCtrl,
                  decoration: _fieldDecoration(hint: 'Meta (ops.)'),
                ),
              ),

              // Tombol tambah
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.brand,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Tambahkan'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ====== TABEL
          Builder(builder: (context) {
            final double tableMinW =
                64 + 220 + 120 + 110 + 110 + 80 + 240 + 110 + 240 + 80;

            return Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: tableMinW),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: zebra,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: const [
                              _HCell('#', 64),
                              _HCell('Design', 220),
                              _HCell('PIC', 120),
                              _HCell('Mulai', 110),
                              _HCell('Selesai', 110),
                              _HCell('Tipe', 80),
                              _HCell('Nama Artefak', 240),
                              _HCell('Status', 110),
                              _HCell('Referensi', 240),
                              _HCell('Aksi', 80),
                            ],
                          ),
                        ),

                        // Body
                        Obx(() {
                          if (c.items.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text('Belum ada design spec.'),
                            );
                          }
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(c.items.length, (i) {
                              final it = c.items[i];
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: border),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // ✅ checkbox + nomor baris (#)
                                    _RowIndexWithCheck(
                                      index: i + 1,
                                      width: 64,
                                    ),
                                    _BCell(it.requirement, 220),
                                    _BCell(it.pic ?? '-', 120),
                                    _BCell(_fmtDate(it.startDate), 110),
                                    _BCell(_fmtDate(it.endDate), 110),
                                    _BCell(it.type, 80),
                                    _BCell(it.artifactName, 240),
                                    _BCell(it.status, 110),
                                    _BCell(it.reference ?? '-', 240),
                                    // 🔹 Aksi: ubah status + hapus
                                    SizedBox(
                                      width: 80,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          PopupMenuButton<String>(
                                            tooltip: 'Ubah status',
                                            onSelected: (v) =>
                                                c.setStatus(it.id, v),
                                            itemBuilder: (_) => const [
                                              PopupMenuItem(
                                                value: 'Planned',
                                                child: Text('Set Draft'),
                                              ),
                                              PopupMenuItem(
                                                value: 'In Progress',
                                                child:
                                                    Text('Set In Progress'),
                                              ),
                                              PopupMenuItem(
                                                value: 'Done',
                                                child: Text('Set Done'),
                                              ),
                                            ],
                                            child: const Icon(
                                              Icons.more_vert,
                                              size: 20,
                                            ),
                                          ),
                                          IconButton(
                                            tooltip: 'Hapus',
                                            onPressed: () => c.removeAt(i),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({String? hint}) => InputDecoration(
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: const Color(0xFFFDFDFE),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFFE6EAF0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFFF9A1E)),
        ),
      );
}

/* ---------- sub-widgets kecil ---------- */

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF5C6A82),
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.child, required this.width});
  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, child: child);
  }
}

class _HCell extends StatelessWidget {
  const _HCell(this.text, this.w);
  final String text;
  final double w;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: w,
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF5C6A82),
        ),
      ),
    );
  }
}

class _BCell extends StatelessWidget {
  const _BCell(this.text, this.w);
  final String text;
  final double w;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: w,
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      ),
    );
  }
}

/// Kolom nomor + checkbox (seperti di Requirement)
class _RowIndexWithCheck extends StatefulWidget {
  const _RowIndexWithCheck({
    super.key,
    required this.index,
    required this.width,
  });

  final int index;
  final double width;

  @override
  State<_RowIndexWithCheck> createState() => _RowIndexWithCheckState();
}

class _RowIndexWithCheckState extends State<_RowIndexWithCheck> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: Checkbox(
              value: _checked,
              onChanged: (v) => setState(() => _checked = v ?? false),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.index}',
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Progress bar tipis seperti contoh (bar + label % di kanan)
class _ProgressLine extends StatelessWidget {
  const _ProgressLine({
    required this.value,
    required this.brand,
    required this.label,
  });

  final double value; // 0..1
  final Color brand;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: const Color(0xFFE4E6ED),
                valueColor: AlwaysStoppedAnimation<Color>(brand),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF384152),
          ),
        ),
      ],
    );
  }
}
