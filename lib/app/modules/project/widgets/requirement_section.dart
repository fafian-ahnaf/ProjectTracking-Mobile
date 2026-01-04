// ------------------------------------------------------------
//  REQUIREMENT SECTION – FORM MIRIP DESAIN DIATAS (tanpa deskripsi,
//  tanpa acceptance criteria, tanpa meta)
// ------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:project_tracking/app/modules/project/controllers/requirement_controller.dart';

class RequirementSection extends StatefulWidget {
  const RequirementSection({
    super.key,
    required this.brand,
    required this.controllerTag,
  });

  final Color brand;
  final String controllerTag;

  @override
  State<RequirementSection> createState() => _RequirementSectionState();
}

class _RequirementSectionState extends State<RequirementSection> {
  // live preview untuk baris draft (hanya judul sekarang)
  final _draftTitle = ''.obs;

  final _noteC = TextEditingController();
  final List<PlatformFile> _pickedFiles = [];

  // PIC & tanggal mulai / selesai
  final TextEditingController _picC = TextEditingController();
  final Rxn<DateTime> _startDate = Rxn<DateTime>();
  final Rxn<DateTime> _endDate = Rxn<DateTime>();

  // lebar kolom tabel
  static const double _wNo = 64;   // dibesarkan sedikit supaya ceklis + nomor muat
  static const double _wTitle = 260;
  static const double _wPic = 140;
  static const double _wStart = 120;
  static const double _wEnd = 120;
  static const double _wType = 90;
  static const double _wPriority = 110;
  static const double _wStatus = 120;
  static const double _wCriteria = 320;
  static const double _wAksi = 120;

  double get _totalWidth =>
      _wNo +
      _wTitle +
      _wPic +
      _wStart +
      _wEnd +
      _wType +
      _wPriority +
      _wStatus +
      _wCriteria +
      _wAksi;

  RequirementController get c =>
      Get.find<RequirementController>(tag: widget.controllerTag);

