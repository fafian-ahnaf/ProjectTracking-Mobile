import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/design_controller.dart';
import '../controllers/development_controller.dart';

class DevelopmentSection extends StatefulWidget {
  const DevelopmentSection({
    super.key,
    required this.brand,
    required this.controllerTag, // 'dev-${project.hashCode}'
    required this.designTag,     // 'design-${project.hashCode}'
  });

  final Color brand;
  final String controllerTag;
  final String designTag;

  @override
  State<DevelopmentSection> createState() => _DevelopmentSectionState();
}

class _DevelopmentSectionState extends State<DevelopmentSection> {
  late final DevelopmentController devC;
  DesignController? designC;

  // form state
  int? _selectedDesignIndex;
  String _status = 'In Progress';

  final _devNameCtrl = TextEditingController();

  // PIC & tanggal mulai / selesai
  final TextEditingController _picCtrl = TextEditingController();
  final TextEditingController _metaCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  // edit state
  bool _isEditing = false;
  int? _editingIndex;

  @override
  void initState() {
    super.initState();

    // Development controller
    if (!Get.isRegistered<DevelopmentController>(tag: widget.controllerTag)) {
      Get.put(
        DevelopmentController(tagId: widget.controllerTag),
        tag: widget.controllerTag,
      );
    }
    devC = Get.find<DevelopmentController>(tag: widget.controllerTag);

    // Design controller (sudah dibuat di DesignSection)
    if (Get.isRegistered<DesignController>(tag: widget.designTag)) {
      designC = Get.find<DesignController>(tag: widget.designTag);
    }
  }

