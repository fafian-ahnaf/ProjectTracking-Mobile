import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_tracking/app/data/models/requirement_item.dart';
import '../controllers/requirement_controller.dart';

class RequirementSection extends StatefulWidget {
  const RequirementSection({
    super.key,
    required this.brand,
    required this.controllerTag,
    this.projectId, // Optional kalau mau di-pass langsung
  });

  final Color brand;
  final String controllerTag;
  final int? projectId;

  @override
  State<RequirementSection> createState() => _RequirementSectionState();
}

class _RequirementSectionState extends State<RequirementSection> {
  late RequirementController c;

  // Controllers Form
  final _titleC = TextEditingController();
  final _picC = TextEditingController();
  final _criteriaC = TextEditingController();
  final _startDateC = TextEditingController();
  final _endDateC = TextEditingController();

  // Form State
  String _type = 'FR';
  String _priority = 'Medium';
  String _status = 'Planned';
  DateTime? _start;
  DateTime? _end;
  int? _editingId;

  @override
  void initState() {
    super.initState();
    // Inject Controller jika belum ada
    if (!Get.isRegistered<RequirementController>(tag: widget.controllerTag)) {
      Get.put(RequirementController(), tag: widget.controllerTag);
    }
    c = Get.find<RequirementController>(tag: widget.controllerTag);

    // Set Project ID agar controller bisa fetch data
    // Kita cari cara mengambil projectId.
    // Cara paling aman: ambil dari parent view via constructor (recommended)
    // Atau ambil dari argument Get.arguments (kurang reliable di widget terpisah)
    if (widget.projectId != null) {
      c.setProjectId(widget.projectId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header & Tombol Tambah
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Daftar Requirement",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            ElevatedButton.icon(
              onPressed: () => _openForm(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.brand,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Tambah"),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // List Requirements
        Obx(() {
          if (c.isLoading.value && c.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (c.items.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Center(
                child: Text(
                  "Belum ada requirement.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: c.items.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final item = c.items[i];
              return _buildReqCard(item);
            },
          );
        }),
      ],
    );
  }

  Widget _buildReqCard(RequirementItem item) {
    Color statusColor = Colors.grey;
    if (item.status == 'In Progress') statusColor = Colors.blue;
    if (item.status == 'Done') statusColor = Colors.green;

    Color priorityColor = Colors.green;
    if (item.priority == 'Medium') priorityColor = Colors.orange;
    if (item.priority == 'High') priorityColor = Colors.red;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge Type (FR/NFR)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: item.type == 'FR'
                      ? Colors.purple.withOpacity(0.1)
                      : Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: item.type == 'FR' ? Colors.purple : Colors.teal,
                  ),
                ),
                child: Text(
                  item.type,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: item.type == 'FR' ? Colors.purple : Colors.teal,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              // Menu Edit/Hapus
              PopupMenuButton(
                child: const Icon(
                  Icons.more_horiz,
                  size: 20,
                  color: Colors.grey,
                ),
                onSelected: (val) {
                  if (val == 'edit') _openForm(context, item: item);
                  if (val == 'delete') _confirmDelete(item);
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'edit', child: Text("Edit")),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text("Hapus", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Badges: Priority & Status
          Row(
            children: [
              _buildBadge(item.priority, priorityColor),
              const SizedBox(width: 8),
              _buildBadge(item.status, statusColor),
              const Spacer(),
              if (item.pic != null)
                Text(
                  "PIC: ${item.pic}",
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
            ],
          ),

          if (item.acceptanceCriteria != null &&
              item.acceptanceCriteria!.isNotEmpty) ...[
            const Divider(height: 16),
            const Text(
              "Acceptance Criteria:",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            Text(
              item.acceptanceCriteria!,
              style: const TextStyle(fontSize: 11, color: Colors.black87),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // --- FORM LOGIC ---
  void _openForm(BuildContext context, {RequirementItem? item}) {
    _editingId = item?.id;
    _titleC.text = item?.title ?? '';
    _picC.text = item?.pic ?? '';
    _criteriaC.text = item?.acceptanceCriteria ?? '';
    _type = item?.type ?? 'FR';
    _priority = item?.priority ?? 'Medium';
    _status = item?.status ?? 'Planned';
    _start = item?.startDate;
    _end = item?.endDate;
    _startDateC.text = _fmt(_start);
    _endDateC.text = _fmt(_end);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _editingId == null ? "Tambah Requirement" : "Edit Requirement",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _titleC,
                decoration: _inputDec("Judul Requirement"),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _dropdown(
                      "Tipe",
                      ['FR', 'NFR'],
                      _type,
                      (v) => setState(() => _type = v!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _dropdown(
                      "Prioritas",
                      ['Low', 'Medium', 'High'],
                      _priority,
                      (v) => setState(() => _priority = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              _dropdown(
                "Status",
                ['Planned', 'In Progress', 'Done'],
                _status,
                (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(child: _dateField("Mulai", _startDateC, true)),
                  const SizedBox(width: 10),
                  Expanded(child: _dateField("Selesai", _endDateC, false)),
                ],
              ),
              const SizedBox(height: 10),

              TextField(controller: _picC, decoration: _inputDec("PIC")),
              const SizedBox(height: 10),
              TextField(
                controller: _criteriaC,
                maxLines: 2,
                decoration: _inputDec("Acceptance Criteria"),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.brand,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Simpan"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_titleC.text.isEmpty) return;

    final item = RequirementItem(
      title: _titleC.text,
      type: _type,
      priority: _priority,
      status: _status,
      pic: _picC.text,
      startDate: _start,
      endDate: _end,
      acceptanceCriteria: _criteriaC.text,
    );

    if (_editingId == null) {
      c.add(item);
    } else {
      c.updateItem(_editingId!, item);
    }
    // Navigator pop akan dipanggil oleh controller setelah sukses
  }

  void _confirmDelete(RequirementItem item) {
    Get.defaultDialog(
      title: 'Hapus?',
      middleText: 'Hapus requirement "${item.title}"?',
      textConfirm: 'Ya',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        c.deleteItem(item.id!);
        Get.back();
      },
    );
  }

  // --- HELPERS ---
  InputDecoration _inputDec(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    contentPadding: const EdgeInsets.all(12),
  );

  Widget _dropdown(
    String label,
    List<String> items,
    String val,
    Function(String?) changed,
  ) {
    return DropdownButtonFormField<String>(
      value: val,
      decoration: _inputDec(label),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: changed,
    );
  }

  Widget _dateField(String label, TextEditingController ctrl, bool isStart) {
    return TextField(
      controller: ctrl,
      readOnly: true,
      decoration: _inputDec(
        label,
      ).copyWith(suffixIcon: const Icon(Icons.calendar_today, size: 16)),
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (d != null) {
          setState(() {
            if (isStart) {
              _start = d;
              ctrl.text = _fmt(d);
            } else {
              _end = d;
              ctrl.text = _fmt(d);
            }
          });
        }
      },
    );
  }

  String _fmt(DateTime? d) => d == null ? '' : '${d.year}-${d.month}-${d.day}';
}
