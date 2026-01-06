import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_tracking/app/data/models/maintenance_item.dart';

import '../controllers/maintenance_controller.dart';

class MaintenanceSection extends StatefulWidget {
  const MaintenanceSection({
    super.key,
    required this.brand,
    required this.controllerTag,
    required this.projectId, // 🔥 WAJIB
  });

  final Color brand;
  final String controllerTag;
  final int projectId;

  @override
  State<MaintenanceSection> createState() => _MaintenanceSectionState();
}

class _MaintenanceSectionState extends State<MaintenanceSection> {
  late final MaintenanceController c;

  // Form State
  final _titleCtrl = TextEditingController();
  final _assigneeCtrl = TextEditingController(); // Assignee
  final _notesCtrl = TextEditingController();
  final _openedCtrl = TextEditingController(); // Opened At
  final _closedCtrl = TextEditingController(); // Closed At

  String _selectedStatus = 'Planned';
  DateTime? _openedDate;
  DateTime? _closedDate;
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
    c.setProjectId(widget.projectId);
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _assigneeCtrl.dispose(); _notesCtrl.dispose();
    _openedCtrl.dispose(); _closedCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext ctx, bool isOpened) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: ctx,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isOpened) {
          _openedDate = picked;
          _openedCtrl.text = _fmt(picked);
        } else {
          _closedDate = picked;
          _closedCtrl.text = _fmt(picked);
        }
      });
    }
  }

  String _fmt(DateTime? d) => d == null ? '' : '${d.day}/${d.month}/${d.year}';

  void _openForm({int? editIndex}) {
    _editingIndex = editIndex;

    if (editIndex == null) {
      _titleCtrl.clear();
      _assigneeCtrl.clear();
      _notesCtrl.clear();
      _selectedStatus = 'Planned';
      _openedDate = DateTime.now(); // Default hari ini
      _closedDate = null;
      _openedCtrl.text = _fmt(_openedDate);
      _closedCtrl.clear();
    } else {
      final it = c.items[editIndex];
      _titleCtrl.text = it.title;
      _assigneeCtrl.text = it.assignee ?? '';
      _notesCtrl.text = it.notes ?? '';
      _selectedStatus = it.status;
      _openedDate = it.openedAt;
      _closedDate = it.closedAt;
      _openedCtrl.text = _fmt(it.openedAt);
      _closedCtrl.text = _fmt(it.closedAt);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) => _buildForm(ctx),
    );
  }

  Widget _buildForm(BuildContext ctx) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        left: 16, right: 16, top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(_editingIndex == null ? 'Tambah Maintenance' : 'Edit Maintenance',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 10),

            TextField(controller: _titleCtrl, decoration: _dec(hint: 'Judul Maintenance / Bug')),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: _selectedStatus,
              isExpanded: true,
              decoration: _dec(hint: 'Status'),
              items: c.statuses.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _selectedStatus = v ?? 'Planned'),
            ),
            const SizedBox(height: 10),

            Row(children: [
              Expanded(
                child: TextField(controller: _openedCtrl, readOnly: true, onTap: () => _pickDate(ctx, true), decoration: _dec(hint: 'Tanggal Lapor')),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(controller: _closedCtrl, readOnly: true, onTap: () => _pickDate(ctx, false), decoration: _dec(hint: 'Tanggal Selesai')),
              ),
            ]),
            const SizedBox(height: 10),

            TextField(controller: _assigneeCtrl, decoration: _dec(hint: 'Assignee (PIC)')),
            const SizedBox(height: 10),
            TextField(controller: _notesCtrl, maxLines: 2, decoration: _dec(hint: 'Catatan')),
            
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () => _submit(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: widget.brand, foregroundColor: Colors.white),
                child: const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit(BuildContext ctx) {
    if (_titleCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Judul wajib diisi', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    final item = MaintenanceItem(
      title: _titleCtrl.text.trim(),
      status: _selectedStatus,
      assignee: _assigneeCtrl.text.trim().isEmpty ? null : _assigneeCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      openedAt: _openedDate,
      closedAt: _closedDate,
    );

    if (_editingIndex == null) {
      c.add(item);
    } else {
      c.updateItem(c.items[_editingIndex!].id!, item);
    }
    Navigator.pop(ctx);
  }

  InputDecoration _dec({String? hint}) => InputDecoration(
    hintText: hint, contentPadding: const EdgeInsets.all(12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  );

  @override
  Widget build(BuildContext context) {
    const zebra = Color(0xFFF7F9FC);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEF1F6)),
        boxShadow: const [BoxShadow(color: Color(0x1A0B1325), blurRadius: 18, offset: Offset(0, 8))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Maintenance Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF5C6A82))),
                Obx(() => Text('${(c.progress.value * 100).toInt()}% Resolved', style: TextStyle(fontWeight: FontWeight.bold, color: widget.brand))),
              ],
            ),
          ),
          Obx(() => LinearProgressIndicator(value: c.progress.value, color: widget.brand, backgroundColor: const Color(0xFFE4E6ED), minHeight: 4)),
          
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity, height: 40,
              child: ElevatedButton(
                onPressed: () => _openForm(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: widget.brand, elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: widget.brand))),
                child: const Text('Tambah Maintenance'),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Obx(() {
            if (c.items.isEmpty) return const Padding(padding: EdgeInsets.all(20), child: Text("Belum ada maintenance log."));
            
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(zebra),
                columns: const [
                  DataColumn(label: Text('Judul')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Lapor')),
                  DataColumn(label: Text('Selesai')),
                  DataColumn(label: Text('Assignee')),
                  DataColumn(label: Text('Aksi')),
                ],
                rows: c.items.asMap().entries.map((entry) {
                  final i = entry.key;
                  final it = entry.value;
                  return DataRow(cells: [
                    DataCell(Text(it.title, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(_StatusBadge(status: it.status)),
                    DataCell(Text(_fmt(it.openedAt))),
                    DataCell(Text(_fmt(it.closedAt))),
                    DataCell(Text(it.assignee ?? '-')),
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
    if (status == 'Resolved') col = Colors.green;
    if (status == 'Closed') col = Colors.black87;
    if (status == 'In Progress') col = Colors.blue;
    return Text(status, style: TextStyle(color: col, fontWeight: FontWeight.bold));
  }
}