import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_tracking/app/data/models/development_item.dart';
import 'package:project_tracking/app/data/models/design_spec_item.dart';

import '../controllers/design_controller.dart';
import '../controllers/development_controller.dart';

class DevelopmentSection extends StatefulWidget {
  const DevelopmentSection({
    super.key,
    required this.brand,
    required this.controllerTag, 
    required this.designTag,     
    required this.projectId, // 🔥 WAJIB
  });

  final Color brand;
  final String controllerTag;
  final String designTag;
  final int projectId;

  @override
  State<DevelopmentSection> createState() => _DevelopmentSectionState();
}

class _DevelopmentSectionState extends State<DevelopmentSection> {
  late final DevelopmentController devC;
  DesignController? designC;

  // Form State
  int? _selectedDesignId;
  String _status = 'In Progress';
  final _developerCtrl = TextEditingController(); // Maps to 'pic' in API
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  // Edit State
  int? _editingId; 

  @override
  void initState() {
    super.initState();

    // Init Development Controller
    if (!Get.isRegistered<DevelopmentController>(tag: widget.controllerTag)) {
      Get.put(DevelopmentController(tagId: widget.controllerTag), tag: widget.controllerTag);
    }
    devC = Get.find<DevelopmentController>(tag: widget.controllerTag);
    devC.setProjectId(widget.projectId);

    // Ambil Design Controller (harus sudah ada dari parent)
    if (Get.isRegistered<DesignController>(tag: widget.designTag)) {
      designC = Get.find<DesignController>(tag: widget.designTag);
    }
  }

  @override
  void dispose() {
    _developerCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _selectedDesignId = null;
      _developerCtrl.clear();
      _startCtrl.clear();
      _endCtrl.clear();
      _status = 'In Progress';
      _startDate = null;
      _endDate = null;
      _editingId = null;
    });
  }

  String _formatDate(DateTime? d) => d == null ? '-' : '${d.day}/${d.month}/${d.year}';

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
          _startCtrl.text = _formatDate(picked);
        } else {
          _endDate = picked;
          _endCtrl.text = _formatDate(picked);
        }
      });
    }
  }

  void _submit() {
    if (_selectedDesignId == null) {
      Get.snackbar('Error', 'Pilih Design Spec dulu', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (_developerCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Isi Nama Developer', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    final item = DevelopmentItem(
      designSpecId: _selectedDesignId!,
      pic: _developerCtrl.text.trim(),
      status: _status,
      startDate: _startDate,
      endDate: _endDate,
    );

    if (_editingId != null) {
      devC.updateItem(_editingId!, item);
    } else {
      devC.add(item);
    }
    _resetForm();
  }

  void _startEdit(DevelopmentItem item) {
    setState(() {
      _editingId = item.id;
      _selectedDesignId = item.designSpecId;
      _developerCtrl.text = item.pic ?? '';
      _status = item.status;
      _startDate = item.startDate;
      _endDate = item.endDate;
      _startCtrl.text = _formatDate(_startDate);
      _endCtrl.text = _formatDate(_endDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dropdown options dari Design Controller
    final designItems = designC?.items ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEF1F6)),
        boxShadow: const [BoxShadow(color: Color(0x1A0B1325), blurRadius: 18, offset: Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Progress
          const Text('Development Tasks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF5C6A82))),
          Obx(() => LinearProgressIndicator(value: devC.progress.value, color: widget.brand, backgroundColor: const Color(0xFFE4E6ED))),
          const SizedBox(height: 16),

          // FORM
          Column(
            children: [
              // Dropdown Design Spec
              DropdownButtonFormField<int>(
                value: _selectedDesignId,
                isExpanded: true,
                hint: const Text('Pilih Design Spec'),
                items: designItems
                    .where((d) => d.id != null)
                    .map<DropdownMenuItem<int>>((d) {
                      final label = '[${d.artifactType}] ${d.artifactName}';
                      return DropdownMenuItem<int>(
                        value: d.id!,
                        child: Text(label, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                onChanged: (v) => setState(() => _selectedDesignId = v),
                decoration: _dec(),
              ),
              const SizedBox(height: 10),
              
              // Nama Developer
              TextField(controller: _developerCtrl, decoration: _dec(hint: 'Nama Developer (PIC)')),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(child: TextField(controller: _startCtrl, readOnly: true, onTap: () => _pickDate(true), decoration: _dec(hint: 'Mulai'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: _endCtrl, readOnly: true, onTap: () => _pickDate(false), decoration: _dec(hint: 'Selesai'))),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _status,
                      items: devC.statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => _status = v!),
                      decoration: _dec(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: widget.brand, foregroundColor: Colors.white),
                    child: Text(_editingId == null ? 'Tambah' : 'Update'),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // TABEL
          Obx(() {
            if (devC.items.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Belum ada task dev.")));
            
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                columns: const [
                  DataColumn(label: Text('Design Spec')),
                  DataColumn(label: Text('Requirement')),
                  DataColumn(label: Text('Developer')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Tanggal')),
                  DataColumn(label: Text('Aksi')),
                ],
                rows: devC.items.map((item) {
                  return DataRow(cells: [
                    DataCell(Text(item.designSpecName, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(item.requirementTitle)),
                    DataCell(Text(item.pic ?? '-')),
                    DataCell(_StatusBadge(status: item.status)),
                    DataCell(Text('${_formatDate(item.startDate)} - ${_formatDate(item.endDate)}')),
                    DataCell(Row(
                      children: [
                        IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _startEdit(item)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 18), onPressed: () => devC.removeAt(devC.items.indexOf(item))),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  InputDecoration _dec({String? hint}) => InputDecoration(
    hintText: hint, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    Color col = Colors.grey;
    if (status == 'Done') col = Colors.green;
    if (status == 'In Progress') col = Colors.blue;
    return Text(status, style: TextStyle(color: col, fontWeight: FontWeight.bold));
  }
}