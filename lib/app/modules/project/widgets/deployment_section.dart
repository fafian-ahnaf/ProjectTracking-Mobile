import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:project_tracking/app/data/models/deployment_item.dart';

import '../controllers/deployment_controller.dart';

class DeploymentSection extends StatefulWidget {
  const DeploymentSection({
    super.key,
    required this.brand,
    required this.controllerTag,
    required this.projectId, // 🔥 WAJIB
  });

  final Color brand;
  final String controllerTag;
  final int projectId;

  @override
  State<DeploymentSection> createState() => _DeploymentSectionState();
}

class _DeploymentSectionState extends State<DeploymentSection> {
  late final DeploymentController c;

  // Form State
  String _selectedEnv = 'Development';
  String _selectedStatus = 'Planned';
  DateTime? _startDate;
  DateTime? _endDate;

  final _versionCtrl = TextEditingController(); // Pengganti Title
  final _urlCtrl = TextEditingController();     // Field baru
  final _picCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _startDateCtrl = TextEditingController();
  final _endDateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<DeploymentController>(tag: widget.controllerTag)) {
      Get.put(DeploymentController(tagId: widget.controllerTag), tag: widget.controllerTag);
    }
    c = Get.find<DeploymentController>(tag: widget.controllerTag);
    c.setProjectId(widget.projectId);
  }

  @override
  void dispose() {
    _versionCtrl.dispose(); _urlCtrl.dispose();
    _picCtrl.dispose(); _notesCtrl.dispose();
    _startDateCtrl.dispose(); _endDateCtrl.dispose();
    super.dispose();
  }

  // Helper Date Picker
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

  String _fmt(DateTime? d) => d == null ? '' : '${d.day}/${d.month}/${d.year}';

  // Open Form
  void _openForm({int? editIndex}) {
    if (editIndex != null) {
      final it = c.items[editIndex];
      _versionCtrl.text = it.version ?? '';
      _urlCtrl.text = it.url ?? '';
      _picCtrl.text = it.pic ?? '';
      _notesCtrl.text = it.notes ?? '';
      _selectedEnv = it.environment;
      _selectedStatus = it.status;
      _startDate = it.startDate;
      _endDate = it.endDate;
      _startDateCtrl.text = _fmt(it.startDate);
      _endDateCtrl.text = _fmt(it.endDate);
    } else {
      _versionCtrl.clear(); _urlCtrl.clear();
      _picCtrl.clear(); _notesCtrl.clear();
      _selectedEnv = 'Development';
      _selectedStatus = 'Planned';
      _startDate = null; _endDate = null;
      _startDateCtrl.clear(); _endDateCtrl.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) => _buildForm(ctx, editIndex),
    );
  }

  Widget _buildForm(BuildContext ctx, int? editIndex) {
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
                Text(editIndex == null ? 'Tambah Deployment' : 'Edit Deployment',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: _selectedEnv,
              isExpanded: true,
              decoration: _dec(hint: 'Environment'),
              items: c.environments.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _selectedEnv = v!),
            ),
            const SizedBox(height: 10),

            TextField(controller: _versionCtrl, decoration: _dec(hint: 'Versi (e.g. v1.0.2)')),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: _dec(hint: 'Status'),
              items: c.statuses.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _selectedStatus = v!),
            ),
            const SizedBox(height: 10),

            Row(children: [
              Expanded(child: TextField(controller: _startDateCtrl, readOnly: true, onTap: () => _pickDate(ctx, true), decoration: _dec(hint: 'Mulai'))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: _endDateCtrl, readOnly: true, onTap: () => _pickDate(ctx, false), decoration: _dec(hint: 'Selesai'))),
            ]),
            const SizedBox(height: 10),

            TextField(controller: _urlCtrl, decoration: _dec(hint: 'URL Deploy (http://...)')),
            const SizedBox(height: 10),
            TextField(controller: _picCtrl, decoration: _dec(hint: 'PIC (DevOps/Engineer)')),
            const SizedBox(height: 10),
            TextField(controller: _notesCtrl, maxLines: 2, decoration: _dec(hint: 'Catatan')),
            
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () => _submit(ctx, editIndex),
                style: ElevatedButton.styleFrom(backgroundColor: widget.brand, foregroundColor: Colors.white),
                child: Text(editIndex == null ? 'Simpan' : 'Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit(BuildContext ctx, int? editIndex) {
    // Validasi sederhana (Environment wajib di API)
    if (_selectedEnv.isEmpty) return;

    final item = DeploymentItem(
      environment: _selectedEnv,
      version: _versionCtrl.text.trim().isEmpty ? null : _versionCtrl.text.trim(),
      status: _selectedStatus,
      pic: _picCtrl.text.trim().isEmpty ? null : _picCtrl.text.trim(),
      url: _urlCtrl.text.trim().isEmpty ? null : _urlCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
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
                const Text('Deployment History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF5C6A82))),
                ElevatedButton(
                  onPressed: () => _openForm(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: widget.brand, elevation: 0, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: widget.brand))),
                  child: const Text('Tambah'),
                )
              ],
            ),
          ),
          Obx(() => LinearProgressIndicator(value: c.progress.value, color: widget.brand, backgroundColor: const Color(0xFFE4E6ED), minHeight: 4)),
          
          Obx(() {
            if (c.items.isEmpty) return const Padding(padding: EdgeInsets.all(30), child: Text("Belum ada deployment."));
            
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(zebra),
                columns: const [
                  DataColumn(label: Text('Env')),
                  DataColumn(label: Text('Versi')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Tanggal')),
                  DataColumn(label: Text('Link')),
                  DataColumn(label: Text('PIC')),
                  DataColumn(label: Text('Aksi')),
                ],
                rows: c.items.asMap().entries.map((entry) {
                  final i = entry.key;
                  final it = entry.value;
                  return DataRow(cells: [
                    DataCell(Text(it.environment, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(it.version ?? '-')),
                    DataCell(_StatusBadge(status: it.status)),
                    DataCell(Text(_fmt(it.startDate))),
                    DataCell(it.url != null 
                      ? InkWell(onTap: () => launchUrlString(it.url!), child: const Icon(Icons.link, color: Colors.blue)) 
                      : const Text('-')),
                    DataCell(Text(it.pic ?? '-')),
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
    if (status == 'Success') col = Colors.green;
    if (status == 'Failed') col = Colors.red;
    if (status == 'In Progress') col = Colors.blue;
    return Text(status, style: TextStyle(color: col, fontWeight: FontWeight.bold));
  }
}