  @override
  void dispose() {
    _devNameCtrl.dispose();
    _picCtrl.dispose();
    _metaCtrl.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _selectedDesignIndex = null;
      _devNameCtrl.clear();
      _picCtrl.clear();
      _metaCtrl.clear();
      _status = 'In Progress';
      _startDate = null;
      _endDate = null;
      _editingIndex = null;
      _isEditing = false;
    });
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '-';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return '$dd/$mm/$yy';
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final current = (isStart ? _startDate : _endDate) ?? now;

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
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = picked;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submit() {
    if (designC == null || designC!.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada DesignSpec. Buat dulu di tab Design.')),
      );
      return;
    }

    if (_selectedDesignIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih DesignSpec terlebih dahulu.')),
      );
      return;
    }

    final devName = _devNameCtrl.text.trim();
    if (devName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi nama developer.')),
      );
      return;
    }

    final d = designC!.items[_selectedDesignIndex!];

    // label untuk dropdown & tabel, misal: [API] Login — ref
    final label = [
      '[${d.type}]',
      d.artifactName,
      if ((d.reference ?? '').isNotEmpty) '— ${d.reference}',
    ].join(' ');

    final pic = _picCtrl.text.trim();
    final meta = _metaCtrl.text.trim().isEmpty ? null : _metaCtrl.text.trim();

    if (_isEditing && _editingIndex != null) {
      final current = devC.items[_editingIndex!];
      devC.updateAt(
        _editingIndex!,
        current.copyWith(
          requirement: d.requirement,
          designSpec: label,
          developer: devName,
          status: _status,
          pic: pic.isEmpty ? null : pic,
          meta: meta,
          startDate: _startDate,
          endDate: _endDate,
        ),
      );
    } else {
      devC.add(
        requirement: d.requirement,
        designSpec: label,
        developer: devName,
        status: _status,
        pic: pic.isEmpty ? null : pic,
        meta: meta,
        startDate: _startDate,
        endDate: _endDate,
      );
    }

    _resetForm();
  }

  void _startEdit(int index) {
    final task = devC.items[index];

    // cari kembali index design spec berdasarkan label (kalau ada yang cocok)
    final items = designC?.items ?? [];
    int? designIndex;
    for (var i = 0; i < items.length; i++) {
      final d = items[i];
      final label = [
        '[${d.type}]',
        d.artifactName,
        if ((d.reference ?? '').isNotEmpty) '— ${d.reference}',
      ].join(' ');
      if (label == task.designSpec) {
        designIndex = i;
        break;
      }
    }

    setState(() {
      _editingIndex = index;
      _isEditing = true;
      _devNameCtrl.text = task.developer;
      _status = task.status;
      _selectedDesignIndex = designIndex;
      _picCtrl.text = (task.pic ?? '');
      _metaCtrl.text = task.meta ?? '';
      _startDate = task.startDate;
      _endDate = task.endDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    const border = Color(0xFFEEF1F6);
    const zebra = Color(0xFFF7F9FC);

    // opsi dropdown design spec
    final designItems = designC?.items ?? [];
    final designOptions = List.generate(designItems.length, (i) {
      final d = designItems[i];
      final label = [
        '[${d.type}]',
        d.artifactName,
        if ((d.reference ?? '').isNotEmpty) '— ${d.reference}',
      ].join(' ');
      return _DesignOption(
        index: i,
        requirement: d.requirement,
        label: label,
      );
    });

    // lebar minimal tabel (kolom # sekarang 64)
    final double tableMinW =
        64 + 200 + 260 + 140 + 120 + 120 + 160 + 120 + 150;

    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== TITLE + PROGRESS BAR
          const _SectionTitle('Development Tasks (terhubung DesignSpec)'),
          const SizedBox(height: 4),
          Obx(() {
            final pct = (devC.progress.value * 100).round();
            return _ProgressLine(
              value: devC.progress.value,
              brand: widget.brand,
              label: '$pct%',
            );
          }),
          const SizedBox(height: 16),

          // ================== FORM ==================

          // Baris 1: dropdown DesignSpec full width
          _RoundedFieldBox(
            child: DropdownButtonFormField<int>(
              value: _selectedDesignIndex,
              isExpanded: true,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              hint: const Text('— Pilih DesignSpec —'),
              items: designOptions
                  .map(
                    (o) => DropdownMenuItem(
                      value: o.index,
                      child: Text(
                        o.label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedDesignIndex = v),
            ),
          ),

          const SizedBox(height: 8),

          // Baris 2: PIC developer | Tanggal mulai
          Row(
            children: [
              Expanded(
                child: _RoundedFieldBox(
                  child: TextField(
                    controller: _picCtrl,
                    decoration: const InputDecoration(
                      hintText: 'PIC developer',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickDate(isStart: true),
                  child: _RoundedFieldBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _startDate == null
                              ? 'Tanggal mulai'
                              : _formatDate(_startDate),
                          style: const TextStyle(fontSize: 13),
                        ),
                        const Icon(Icons.calendar_today_outlined, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Baris 3: Tanggal selesai | Status
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickDate(isStart: false),
                  child: _RoundedFieldBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _endDate == null
                              ? 'Tanggal selesai'
                              : _formatDate(_endDate),
                          style: const TextStyle(fontSize: 13),
                        ),
                        const Icon(Icons.calendar_today_outlined, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RoundedFieldBox(
                  child: DropdownButtonFormField<String>(
                    value: _status,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    hint: const Text('Status'),
                    items: devC.statuses
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(s),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _status = v ?? 'In Progress'),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Baris 4: Nama developer (full width)
          _RoundedFieldBox(
            child: TextField(
              controller: _devNameCtrl,
              decoration: const InputDecoration(
                hintText: 'Nama developer',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Baris 5: Meta (ops.) + Tombol Tambahkan
          Row(
            children: [
              Expanded(
                child: _RoundedFieldBox(
                  child: TextField(
                    controller: _metaCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Meta (ops.)',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 140,
                height: 46,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.brand,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(_isEditing ? 'Simpan' : 'Tambahkan'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // =================== TABEL ===================
          Builder(
            builder: (context) {
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
                          // header
                          Container(
                            height: 44,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: zebra,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: const [
                                _HCell('#', 64),
                                _HCell('Development', 200),
                                _HCell('DesignSpec', 260),
                                _HCell('PIC', 140),
                                _HCell('Mulai', 120),
                                _HCell('Selesai', 120),
                                _HCell('Developer', 160),
                                _HCell('Status', 120),
                                _HCell('Aksi', 150),
                              ],
                            ),
                          ),

                          // body
                          Obx(() {
                            if (devC.items.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text('Belum ada task development.'),
                              );
                            }

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children:
                                  List.generate(devC.items.length, (i) {
                                final it = devC.items[i];
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
                                      _RowIndexWithCheck(
                                        index: i + 1,
                                        width: 64,
                                      ),
                                      _BCell(it.requirement, 200),
                                      _BCell(it.designSpec, 260),
                                      _BCell(
                                        (it.pic ?? '').isEmpty
                                            ? '-'
                                            : it.pic!,
                                        140,
                                      ),
                                      _BCell(
                                          _formatDate(it.startDate), 120),
                                      _BCell(
                                          _formatDate(it.endDate), 120),
                                      _BCell(
                                        it.developer.isEmpty
                                            ? '-'
                                            : it.developer,
                                        160,
                                      ),
                                      _BCell(it.status, 120),
                                      SizedBox(
                                        width: 150,
                                        child: Row(
                                          children: [
                                            TextButton(
                                              onPressed: () =>
                                                  _startEdit(i),
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                foregroundColor:
                                                    const Color(
                                                        0xFF4A5668),
                                                backgroundColor:
                                                    Colors.white,
                                                shape:
                                                    RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(8),
                                                  side: const BorderSide(
                                                    color:
                                                        Color(0xFFE0E4EC),
                                                  ),
                                                ),
                                              ),
                                              child: const Text('Edit'),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton(
                                              onPressed: () =>
                                                  devC.removeAt(i),
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                  horizontal: 12,
                                                  vertical: 6),
                                                foregroundColor:
                                                    Colors.white,
                                                backgroundColor:
                                                    const Color(
                                                        0xFFFF7A7A),
                                                shape:
                                                    RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(8),
                                                ),
                                              ),
                                              child: const Text('Hapus'),
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
            },
          ),
        ],
      ),
    );
  }
}

/* ===== sub-widgets kecil + helper ===== */

class _RoundedFieldBox extends StatelessWidget {
  const _RoundedFieldBox({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E6)),
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}

class _DesignOption {
  final int index;
  final String requirement;
  final String label;
  _DesignOption({
    required this.index,
    required this.requirement,
    required this.label,
  });
}

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

/// Kolom nomor + checkbox di tabel Development
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

/// Progress bar tipis (bar + label % di kanan)
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
