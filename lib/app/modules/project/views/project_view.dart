// lib/app/modules/project/views/project_view.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:mime/mime.dart';

import 'package:project_tracking/app/data/models/project_item.dart';
import 'package:project_tracking/app/modules/project/views/project_detail_view.dart';
import '../controllers/project_controller.dart';

class ProjectView extends GetView<ProjectController> {
  const ProjectView({super.key});

  Color get brand => const Color(0xFFF69220);
  Color get background => const Color(0xFFF6F7FB);

  @override
  Widget build(BuildContext context) {
    Get.put(ProjectController());
    final keyword = ''.obs;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Project'),
        backgroundColor: brand,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final q = await showSearch<String?>(
                context: context,
                delegate: _SimpleSearchDelegate(initial: keyword.value),
              );
              if (q != null) keyword.value = q;
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Header oranye + tombol
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            decoration: BoxDecoration(
              color: brand,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pantau Progres Pekerjaanmu:',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'status, timeline, dan dokumen kontrak.',
                        style: TextStyle(color: Colors.white, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _openAddDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: brand,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Tambah Project'),
                ),
              ],
            ),
          ),


          // tabel
          Expanded(
            child: Obx(() {
              final list = controller.projects.where((pjt) => _hit(pjt, keyword.value)).toList();

              if (list.isEmpty) {
                return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.folder_open, size: 60, color: brand),
                    const SizedBox(height: 10),
                    const Text('Belum Ada Project', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ]),
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DataTable(
                  columnSpacing: 24,
                  headingRowHeight: 44,
                  dataRowMinHeight: 48,
                  dataRowMaxHeight: 64,
                  columns: const [
                    DataColumn(label: Text('Nama Proyek')),
                    DataColumn(label: Text('PIC')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Mulai')),
                    DataColumn(label: Text('Selesai')),
                    DataColumn(label: Text('%')),
                    DataColumn(label: Text('Dokumen')),
                    DataColumn(label: Text('Kegiatan')),
                    DataColumn(label: Text('Aksi')),
                  ],
                  rows: List.generate(list.length, (i) {
                    final pjt = list[i];
                    return DataRow(cells: [
                      DataCell(
                        InkWell(
                          onTap: () => _openDetail(pjt),
                          child: Text(pjt.name, style: const TextStyle(decoration: TextDecoration.underline)),
                        ),
                      ),
                      DataCell(Text(pjt.pic.isEmpty ? '-' : pjt.pic)),
                      DataCell(Text(pjt.status)),
                      DataCell(Text(_fmt(pjt.startDate))),
                      DataCell(Text(_fmt(pjt.endDate))),
                      DataCell(Text('${pjt.progress}%')),

                      // ==== KOLUM DOKUMEN: tampilkan nama file & bisa diklik ====
                      DataCell(
                        (pjt.documentPath == null || pjt.documentPath!.isEmpty)
                            ? const Text('-')
                            : ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 220),
                                child: InkWell(
                                  onTap: () => _openDoc(pjt.documentPath),
                                  child: Text(
                                    p.basename(pjt.documentPath!),
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                      ),

                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 260),
                          child: Text(
                            pjt.activity.isEmpty ? '-' : pjt.activity,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      DataCell(Row(children: [
                        IconButton(icon: const Icon(Icons.visibility_outlined), onPressed: () => _openDetail(pjt)),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _openAddDialog(
                            context,
                            editIndex: controller.projects.indexOf(pjt),
                            initial: pjt,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            final idx = controller.projects.indexOf(pjt);
                            if (idx >= 0) controller.removeAt(idx);
                          },
                        ),
                      ])),
                    ]);
                  }),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // helpers
  String _fmt(DateTime? d) => d == null ? '-' : '${d.day}/${d.month}/${d.year}';

  bool _hit(ProjectItem pjt, String q) {
    final k = q.trim().toLowerCase();
    if (k.isEmpty) return true;
    bool s(String t) => t.toLowerCase().contains(k);
    return s(pjt.name) ||
        s(pjt.pic) ||
        s(pjt.status) ||
        s(pjt.activity) ||
        _fmt(pjt.startDate).contains(k) ||
        _fmt(pjt.endDate).contains(k) ||
        pjt.progress.toString() == k;
  }

  Future<void> _openAddDialog(BuildContext context, {int? editIndex, ProjectItem? initial}) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: _AddProjectForm(
          brand: brand,
          initial: initial,
          onSubmit: (item) {
            if (editIndex != null) {
              controller.updateAt(editIndex, item);
            } else {
              controller.add(item);
            }
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Project disimpan')));
          },
        ),
      ),
    );
  }

  void _openDetail(ProjectItem item) =>
      Get.to(() => ProjectDetailView(item: item, brand: brand));

  Future<void> _openDoc(String? path) async {
    if (path == null || path.isEmpty) return;
    await OpenFilex.open(path);
  }
}

// ====== small pieces ======
class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE0E0E6)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF1C1C39))),
        ]),
      ),
    );
  }
}

