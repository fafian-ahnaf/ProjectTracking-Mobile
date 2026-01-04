import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/testing_controller.dart';
import '../controllers/requirement_controller.dart';
import '../controllers/design_controller.dart';

class TestingSection extends StatefulWidget {
  const TestingSection({
    super.key,
    required this.brand,
    required this.controllerTag,
    required this.requirementTag,
    required this.designTag,
  });

  final Color brand;
  final String controllerTag;
  final String requirementTag;
  final String designTag;

  @override
  State<TestingSection> createState() => _TestingSectionState();
}

class _TestingSectionState extends State<TestingSection> {
  late final TestingController c;
  RequirementController? reqC;
  DesignController? designC;

  // ================= FORM STATE =================
  String? _selectedReq;
  String? _selectedDesign;
  String _selectedStatus = 'Planned';

  DateTime? _startDate;
  DateTime? _endDate;

  final _titleCtrl = TextEditingController();
  final _scenarioCtrl = TextEditingController();
  final _expectedCtrl = TextEditingController();
  final _testerCtrl = TextEditingController();
  final _startDateCtrl = TextEditingController();
  final _endDateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (!Get.isRegistered<TestingController>(tag: widget.controllerTag)) {
      Get.put(
        TestingController(tagId: widget.controllerTag),
        tag: widget.controllerTag,
      );
    }
    c = Get.find<TestingController>(tag: widget.controllerTag);

    if (Get.isRegistered<RequirementController>(tag: widget.requirementTag)) {
      reqC = Get.find<RequirementController>(tag: widget.requirementTag);
    }

