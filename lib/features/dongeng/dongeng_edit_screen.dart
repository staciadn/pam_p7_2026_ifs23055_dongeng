import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../data/models/dongeng_model.dart';
import '../../providers/dongeng_provider.dart';
import '../../shared/widgets/top_app_bar_widget.dart';

class DongengEditScreen extends StatefulWidget {
  const DongengEditScreen({super.key, required this.dongengId});
  final String dongengId;

  @override
  State<DongengEditScreen> createState() => _DongengEditScreenState();
}

class _DongengEditScreenState extends State<DongengEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _asalController = TextEditingController();
  final _sinopsisController = TextEditingController();
  final _pesanController = TextEditingController();
  final _tokohController = TextEditingController();

  File? _newImageFile;
  Uint8List? _newImageBytes;
  String _newImageFilename = 'image.jpg';
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) context.read<DongengProvider>().loadDongengById(widget.dongengId);
    });
  }

  @override
  void dispose() {
    _judulController.dispose(); _asalController.dispose();
    _sinopsisController.dispose(); _pesanController.dispose();
    _tokohController.dispose();
    super.dispose();
  }

  void _populateForm(DongengModel d) {
    if (_isInitialized) return;
    _judulController.text = d.judul;
    _asalController.text = d.asal;
    _sinopsisController.text = d.sinopsis;
    _pesanController.text = d.pesan;
    _tokohController.text = d.tokoh;
    _isInitialized = true;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 80, maxWidth: 1024);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _newImageBytes = bytes;
      _newImageFilename = picked.name;
      _newImageFile = kIsWeb ? null : File(picked.path);
    });
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Pilih dari Galeri'),
            onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.gallery); },
          ),
          if (!kIsWeb)
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Ambil Foto'),
              onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.camera); },
            ),
        ]),
      ),
    );
  }

  Future<void> _submit(DongengModel original) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final success = await context.read<DongengProvider>().editDongeng(
      id: original.id!,
      judul: _judulController.text.trim(),
      asal: _asalController.text.trim(),
      sinopsis: _sinopsisController.text.trim(),
      pesan: _pesanController.text.trim(),
      tokoh: _tokohController.text.trim(),
      imageFile: _newImageFile, imageBytes: _newImageBytes, imageFilename: _newImageFilename,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dongeng berhasil diperbarui.')));
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.read<DongengProvider>().errorMessage),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<DongengProvider>(
      builder: (context, provider, _) {
        final dongeng = provider.selectedDongeng;
        if (dongeng != null) _populateForm(dongeng);
        return Scaffold(
          appBar: const TopAppBarWidget(title: 'Edit Dongeng', showBackButton: true),
          body: dongeng == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                GestureDetector(
                  onTap: _showImageSourceSheet,
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outline),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(fit: StackFit.expand, children: [
                        _newImageBytes != null
                            ? Image.memory(_newImageBytes!, fit: BoxFit.cover)
                            : Image.network(dongeng.gambar, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(Icons.menu_book, size: 48, color: colorScheme.primary)),
                        Positioned(bottom: 0, left: 0, right: 0,
                            child: Container(color: Colors.black45, padding: const EdgeInsets.symmetric(vertical: 6),
                                child: const Text('Ketuk untuk ganti gambar (opsional)',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white, fontSize: 12)))),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildField(controller: _judulController, label: 'Judul Dongeng', icon: Icons.title),
                const SizedBox(height: 12),
                _buildField(controller: _asalController, label: 'Asal Daerah', icon: Icons.location_on_outlined),
                const SizedBox(height: 12),
                _buildField(controller: _tokohController, label: 'Tokoh', icon: Icons.people_outline, maxLines: 2),
                const SizedBox(height: 12),
                _buildField(controller: _sinopsisController, label: 'Sinopsis', icon: Icons.description_outlined, maxLines: 4),
                const SizedBox(height: 12),
                _buildField(controller: _pesanController, label: 'Pesan Moral', icon: Icons.lightbulb_outline, maxLines: 3),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _isLoading ? null : () => _submit(dongeng),
                  icon: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save_outlined),
                  label: Text(_isLoading ? 'Menyimpan...' : 'Simpan'),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildField({required TextEditingController controller,
    required String label, required IconData icon, int maxLines = 1}) {
    return TextFormField(
      controller: controller, maxLines: maxLines,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder()),
      validator: (v) => (v == null || v.trim().isEmpty) ? '$label tidak boleh kosong.' : null,
    );
  }
}