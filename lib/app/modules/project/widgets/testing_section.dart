import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_tracking/app/data/models/test_case_item.dart';

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
    required this.projectId, // 🔥 WAJIB
  });

  final Color brand;
  final String controllerTag;
  final String requirementTag;
  final String designTag;
  final int projectId;

  @override
  State<TestingSection> createState() => _TestingSectionState();
}

class _TestingSectionState extends State<TestingSection> {
  late final TestingController c;
  RequirementController? reqC;
  DesignController? designC;

  // ================= FORM STATE =================
  int? _selectedReqId;
  int? _selectedDesignId;
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

    // Init Testing Controller
    if (!Get.isRegistered<TestingController>(tag: widget.controllerTag)) {
      Get.put(
        TestingController(tagId: widget.controllerTag),
        tag: widget.controllerTag,
      );
    }
    c = Get.find<TestingController>(tag: widget.controllerTag);
    c.setProjectId(widget.projectId);

    // Get Req Controller
    if (Get.isRegistered<RequirementController>(tag: widget.requirementTag)) {
      reqC = Get.find<RequirementController>(tag: widget.requirementTag);
    }

    // Get Design Controller (Should exist from DesignSection)
    if (Get.isRegistered<DesignController>(tag: widget.designTag)) {
      designC = Get.find<DesignController>(tag: widget.designTag);
    }
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

