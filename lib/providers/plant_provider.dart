import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../data/models/plant_model.dart';
import '../data/services/plant_repository.dart';

enum PlantStatus { initial, loading, success, error }

class PlantProvider extends ChangeNotifier {
  PlantProvider({PlantRepository? repository})
      : _repository = repository ?? PlantRepository();
  final PlantRepository _repository;

  PlantStatus _status = PlantStatus.initial;
  List<PlantModel> _plants = [];
  PlantModel? _selectedPlant;
  String _errorMessage = '';
  String _searchQuery = '';

  PlantStatus get status => _status;
  PlantModel? get selectedPlant => _selectedPlant;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  List<PlantModel> get plants {
    if (_searchQuery.isEmpty) return List.unmodifiable(_plants);
    return _plants
        .where((p) => p.nama.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> loadPlants() async {
    _setStatus(PlantStatus.loading);
    final result = await _repository.getPlants();
    if (result.success && result.data != null) {
      _plants = result.data!;
      _setStatus(PlantStatus.success);
    } else {
      _errorMessage = result.message;
      _setStatus(PlantStatus.error);
    }
  }

  Future<void> loadPlantById(String id) async {
    _setStatus(PlantStatus.loading);
    final result = await _repository.getPlantById(id);
    if (result.success && result.data != null) {
      _selectedPlant = result.data;
      _setStatus(PlantStatus.success);
    } else {
      _errorMessage = result.message;
      _setStatus(PlantStatus.error);
    }
  }

  Future<bool> addPlant({
    required String nama, required String deskripsi,
    required String manfaat, required String efekSamping,
    File? imageFile, Uint8List? imageBytes, String imageFilename = 'image.jpg',
  }) async {
    _setStatus(PlantStatus.loading);
    final result = await _repository.createPlant(
      nama: nama, deskripsi: deskripsi, manfaat: manfaat,
      efekSamping: efekSamping, imageFile: imageFile,
      imageBytes: imageBytes, imageFilename: imageFilename,
    );
    if (result.success) { await loadPlants(); return true; }
    _errorMessage = result.message;
    _setStatus(PlantStatus.error);
    return false;
  }

  Future<bool> editPlant({
    required String id, required String nama, required String deskripsi,
    required String manfaat, required String efekSamping,
    File? imageFile, Uint8List? imageBytes, String imageFilename = 'image.jpg',
  }) async {
    _setStatus(PlantStatus.loading);
    final result = await _repository.updatePlant(
      id: id, nama: nama, deskripsi: deskripsi, manfaat: manfaat,
      efekSamping: efekSamping, imageFile: imageFile,
      imageBytes: imageBytes, imageFilename: imageFilename,
    );
    if (result.success) { await loadPlantById(id); return true; }
    _errorMessage = result.message;
    _setStatus(PlantStatus.error);
    return false;
  }

  Future<bool> removePlant(String id) async {
    _setStatus(PlantStatus.loading);
    final result = await _repository.deletePlant(id);
    if (result.success) {
      _plants.removeWhere((p) => p.id == id);
      _setStatus(PlantStatus.success);
      return true;
    }
    _errorMessage = result.message;
    _setStatus(PlantStatus.error);
    return false;
  }

  void updateSearchQuery(String query) { _searchQuery = query; notifyListeners(); }
  void clearSelectedPlant() { _selectedPlant = null; notifyListeners(); }
  void _setStatus(PlantStatus s) { _status = s; notifyListeners(); }
}