    if (!Get.isRegistered<DesignController>(tag: widget.designTag)) {
      Get.put(
        DesignController(tagId: widget.designTag),
        tag: widget.designTag,
      );
    }
    designC = Get.find<DesignController>(tag: widget.designTag);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _scenarioCtrl.dispose();
    _expectedCtrl.dispose();
    _testerCtrl.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    super.dispose();
  }

  // ================= DATE PICKER (FIXED) =================
  Future<void> _pickDate({
    required BuildContext context,
    required TextEditingController controller,
    required ValueChanged<DateTime> onPicked,
    DateTime? firstDate,
  }) async {
    final now = DateTime.now();

    final DateTime safeInitialDate =
        firstDate != null && now.isBefore(firstDate)
            ? firstDate
            : now;

    final picked = await showDatePicker(
      context: context,
      initialDate: safeInitialDate,
      firstDate: firstDate ?? DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      controller.text =
          '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.month.toString().padLeft(2, '0')}/'
          '${picked.year}';
      onPicked(picked);
    }
  }

  // ================= OPEN FORM =================
  void _openForm({int? editIndex}) {
    if (editIndex != null) {
      final it = c.items[editIndex];
      _titleCtrl.text = it.title;
      _scenarioCtrl.text = it.scenario ?? '';
      _expectedCtrl.text = it.expectedResult ?? '';
      _testerCtrl.text = it.tester ?? '';
      _selectedReq = it.requirement;
      _selectedDesign = it.designSpec;
      _selectedStatus = it.status;
      _startDate = it.startDate;
      _endDate = it.endDate;
      _startDateCtrl.text = _fmtDate(it.startDate);
      _endDateCtrl.text = _fmtDate(it.endDate);
    } else {
      _titleCtrl.clear();
      _scenarioCtrl.clear();
      _expectedCtrl.clear();
      _testerCtrl.clear();
      _selectedReq = null;
      _selectedDesign = null;
      _selectedStatus = 'Planned';
      _startDate = null;
      _endDate = null;
      _startDateCtrl.clear();
      _endDateCtrl.clear();
    }

    final reqOptions =
        reqC?.items.map((e) => e.title).toList() ?? const <String>[];
    final designOptions = designC?.items
            .map((e) =>
                '[${e.type}] ${e.artifactName}${e.reference == null || e.reference!.isEmpty ? '' : ' — ${e.reference}'}')
            .toList() ??
        const <String>[];

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
              children: [
                Row(
                  children: [
                    Text(
                      editIndex == null
                          ? 'Tambah Test Case'
                          : 'Edit Test Case',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  value: _selectedReq,
                  isExpanded: true,
                  decoration:
                      _fieldDecoration(hint: 'Requirement (opsional)'),
                  items: reqOptions
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedReq = v),
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: _selectedDesign,
                  isExpanded: true,
                  decoration:
                      _fieldDecoration(hint: 'DesignSpec (opsional)'),
                  items: designOptions
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedDesign = v),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _titleCtrl,
                  decoration:
                      _fieldDecoration(hint: 'Judul / nama test case'),
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  isExpanded: true,
                  decoration: _fieldDecoration(hint: 'Status'),
                  items: c.statuses
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _selectedStatus = v ?? 'Planned'),
                ),
                const SizedBox(height: 10),

                // ===== TANGGAL MULAI =====
                TextField(
                  controller: _startDateCtrl,
                  readOnly: true,
                  decoration: _fieldDecoration(
                    hint: 'Tanggal Mulai',
                  ).copyWith(
                    suffixIcon:
                        const Icon(Icons.calendar_today, size: 18),
                  ),
                  onTap: () => _pickDate(
                    context: ctx,
                    controller: _startDateCtrl,
                    onPicked: (d) {
                      setState(() {
                        _startDate = d;
                        _endDate = null;
                        _endDateCtrl.clear();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // ===== TANGGAL SELESAI (FIXED) =====
                TextField(
                  controller: _endDateCtrl,
                  readOnly: true,
                  decoration: _fieldDecoration(
                    hint: 'Tanggal Selesai',
                  ).copyWith(
                    suffixIcon:
                        const Icon(Icons.calendar_today, size: 18),
                  ),
                  onTap: () => _pickDate(
                    context: ctx,
                    controller: _endDateCtrl,
                    firstDate: _startDate ?? DateTime.now(),
                    onPicked: (d) =>
                        setState(() => _endDate = d),
                  ),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _scenarioCtrl,
                  maxLines: 3,
                  decoration: _fieldDecoration(
                    hint: 'Skenario / langkah pengujian (opsional)',
                  ),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _expectedCtrl,
                  maxLines: 3,
                  decoration: _fieldDecoration(
                    hint: 'Hasil yang diharapkan (opsional)',
                  ),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _testerCtrl,
                  decoration:
                      _fieldDecoration(hint: 'Nama tester (opsional)'),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () =>
                        _submit(ctx, editIndex: editIndex),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.brand,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(editIndex == null
                        ? 'Simpan Test Case'
                        : 'Simpan Perubahan'),
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

  // ================= SUBMIT =================
  void _submit(BuildContext ctx, {int? editIndex}) {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('Isi judul / nama test case terlebih dahulu.'),
        ),
      );
      return;
    }

    if (editIndex == null) {
      c.add(
        title: title,
        status: _selectedStatus,
        requirement: _selectedReq,
        designSpec: _selectedDesign,
        tester:
            _testerCtrl.text.trim().isEmpty ? null : _testerCtrl.text.trim(),
        scenario:
            _scenarioCtrl.text.trim().isEmpty ? null : _scenarioCtrl.text.trim(),
        expectedResult: _expectedCtrl.text.trim().isEmpty
            ? null
            : _expectedCtrl.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
      );
    } else {
      final old = c.items[editIndex];
      c.updateAt(
        editIndex,
        old.copyWith(
          title: title,
          status: _selectedStatus,
          requirement: _selectedReq,
          designSpec: _selectedDesign,
          tester:
              _testerCtrl.text.trim().isEmpty ? null : _testerCtrl.text.trim(),
          scenario:
              _scenarioCtrl.text.trim().isEmpty ? null : _scenarioCtrl.text.trim(),
          expectedResult: _expectedCtrl.text.trim().isEmpty
              ? null
              : _expectedCtrl.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
        ),
      );
    }

    Navigator.pop(ctx);
  }

  int _statusToPercent(String status) {
    final s = status.toLowerCase();
    if (s.contains('plan')) return 0;
    if (s.contains('progress')) return 50;
    if (s.contains('done') || s.contains('pass')) return 100;
    return 0;
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '-';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    const border = Color(0xFFEEF1F6);
    const zebra = Color(0xFFF7F9FC);

    const double tableMinWidth =
        40 + 40 + 200 + 200 + 220 + 120 + 120 + 120 + 140 + 140 + 120;

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
                    'Pantau Progres Pekerjaanmu:',
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
                      foregroundColor: Color(0xFFF69220),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Tambah Testing',
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
                return const _EmptyTestingView();
              }
              return Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(minWidth: tableMinWidth),
                    child: _buildTable(border, zebra),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(Color border, Color zebra) {
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: const [
                _HCell('', 40),
                _HCell('#', 40),
                _HCell('Judul', 200),
                _HCell('Requirement', 200),
                _HCell('DesignSpec', 220),
                _HCell('Mulai', 120),
                _HCell('Selesai', 120),
                _HCell('Status', 120),
                _HCell('Progress', 140),
                _HCell('Tester', 140),
                _HCell('Aksi', 120),
              ],
            ),
          ),
          Column(
            children: List.generate(c.items.length, (i) {
              final it = c.items[i];
              final percent = _statusToPercent(it.status);
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFEEF1F6))),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 40,
                      child: Checkbox(
                        value: percent == 100,
                        onChanged: (v) {
                          final old = c.items[i];
                          c.updateAt(
                            i,
                            old.copyWith(
                              status:
                                  (v ?? false) ? 'Done' : 'Planned',
                            ),
                          );
                        },
                        activeColor: widget.brand,
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    _BCell('${i + 1}', 40),
                    _BCell(it.title, 200),
                    _BCell(it.requirement ?? '-', 200),
                    _BCell(it.designSpec ?? '-', 220),
                    _BCell(_fmtDate(it.startDate), 120),
                    _BCell(_fmtDate(it.endDate), 120),
                    _BCell(it.status, 120),
                    SizedBox(
                      width: 140,
                      child: _RowProgressBar(
                        percent: percent,
                        color: widget.brand,
                      ),
                    ),
                    _BCell(it.tester ?? '-', 140),
                    SizedBox(
                      width: 120,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            color: widget.brand,
                            onPressed: () => _openForm(editIndex: i),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18),
                            color: Colors.red,
                            onPressed: () => c.removeAt(i),
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
  }

  InputDecoration _fieldDecoration({String? hint}) => InputDecoration(
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: const Color(0xFFFDFDFE),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFFE6EAF0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF9A1E)),
        ),
      );
}

/* ================= SUB WIDGET ================= */

class _EmptyTestingView extends StatelessWidget {
  const _EmptyTestingView();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      color: const Color(0xFFF7F8FC),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.folder_rounded,
              size: 54, color: Color(0xFFF69220)),
          SizedBox(height: 12),
          Text(
            'Belum Ada Aktivitas Testing',
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

class _RowProgressBar extends StatelessWidget {
  const _RowProgressBar({
    super.key,
    required this.percent,
    required this.color,
  });

  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = percent.clamp(0, 100) / 100.0;
    return Row(
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E8F0),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              FractionallySizedBox(
                widthFactor: p,
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${percent.clamp(0, 100)}%',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }
}