  // ================= DATE PICKER =================
  Future<void> _pickDate({
    required BuildContext context,
    required TextEditingController controller,
    required ValueChanged<DateTime> onPicked,
    DateTime? firstDate,
  }) async {
    final now = DateTime.now();
    final safeFirst = firstDate ?? DateTime(2020);
    
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: safeFirst,
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      controller.text = '${picked.day}/${picked.month}/${picked.year}';
      onPicked(picked);
    }
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '-';
    return '${d.day}/${d.month}/${d.year}';
  }

  // ================= OPEN FORM =================
  void _openForm({int? editIndex}) {
    if (editIndex != null) {
      final it = c.items[editIndex];
      _titleCtrl.text = it.title;
      _scenarioCtrl.text = it.scenario ?? '';
      _expectedCtrl.text = it.expectedResult ?? '';
      _testerCtrl.text = it.tester ?? '';
      _selectedReqId = it.requirementId;
      _selectedDesignId = it.designSpecId;
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
      _selectedReqId = null;
      _selectedDesignId = null;
      _selectedStatus = 'Planned';
      _startDate = null;
      _endDate = null;
      _startDateCtrl.clear();
      _endDateCtrl.clear();
    }

    // Load dropdown data
    final reqItems = reqC?.items ?? [];
    final designItems = designC?.items ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 16, right: 16, top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(editIndex == null ? 'Tambah Test Case' : 'Edit Test Case',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 8),

                // REQ DROPDOWN
                DropdownButtonFormField<int>(
                  value: _selectedReqId,
                  isExpanded: true,
                  decoration: _dec(hint: 'Requirement (opsional)'),
                  items: reqItems
                      .where((e) => e.id != null)
                      .map<DropdownMenuItem<int>>((e) => DropdownMenuItem<int>(
                            value: e.id!,
                            child: Text(e.title, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedReqId = v),
                ),
                const SizedBox(height: 10),

                // DESIGN DROPDOWN
                DropdownButtonFormField<int>(
                  value: _selectedDesignId,
                  isExpanded: true,
                  decoration: _dec(hint: 'Design Spec (opsional)'),
                  items: designItems
                      .where((e) => e.id != null)
                      .map<DropdownMenuItem<int>>((e) => DropdownMenuItem<int>(
                            value: e.id!,
                            child: Text('[${e.artifactType}] ${e.artifactName}', overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedDesignId = v),
                ),
                const SizedBox(height: 10),

                TextField(controller: _titleCtrl, decoration: _dec(hint: 'Judul Test Case')),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  isExpanded: true,
                  decoration: _dec(hint: 'Status'),
                  items: c.statuses.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => _selectedStatus = v ?? 'Planned'),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _startDateCtrl,
                        readOnly: true,
                        decoration: _dec(hint: 'Mulai'),
                        onTap: () => _pickDate(context: ctx, controller: _startDateCtrl, onPicked: (d) => _startDate = d),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _endDateCtrl,
                        readOnly: true,
                        decoration: _dec(hint: 'Selesai'),
                        onTap: () => _pickDate(context: ctx, controller: _endDateCtrl, firstDate: _startDate, onPicked: (d) => _endDate = d),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                TextField(controller: _scenarioCtrl, maxLines: 2, decoration: _dec(hint: 'Skenario')),
                const SizedBox(height: 10),
                TextField(controller: _expectedCtrl, maxLines: 2, decoration: _dec(hint: 'Hasil yang diharapkan')),
                const SizedBox(height: 10),
                TextField(controller: _testerCtrl, decoration: _dec(hint: 'Nama Tester')),
                
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => _submit(ctx, editIndex: editIndex),
                    style: ElevatedButton.styleFrom(backgroundColor: widget.brand, foregroundColor: Colors.white),
                    child: Text(editIndex == null ? 'Simpan' : 'Update'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submit(BuildContext ctx, {int? editIndex}) {
    if (_titleCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Judul wajib diisi', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    final item = TestCaseItem(
      requirementId: _selectedReqId,
      designSpecId: _selectedDesignId,
      title: _titleCtrl.text.trim(),
      scenario: _scenarioCtrl.text.trim(),
      expectedResult: _expectedCtrl.text.trim(),
      tester: _testerCtrl.text.trim(),
      status: _selectedStatus,
      startDate: _startDate,
      endDate: _endDate,
    );

    if (editIndex == null) {
      c.add(item);
    } else {
      c.updateItem(c.items[editIndex].id!, item);
    }
    Navigator.pop(ctx);
  }

  InputDecoration _dec({String? hint}) => InputDecoration(
    hintText: hint, contentPadding: const EdgeInsets.all(12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  );

  @override
  Widget build(BuildContext context) {
    const border = Color(0xFFEEF1F6);
    const zebra = Color(0xFFF7F9FC);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: const [BoxShadow(color: Color(0x1A0B1325), blurRadius: 18, offset: Offset(0, 8))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Test Cases', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF5C6A82))),
                Obx(() => Text('${(c.progress.value * 100).toInt()}% Passed', style: TextStyle(fontWeight: FontWeight.bold, color: widget.brand))),
              ],
            ),
          ),
          Obx(() => LinearProgressIndicator(value: c.progress.value, color: widget.brand, backgroundColor: const Color(0xFFE4E6ED), minHeight: 4)),
          
          const SizedBox(height: 10),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 40,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _openForm(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, foregroundColor: widget.brand, elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: widget.brand)),
                ),
                child: const Text('Tambah Test Case'),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Obx(() {
            if (c.items.isEmpty) return const Padding(padding: EdgeInsets.all(20), child: Text("Belum ada test case."));
            
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(zebra),
                columns: const [
                  DataColumn(label: Text('Judul')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Req')),
                  DataColumn(label: Text('Design')),
                  DataColumn(label: Text('Tester')),
                  DataColumn(label: Text('Tgl')),
                  DataColumn(label: Text('Aksi')),
                ],
                rows: c.items.asMap().entries.map((entry) {
                  final i = entry.key;
                  final it = entry.value;
                  return DataRow(cells: [
                    DataCell(Text(it.title, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(_StatusBadge(status: it.status)),
                    DataCell(Text(it.requirementName ?? '-')),
                    DataCell(Text(it.designSpecName ?? '-')),
                    DataCell(Text(it.tester ?? '-')),
                    DataCell(Text(_fmtDate(it.startDate))),
                    DataCell(Row(
                      children: [
                        IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _openForm(editIndex: i)),
                        IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () => c.removeAt(i)),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    Color col = Colors.grey;
    if (status == 'Passed') col = Colors.green;
    if (status == 'Failed') col = Colors.red;
    if (status == 'In Progress') col = Colors.blue;
    return Text(status, style: TextStyle(color: col, fontWeight: FontWeight.bold));
  }
}