// ====== Form tambah/edit ======
class _AddProjectForm extends StatefulWidget {
  final Color brand;
  final ProjectItem? initial;
  final Function(ProjectItem) onSubmit;
  const _AddProjectForm({required this.brand, this.initial, required this.onSubmit});

  @override
  State<_AddProjectForm> createState() => _AddProjectFormState();
}

class _AddProjectFormState extends State<_AddProjectForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameC;
  late final TextEditingController _picC;
  late final TextEditingController _activityC;
  String _status = 'Belum Mulai';
  DateTime? _start;
  DateTime? _end;
  double _progress = 0;

  // Dokumen
  String? _documentPath;         // path lokal (mobile/desktop)
  Uint8List? _documentBytes;     // bytes (web / fallback)
  String? _documentName;         // nama file yg ditampilkan
  String? _documentMime;         // mime type

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController(text: widget.initial?.name ?? '');
    _picC = TextEditingController(text: widget.initial?.pic ?? '');
    _activityC = TextEditingController(text: widget.initial?.activity ?? '');
    _status = widget.initial?.status ?? 'Belum Mulai';
    _start = widget.initial?.startDate;
    _end = widget.initial?.endDate;
    _progress = (widget.initial?.progress ?? 0).toDouble();
    _documentPath = widget.initial?.documentPath;
    _documentName = widget.initial?.documentPath != null
        ? p.basename(widget.initial!.documentPath!)
        : null;
  }

  String _fmt(DateTime? d) => d == null ? 'Pilih tanggal' : '${d.day}/${d.month}/${d.year}';

  // Simpan file ke folder app (untuk mobile/desktop)
  Future<String?> _savePickedFile(PlatformFile f) async {
    String ext = p.extension(f.name);
    if (ext.isEmpty) {
      final mime = lookupMimeType(f.name) ?? '';
      if (mime.contains('pdf')) {
        ext = '.pdf';
      } else if (mime.contains('png')) {
        ext = '.png';
      } else if (mime.contains('jpeg') || mime.contains('jpg')) {
        ext = '.jpg';
      } else if (mime.contains('webp')) {
        ext = '.webp';
      } else if (mime.contains('gif')) {
        ext = '.gif';
      } else {
        ext = p.extension(f.path ?? '');
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    final fileName = f.name.isNotEmpty ? f.name : 'contract_${DateTime.now().millisecondsSinceEpoch}$ext';
    final dest = File(p.join(dir.path, fileName));

    try {
      if (f.bytes != null) {
        await dest.writeAsBytes(f.bytes!, flush: true);
      } else if (f.path != null) {
        await File(f.path!).copy(dest.path);
      } else {
        return null;
      }
      return dest.path;
    } catch (e) {
      // ignore: avoid_print
      print('savePickedFile error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(children: [
              _L('Nama Proyek', TextFormField(
                controller: _nameC,
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                decoration: _input(),
              )),
              const SizedBox(height: 10),
              _L('PIC', TextFormField(controller: _picC, decoration: _input())),
              const SizedBox(height: 10),
              _L('Status', DropdownButtonFormField<String>(
                value: _status,
                items: const [
                  DropdownMenuItem(value: 'Belum Mulai', child: Text('Belum Mulai')),
                  DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                  DropdownMenuItem(value: 'Review', child: Text('Review')),
                  DropdownMenuItem(value: 'Selesai', child: Text('Selesai')),
                ],
                onChanged: (v) => setState(() => _status = v ?? _status),
                decoration: _input(),
              )),
              const SizedBox(height: 10),

              Row(children: [
                Expanded(child: _L('Tanggal Mulai', InkWell(
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context, firstDate: DateTime(now.year - 2),
                      lastDate: DateTime(now.year + 3), initialDate: _start ?? now,
                    );
                    if (picked != null) setState(() => _start = picked);
                  },
                  child: _dateBox(_fmt(_start)),
                ))),
                const SizedBox(width: 10),
                Expanded(child: _L('Tanggal Selesai', InkWell(
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context, firstDate: DateTime(now.year - 2),
                      lastDate: DateTime(now.year + 3), initialDate: _end ?? now,
                    );
                    if (picked != null) setState(() => _end = picked);
                  },
                  child: _dateBox(_fmt(_end)),
                ))),
              ]),
              const SizedBox(height: 10),

              _L('Persentase (${_progress.toInt()}%)', Slider(
                value: _progress, min: 0, max: 100, divisions: 20,
                activeColor: widget.brand, onChanged: (v) => setState(() => _progress = v),
              )),

              // ===== Dokumen Kontrak (tampilkan nama file/chip) =====
              _L('Dokumen Kontrak', Row(
                children: [
                  Expanded(
                    child: (_documentName == null || _documentName!.isEmpty)
                        ? const Text('Belum ada file')
                        : _FileChip(
                            name: _documentName!,
                            onClear: () {
                              setState(() {
                                _documentPath = null;
                                _documentBytes = null;
                                _documentName  = null;
                                _documentMime  = null;
                              });
                            },
                          ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: () async {
                      final res = await FilePicker.platform.pickFiles(
                        type: FileType.any,
                        withData: true, // penting agar dapat bytes di web/android
                      );
                      final f = res?.files.single;
                      if (f == null) return;

                      _documentName = f.name;
                      _documentMime = lookupMimeType(f.name) ?? lookupMimeType(f.path ?? '');

                      String? savedPath;
                      if (!kIsWeb) {
                        savedPath = await _savePickedFile(f);
                      }

                      setState(() {
                        _documentPath  = savedPath;   // null di web
                        _documentBytes = f.bytes;     // bytes utk preview web
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Dokumen dipilih: ${_documentName!}')),
                      );
                    },
                  ),
                ],
              )),

              if ((_documentPath != null && _documentPath!.isNotEmpty) || _documentBytes != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _DocPreviewCard(
                    brand: widget.brand,
                    fileName: _documentName,
                    path: _documentPath,
                    bytes: _documentBytes,
                    mime: _documentMime,
                    onOpen: () {
                      if (_documentPath != null && _documentPath!.isNotEmpty) {
                        OpenFilex.open(_documentPath!);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tidak ada path file untuk dibuka')),
                        );
                      }
                    },
                  ),
                ),

              const SizedBox(height: 10),

              _L('Kegiatan', TextFormField(
                controller: _activityC, maxLines: 3,
                decoration: _input().copyWith(hintText: 'Tuliskan deskripsi kegiatan'),
              )),

              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: widget.brand, foregroundColor: Colors.white),
                  onPressed: () {
                    if (_formKey.currentState?.validate() != true) return;

                    if (_start != null && _end != null && _end!.isBefore(_start!)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tanggal selesai harus setelah tanggal mulai')),
                      );
                      return;
                    }

                    // 🔥 Pastikan path tersimpan (agar muncul di kolom Dokumen)
                    final savedPath = _documentPath ?? '';

                    widget.onSubmit(ProjectItem(
                      name: _nameC.text.trim(),
                      pic: _picC.text.trim(),
                      status: _status,
                      startDate: _start,
                      endDate: _end,
                      progress: _progress.toInt(),
                      documentPath: savedPath,
                      activity: _activityC.text.trim(),
                    ));
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan'),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _dateBox(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(color: const Color(0xFFF3EFEF), borderRadius: BorderRadius.circular(6)),
        child: Text(text),
      );

  InputDecoration _input() => InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF3EFEF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
      );
}