  @override
  void dispose() {
    _noteC.dispose();
    _picC.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '-';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final current = (isStart ? _startDate.value : _endDate.value) ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      if (isStart) {
        _startDate.value = picked;
        // jaga supaya endDate tidak sebelum startDate
        if (_endDate.value != null && _endDate.value!.isBefore(picked)) {
          _endDate.value = picked;
        }
      } else {
        _endDate.value = picked;
      }
    }
  }

  void _onSave() {
    // simpan ke controller (PIC & tanggal ikut)
    c.save(
      pic: _picC.text,
      startDate: _startDate.value,
      endDate: _endDate.value,
    );

    // reset draft preview & input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _draftTitle.value = '';
      _picC.clear();
      _startDate.value = null;
      _endDate.value = null;
      c.titleC.clear();
      c.criteriaC.clear(); // boleh dibiarkan kosong di controller
    });
  }

  @override
  Widget build(BuildContext context) {
    final brand = widget.brand;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E6)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // ================= HEADER =================
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: brand.withOpacity(.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: brand, width: 1),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Requirements',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // ======= PROGRESS REQUIREMENT (BAR + % ) =======
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
            child: Obx(() {
              final pct = (c.progress.value * 100).round();
              return Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: c.progress.value, // 0..1
                        minHeight: 6,
                        backgroundColor: const Color(0xFFE0E0E6),
                        valueColor: AlwaysStoppedAnimation<Color>(brand),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$pct%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }),
          ),

          // ================ FORM =====================
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1) Judul requirement
                const Text(
                  'Judul requirement',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                _RoundedField(
                  child: TextField(
                    controller: c.titleC,
                    onChanged: (_) => _draftTitle.value = c.titleC.text,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 2) PIC + Tanggal mulai
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PIC requirement',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _RoundedField(
                            child: TextField(
                              controller: _picC,
                              decoration: const InputDecoration(
                                hintText: 'Nama PIC',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tanggal mulai',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(
                            () => GestureDetector(
                              onTap: () => _pickDate(isStart: true),
                              child: _RoundedField(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _startDate.value == null
                                          ? 'Pilih tanggal'
                                          : _formatDate(_startDate.value),
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 3) Tanggal selesai + Type
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tanggal selesai',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(
                            () => GestureDetector(
                              onTap: () => _pickDate(isStart: false),
                              child: _RoundedField(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _endDate.value == null
                                          ? 'Pilih tanggal'
                                          : _formatDate(_endDate.value),
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tipe requirement',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _DropdownBox(
                            value: c.type,
                            items: const ['FR', 'NFR', 'Bug', 'Change'],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 4) Priority + Status
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Priority',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _DropdownBox(
                            value: c.priority,
                            items: const ['Low', 'Medium', 'High', 'Critical'],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _DropdownBox(
                            value: c.status,
                            items: const ['Planned', 'In Progress', 'Done'],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 5) Tombol Tambahkan
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brand,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Tambahkan'),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===================== TABEL =====================
          _TableBox(
            totalWidth: _totalWidth,
            header: _HeaderRow(
              wNo: _wNo,
              wTitle: _wTitle,
              wPic: _wPic,
              wStart: _wStart,
              wEnd: _wEnd,
              wType: _wType,
              wPriority: _wPriority,
              wStatus: _wStatus,
              wCriteria: _wCriteria,
              wAksi: _wAksi,
            ),
            body: Obx(() {
              final items = c.items;
              final showDraft = _draftTitle.value.trim().isNotEmpty;

              return Column(
                children: [
                  if (showDraft)
                    _DataRow(
                      wNo: _wNo,
                      wTitle: _wTitle,
                      wPic: _wPic,
                      wStart: _wStart,
                      wEnd: _wEnd,
                      wType: _wType,
                      wPriority: _wPriority,
                      wStatus: _wStatus,
                      wCriteria: _wCriteria,
                      wAksi: _wAksi,
                      id: '—',
                      title: _draftTitle.value.isEmpty
                          ? '(tanpa judul)'
                          : _draftTitle.value,
                      pic: _picC.text.isEmpty ? '-' : _picC.text,
                      startDate: _formatDate(_startDate.value),
                      endDate: _formatDate(_endDate.value),
                      type: c.type.value,
                      priority: c.priority.value,
                      status: c.status.value,
                      criteria: '-', // tidak ada form criteria lagi
                      brand: brand,
                      isDraft: true,
                    ),
                  ...items.map(
                    (e) => _DataRow(
                      wNo: _wNo,
                      wTitle: _wTitle,
                      wPic: _wPic,
                      wStart: _wStart,
                      wEnd: _wEnd,
                      wType: _wType,
                      wPriority: _wPriority,
                      wStatus: _wStatus,
                      wCriteria: _wCriteria,
                      wAksi: _wAksi,
                      id: '${e.id}',
                      title: e.title,
                      pic: (e.pic ?? '').isEmpty ? '-' : e.pic!,
                      startDate: _formatDate(e.startDate),
                      endDate: _formatDate(e.endDate),
                      type: e.type,
                      priority: e.priority,
                      status: e.status,
                      criteria: e.criteria.isEmpty ? '-' : e.criteria,
                      brand: brand,
                      onDelete: () => c.remove(e.id),
                      onSetStatus: (v) => c.setStatus(e.id, v),
                    ),
                  ),
                ],
              );
            }),
          ),

          // ===================== DOKUMEN/CATATAN =====================
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE0E0E6)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _noteC.text.isEmpty ? 'yes' : _noteC.text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF232B3A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
    UI FIELD COMPONENTS
============================================================ */

class _RoundedField extends StatelessWidget {
  const _RoundedField({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        border: Border.all(color: const Color(0xFFE0E0E6)),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}

class _DropdownBox extends StatelessWidget {
  const _DropdownBox({required this.value, required this.items});
  final RxString value;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        border: Border.all(color: const Color(0xFFE0E0E6)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Obx(
        () => DropdownButton<String>(
          value: value.value,
          isExpanded: true,
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => value.value = v ?? value.value,
        ),
      ),
    );
  }
}

/* ============================================================
    TABEL & ROW
============================================================ */

class _TableBox extends StatefulWidget {
  const _TableBox({
    required this.totalWidth,
    required this.header,
    required this.body,
  });

  final double totalWidth;
  final Widget header;
  final Widget body;

  @override
  State<_TableBox> createState() => _TableBoxState();
}

class _TableBoxState extends State<_TableBox> {
  final ScrollController _scroll = ScrollController();
  final ScrollController _scrollHeader = ScrollController();

  @override
  void initState() {
    super.initState();

    _scroll.addListener(() {
      if (_scrollHeader.hasClients &&
          _scrollHeader.offset != _scroll.offset) {
        _scrollHeader.jumpTo(_scroll.offset);
      }
    });

    _scrollHeader.addListener(() {
      if (_scroll.hasClients &&
          _scroll.offset != _scrollHeader.offset) {
        _scroll.jumpTo(_scrollHeader.offset);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final line = const Color(0xFFE6E9EF);
    final softBg = const Color(0xFFF6F7FB);

    return SizedBox(
      height: 420,
      child: Column(
        children: [
          SingleChildScrollView(
            controller: _scrollHeader,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: widget.totalWidth),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                color: softBg,
                child: widget.header,
              ),
            ),
          ),
          Container(height: 1, color: line),
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: widget.totalWidth),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: widget.body,
                ),
              ),
            ),
          ),
          Container(height: 1, color: line),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.wNo,
    required this.wTitle,
    required this.wPic,
    required this.wStart,
    required this.wEnd,
    required this.wType,
    required this.wPriority,
    required this.wStatus,
    required this.wCriteria,
    required this.wAksi,
  });

  final double wNo,
      wTitle,
      wPic,
      wStart,
      wEnd,
      wType,
      wPriority,
      wStatus,
      wCriteria,
      wAksi;

  @override
  Widget build(BuildContext context) {
    Widget h(String t, double w, {TextAlign align = TextAlign.left}) =>
        SizedBox(
          width: w,
          child: Text(
            t,
            textAlign: align,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        );

    return Row(
      children: [
        h('#', wNo),
        h('Judul', wTitle),
        h('PIC', wPic),
        h('Mulai', wStart),
        h('Selesai', wEnd),
        h('Type', wType),
        h('Priority', wPriority),
        h('Status', wStatus),
        h('Acceptance Criteria', wCriteria),
        h('Aksi', wAksi, align: TextAlign.right),
      ],
    );
  }
}

/* ================== DATA ROW DENGAN CHECKBOX ================== */

class _DataRow extends StatefulWidget {
  const _DataRow({
    required this.wNo,
    required this.wTitle,
    required this.wPic,
    required this.wStart,
    required this.wEnd,
    required this.wType,
    required this.wPriority,
    required this.wStatus,
    required this.wCriteria,
    required this.wAksi,
    required this.id,
    required this.title,
    required this.pic,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.priority,
    required this.status,
    required this.criteria,
    required this.brand,
    this.onDelete,
    this.onSetStatus,
    this.isDraft = false,
  });

  final double wNo,
      wTitle,
      wPic,
      wStart,
      wEnd,
      wType,
      wPriority,
      wStatus,
      wCriteria,
      wAksi;

  final String id,
      title,
      pic,
      startDate,
      endDate,
      type,
      priority,
      status,
      criteria;

  final Color brand;
  final VoidCallback? onDelete;
  final ValueChanged<String>? onSetStatus;
  final bool isDraft;

  @override
  State<_DataRow> createState() => _DataRowState();
}

class _DataRowState extends State<_DataRow> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    final line = const Color(0xFFE6E9EF);

    Widget _cell(String text, double w, {bool bold = false}) => SizedBox(
          width: w,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.2,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration:
          BoxDecoration(border: Border(bottom: BorderSide(color: line))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // kolom # + checkbox
          SizedBox(
            width: widget.wNo,
            child: Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: Checkbox(
                    value: _checked,
                    onChanged: (v) {
                      setState(() => _checked = v ?? false);
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.id,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          _cell(widget.title, widget.wTitle, bold: true),
          _cell(widget.pic, widget.wPic),
          _cell(widget.startDate, widget.wStart),
          _cell(widget.endDate, widget.wEnd),
          _cell(widget.type, widget.wType),
          _cell(widget.priority, widget.wPriority),
          _cell(widget.status, widget.wStatus),
          _cell(widget.criteria, widget.wCriteria),

          SizedBox(
            width: widget.wAksi,
            child: Align(
              alignment: Alignment.centerRight,
              child: widget.isDraft
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.brand.withOpacity(.10),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: widget.brand.withOpacity(.25),
                        ),
                      ),
                      child: Text(
                        'Draft',
                        style: TextStyle(
                          color: widget.brand,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuButton<String>(
                          onSelected: (v) => widget.onSetStatus?.call(v),
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                                value: 'Planned', child: Text('Set Planned')),
                            PopupMenuItem(
                                value: 'In Progress',
                                child: Text('Set In Progress')),
                            PopupMenuItem(
                                value: 'Done', child: Text('Set Done')),
                          ],
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(Icons.more_vert, size: 20),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: widget.onDelete,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
