import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_tracking/app/data/models/design_spec_item.dart';
import 'package:project_tracking/app/data/models/requirement_item.dart';
import '../controllers/design_controller.dart';
import '../controllers/requirement_controller.dart';

class DesignSection extends StatefulWidget {
  const DesignSection({
    super.key,
    required this.brand,
    required this.controllerTag,
    required this.requirementTag,
    required this.projectId, // WAJIB ADA
  });

  final Color brand;
  final String controllerTag;
  final String requirementTag;
  final int projectId;

  @override
  State<DesignSection> createState() => _DesignSectionState();
}

class _DesignSectionState extends State<DesignSection> {
  late final DesignController c;

  // Form
  int? _selectedReqId;
  String _selectedType = 'UI';
  String _selectedStatus = 'Draft'; // Sesuai API (Draft, Review, Approved)

  final _artifactCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _picCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Init Controller Unik
    if (!Get.isRegistered<DesignController>(tag: widget.controllerTag)) {
      Get.put(
        DesignController(tagId: widget.controllerTag),
        tag: widget.controllerTag,
      );
    }
    c = Get.find<DesignController>(tag: widget.controllerTag);
    c.setProjectId(widget.projectId);
  }

  // Ambil Requirement Controller dari section sebelah
  RequirementController? get reqC {
    if (Get.isRegistered<RequirementController>(tag: widget.requirementTag)) {
      return Get.find<RequirementController>(tag: widget.requirementTag);
    }
    return null;
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _startCtrl.text = "${picked.day}/${picked.month}/${picked.year}";
        } else {
          _endDate = picked;
          _endCtrl.text = "${picked.day}/${picked.month}/${picked.year}";
        }
      });
    }
  }

  void _submit() {
    if (_selectedReqId == null) {
      Get.snackbar(
        'Error',
        'Pilih Requirement dulu',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    if (_artifactCtrl.text.isEmpty) return;

    final item = DesignSpecItem(
      requirementId: _selectedReqId!,
      artifactType: _selectedType,
      artifactName: _artifactCtrl.text.trim(),
      status: _selectedStatus,
      referenceUrl: _linkCtrl.text.trim(),
      rationale: _notesCtrl.text.trim(),
      pic: _picCtrl.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
    );

    c.add(item);
    _resetForm();
  }

  void _resetForm() {
    _artifactCtrl.clear();
    _linkCtrl.clear();
    _notesCtrl.clear();
    _picCtrl.clear();
    _startCtrl.clear();
    _endCtrl.clear();
    setState(() {
      _selectedReqId = null;
      _selectedType = 'UI';
      _selectedStatus = 'Draft';
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ambil list requirement untuk dropdown
    final List<RequirementItem> reqs = reqC?.items ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEF1F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Design Specification',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF5C6A82),
                ),
              ),
              Obx(
                () => Text(
                  '${(c.progress.value * 100).toInt()}% Done',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.brand,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // FORM
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              // Dropdown Requirement
              _fieldBox(
                width: 300,
                child: DropdownButtonFormField<int>(
                  value: _selectedReqId,
                  isExpanded: true,
                  hint: const Text('Pilih Requirement'),
                  items: reqs
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.id,
                          child: Text(e.title, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedReqId = v),
                  decoration: _dec(),
                ),
              ),
              // Tipe Artefak
              _fieldBox(
                width: 120,
                child: DropdownButtonFormField<String>(
                  value: _selectedType,
                  items: c.types
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedType = v!),
                  decoration: _dec(),
                ),
              ),
              // Nama Artefak
              _fieldBox(
                width: 250,
                child: TextField(
                  controller: _artifactCtrl,
                  decoration: _dec(hint: 'Nama Artefak (Login UI)'),
                ),
              ),
              // Status
              _fieldBox(
                width: 140,
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  items: c.statuses
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedStatus = v!),
                  decoration: _dec(),
                ),
              ),
              // Link Ref
              _fieldBox(
                width: 300,
                child: TextField(
                  controller: _linkCtrl,
                  decoration: _dec(hint: 'Link Figma/Doc'),
                ),
              ),

              // Tombol Tambah
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.brand,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Tambah'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // TABLE
          Obx(() {
            if (c.items.isEmpty)
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Belum ada data design."),
                ),
              );

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                columns: const [
                  DataColumn(label: Text('Req')),
                  DataColumn(label: Text('Tipe')),
                  DataColumn(label: Text('Artefak')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Ref')),
                  DataColumn(label: Text('Aksi')),
                ],
                rows: c.items.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          item.requirementTitle ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataCell(Text(item.artifactType)),
                      DataCell(Text(item.artifactName)),
                      DataCell(_StatusBadge(status: item.status)),
                      DataCell(Text(item.referenceUrl ?? '-')),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 18,
                              ),
                              onPressed: () =>
                                  c.removeAt(c.items.indexOf(item)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _fieldBox({required double width, required Widget child}) =>
      SizedBox(width: width, child: child);

  InputDecoration _dec({String? hint}) => InputDecoration(
    hintText: hint,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    Color col = Colors.grey;
    if (status == 'Approved') col = Colors.green;
    if (status == 'Review') col = Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: col.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}