// Chip nama file + tombol hapus
class _FileChip extends StatelessWidget {
  const _FileChip({required this.name, required this.onClear});
  final String name;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFEF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file, size: 18),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onClear,
            child: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );
  }
}

// Kartu preview dokumen (gambar / pdf / lainnya)
class _DocPreviewCard extends StatelessWidget {
  const _DocPreviewCard({
    required this.brand,
    this.path,
    this.bytes,
    this.fileName,
    this.mime,
    this.onOpen,
  });

  final Color brand;
  final String? path;
  final Uint8List? bytes;
  final String? fileName;
  final String? mime;
  final VoidCallback? onOpen;

  bool get _hasPath => path != null && path!.isNotEmpty;

  bool _isImage() {
    final lower = (mime ?? '').toLowerCase();
    if (lower.startsWith('image/')) return true;
    final ext = p.extension(fileName ?? path ?? '').toLowerCase();
    return {'.png', '.jpg', '.jpeg', '.webp', '.gif'}.contains(ext);
  }

  bool _isPdf() {
    final lower = (mime ?? '').toLowerCase();
    if (lower == 'application/pdf') return true;
    final ext = p.extension(fileName ?? path ?? '').toLowerCase();
    return ext == '.pdf';
  }

  @override
  Widget build(BuildContext context) {
    final exists = _hasPath ? File(path!).existsSync() : false;

    Widget content() {
      if (_isImage()) {
        if (_hasPath && exists) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(path!),
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          );
        } else if (bytes != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              bytes!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          );
        }
      }

      // Default: PDF atau file lain
      return Row(
        children: [
          Icon(_isPdf() ? Icons.picture_as_pdf : Icons.description_outlined),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              fileName ?? (_hasPath ? p.basename(path!) : 'Dokumen terpilih'),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.open_in_new, size: 18),
            style: ElevatedButton.styleFrom(
              backgroundColor: brand,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            label: const Text('Buka'),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E6)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: content(),
    );
  }
}

class _L extends StatelessWidget {
  final String label;
  final Widget child;
  const _L(this.label, this.child);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13)),
      const SizedBox(height: 6),
      child,
    ]);
  }
}

// ====== Search delegate sederhana ======
class _SimpleSearchDelegate extends SearchDelegate<String?> {
  _SimpleSearchDelegate({required this.initial}) : super(searchFieldLabel: 'Cari project, PIC, status…') {
    query = initial;
  }
  final String initial;

  @override
  List<Widget>? buildActions(BuildContext context) =>
      [if (query.isNotEmpty) IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear))];

  @override
  Widget? buildLeading(BuildContext context) =>
      IconButton(onPressed: () => close(context, null), icon: const Icon(Icons.arrow_back));

  @override
  Widget buildResults(BuildContext context) {
    close(context, query);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) => const SizedBox.shrink();
}
