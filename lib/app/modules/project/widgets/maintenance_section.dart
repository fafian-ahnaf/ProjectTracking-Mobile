import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/maintenance_controller.dart';

class MaintenanceSection extends StatefulWidget {
  const MaintenanceSection({
    super.key,
    required this.brand,
    required this.controllerTag,
  });

  final Color brand;
  final String controllerTag;

  @override
  State<MaintenanceSection> createState() => _MaintenanceSectionState();
}

class _MaintenanceSectionState extends State<MaintenanceSection> {
  late final MaintenanceController c;

  final _titleCtrl = TextEditingController();
  final _picCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _startDateCtrl = TextEditingController();
  final _endDateCtrl = TextEditingController();

  String _selectedStatus = 'Planned';
  DateTime? _startDate;
  DateTime? _endDate;
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<MaintenanceController>(tag: widget.controllerTag)) {
      Get.put(
        MaintenanceController(tagId: widget.controllerTag),
        tag: widget.controllerTag,
      );
    }
    c = Get.find<MaintenanceController>(tag: widget.controllerTag);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _picCtrl.dispose();
    _notesCtrl.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    super.dispose();
  }

  /* ================= DATE ================= */

  Future<void> _pickDate(BuildContext ctx, bool isStart) async {
    final picked = await showDatePicker(
      context: ctx,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _startDateCtrl.text = _fmt(picked);
        } else {
          _endDate = picked;
          _endDateCtrl.text = _fmt(picked);
        }
      });
    }
  }

  String _fmt(DateTime? d) {
    if (d == null) return '';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  /* ================= FORM ================= */

  void _openForm({int? editIndex}) {
    _editingIndex = editIndex;

    if (editIndex == null) {
      _titleCtrl.clear();
      _picCtrl.clear();
      _notesCtrl.clear();
      _selectedStatus = 'Planned';
      _startDate = null;
      _endDate = null;
      _startDateCtrl.clear();
      _endDateCtrl.clear();
    } else {
      final it = c.items[editIndex];
      _titleCtrl.text = it.title;
      _picCtrl.text = it.pic ?? '';
      _notesCtrl.text = it.notes ?? '';
      _selectedStatus = it.status;
      _startDate = it.startDate;
      _endDate = it.endDate;
      _startDateCtrl.text = _fmt(it.startDate);
      _endDateCtrl.text = _fmt(it.endDate);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        final media = MediaQuery.of(ctx);
        return Padding(
          padding: EdgeInsets.only(
            bottom: media.viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      editIndex == null
                          ? 'Tambah Maintenance'
                          : 'Edit Maintenance',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: _titleCtrl,
                  decoration: _fieldDecoration(
                    hint: 'Judul / Aktivitas Maintenance',
                  ),
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  isExpanded: true,
                  decoration: _fieldDecoration(hint: 'Status'),
                  items: c.statuses
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _selectedStatus = v ?? 'Planned'),
                ),
                const SizedBox(height: 10),

                // ===== TANGGAL MULAI =====
                TextField(
                  controller: _startDateCtrl,
                  readOnly: true,
                  onTap: () => _pickDate(ctx, true),
                  decoration: _fieldDecoration(
                    hint: 'Tanggal Mulai',
                  ).copyWith(
                    suffixIcon:
                        const Icon(Icons.calendar_today_outlined),
                  ),
                ),
                const SizedBox(height: 10),

                // ===== TANGGAL SELESAI =====
                TextField(
                  controller: _endDateCtrl,
                  readOnly: true,
                  onTap: () => _pickDate(ctx, false),
                  decoration: _fieldDecoration(
                    hint: 'Tanggal Selesai',
                  ).copyWith(
                    suffixIcon:
                        const Icon(Icons.calendar_today_outlined),
                  ),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _picCtrl,
                  decoration: _fieldDecoration(
                    hint: 'PIC / Penanggung Jawab (opsional)',
                  ),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  decoration: _fieldDecoration(
                    hint: 'Catatan (opsional)',
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => _submit(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.brand,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Simpan Maintenance'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submit(BuildContext ctx) {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Judul maintenance wajib diisi.')),
      );
      return;
    }

    if (_editingIndex == null) {
      c.add(
        title: title,
        status: _selectedStatus,
        pic: _picCtrl.text.trim().isEmpty ? null : _picCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
      );
    } else {
      c.updateAt(
        _editingIndex!,
        title: title,
        status: _selectedStatus,
        pic: _picCtrl.text.trim().isEmpty ? null : _picCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
      );
    }

    Navigator.pop(ctx);
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    const border = Color(0xFFEEF1F6);
    const zebra = Color(0xFFF7F9FC);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0B1325),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: widget.brand,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Pantau Progress Pekerjaanmu:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => _openForm(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFF69220),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Tambah Maintenance',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            child: Obx(() {
              if (c.items.isEmpty) {
                return const _EmptyMaintenanceView();
              }

              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
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
                          _HCell('#', 36),
                          _HCell('Judul', 200),
                          _HCell('Status', 110),
                          _HCell('Mulai', 110),
                          _HCell('Selesai', 110),
                          _HCell('Aksi', 120),
                        ],
                      ),
                    ),
                    Column(
                      children: List.generate(c.items.length, (i) {
                        final it = c.items[i];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(top: BorderSide(color: border)),
                          ),
                          child: Row(
                            children: [
                              _BCell('${i + 1}', 36),
                              _BCell(it.title, 200),
                              _BCell(it.status, 110),
                              _BCell(_fmt(it.startDate), 110),
                              _BCell(_fmt(it.endDate), 110),
                              SizedBox(
                                width: 120,
                                child: Row(
                                  children: [
                                    TextButton(
                                      onPressed: () =>
                                          _openForm(editIndex: i),
                                      child: const Text('Edit'),
                                    ),
                                    TextButton(
                                      onPressed: () => c.removeAt(i),
                                      child: const Text(
                                        'Hapus',
                                        style:
                                            TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      filled: true,
      fillColor: const Color(0xFFF4F6FA),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFFE6EAF0)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFFFF9A1E)),
      ),
    );
  }
}

/* ================= SUB WIDGET ================= */

class _EmptyMaintenanceView extends StatelessWidget {
  const _EmptyMaintenanceView();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      color: const Color(0xFFF7F8FC),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.folder_rounded,
              size: 54, color: Color(0xFFF69220)),
          SizedBox(height: 12),
          Text(
            'Belum Ada Aktivitas Maintenance',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
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
        maxLines: 2,
      ),
    );
  }
}
