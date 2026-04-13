import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/dongeng_provider.dart';
import '../../shared/widgets/top_app_bar_widget.dart';

class DongengAddScreen extends StatefulWidget {
  const DongengAddScreen({super.key});

  @override
  State<DongengAddScreen> createState() => _DongengAddScreenState();
}

class _DongengAddScreenState extends State<DongengAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _asalController = TextEditingController();
  final _sinopsisController = TextEditingController();
  final _pesanController = TextEditingController();
  final _tokohController = TextEditingController();

  File? _imageFile;
  Uint8List? _imageBytes;
  String _imageFilename = 'image.jpg';
  bool _isLoading = false;

  @override
  void dispose() {
    _judulController.dispose(); _asalController.dispose();
    _sinopsisController.dispose(); _pesanController.dispose();
    _tokohController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 80, maxWidth: 1024);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _imageFilename = picked.name;
      _imageFile = kIsWeb ? null : File(picked.path);
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih gambar terlebih dahulu.')));
      return;
    }
    setState(() => _isLoading = true);
    final success = await context.read<DongengProvider>().addDongeng(
      judul: _judulController.text.trim(),
      asal: _asalController.text.trim(),
      sinopsis: _sinopsisController.text.trim(),
      pesan: _pesanController.text.trim(),
      tokoh: _tokohController.text.trim(),
      imageFile: _imageFile, imageBytes: _imageBytes, imageFilename: _imageFilename,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dongeng berhasil ditambahkan.')));
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
    return Scaffold(
      appBar: const TopAppBarWidget(title: 'Tambah Dongeng', showBackButton: true),
      body: SingleChildScrollView(
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
                child: _imageBytes != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(12),
                    child: Image.memory(_imageBytes!, fit: BoxFit.cover, width: double.infinity))
                    : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.add_photo_alternate_outlined, size: 48, color: colorScheme.primary),
                  const SizedBox(height: 8),
                  Text('Ketuk untuk pilih gambar *', style: TextStyle(color: colorScheme.primary)),
                ]),
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
              onPressed: _isLoading ? null : _submit,
              icon: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save_outlined),
              label: Text(_isLoading ? 'Menyimpan...' : 'Simpan'),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildField({required TextEditingController controller,
    required String label, required IconData icon, int maxLines = 1}) {
    return TextFormField(
      controller: controller, maxLines: maxLines,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon),
          border: const OutlineInputBorder()),
      validator: (v) => (v == null || v.trim().isEmpty) ? '$label tidak boleh kosong.' : null,
    );
  }
}