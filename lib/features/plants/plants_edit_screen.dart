// lib/features/plants/plants_edit_screen.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../data/models/plant_model.dart';
import '../../providers/plant_provider.dart';
import '../../shared/widgets/top_app_bar_widget.dart';

class PlantsEditScreen extends StatefulWidget {
  const PlantsEditScreen({super.key, required this.plantId});

  final String plantId; // UUID

  @override
  State<PlantsEditScreen> createState() => _PlantsEditScreenState();
}

class _PlantsEditScreenState extends State<PlantsEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _manfaatController = TextEditingController();
  final _efekSampingController = TextEditingController();

  File? _newImageFile;        // mobile
  Uint8List? _newImageBytes;  // web & preview
  String _newImageFilename = 'image.jpg';
  bool _isLoading = false;
  bool _isInitialized = false;

  bool get _hasNewImage => _newImageBytes != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        context.read<PlantProvider>().loadPlantById(widget.plantId);
      }
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _manfaatController.dispose();
    _efekSampingController.dispose();
    super.dispose();
  }

  void _populateForm(PlantModel plant) {
    if (_isInitialized) return;
    _namaController.text = plant.nama;
    _deskripsiController.text = plant.deskripsi;
    _manfaatController.text = plant.manfaat;
    _efekSampingController.text = plant.efekSamping;
    _isInitialized = true;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
    );
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Ambil Foto'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(PlantModel original) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await context.read<PlantProvider>().editPlant(
      id: original.id!,
      nama: _namaController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
      manfaat: _manfaatController.text.trim(),
      efekSamping: _efekSampingController.text.trim(),
      // null di keduanya = server pertahankan gambar lama
      imageFile: _newImageFile,
      imageBytes: _newImageBytes,
      imageFilename: _newImageFilename,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanaman berhasil diperbarui.')),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<PlantProvider>().errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<PlantProvider>(
      builder: (context, provider, _) {
        final plant = provider.selectedPlant;

        if (plant != null) _populateForm(plant);

        return Scaffold(
          appBar: const TopAppBarWidget(
            title: 'Edit Tanaman',
            showBackButton: true,
          ),
          body: plant == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Preview Gambar ──
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
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Gambar baru (bytes) jika sudah dipilih,
                            // atau gambar lama dari URL API
                            _hasNewImage
                                ? Image.memory(
                              _newImageBytes!,
                              fit: BoxFit.cover,
                            )
                                : Image.network(
                              plant.gambar,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.eco,
                                size: 48,
                                color: colorScheme.primary,
                              ),
                            ),
                            // Overlay hint
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.black45,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6),
                                child: const Text(
                                  'Ketuk untuk ganti gambar (opsional)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildField(
                    controller: _namaController,
                    label: 'Nama Tanaman',
                    icon: Icons.local_florist_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _deskripsiController,
                    label: 'Deskripsi',
                    icon: Icons.description_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _manfaatController,
                    label: 'Manfaat',
                    icon: Icons.favorite_outline,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _efekSampingController,
                    label: 'Efek Samping',
                    icon: Icons.warning_amber_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _isLoading ? null : () => _submit(plant),
                    icon: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2),
                    )
                        : const Icon(Icons.save_outlined),
                    label:
                    Text(_isLoading ? 'Menyimpan...' : 'Simpan'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label tidak boleh kosong.';
        }
        return null;
      },
    );
  }
}