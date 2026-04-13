import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../data/models/dongeng_model.dart';
import '../data/services/dongeng_repository.dart';

enum DongengStatus { initial, loading, success, error }

class DongengProvider extends ChangeNotifier {
  DongengProvider({DongengRepository? repository})
      : _repository = repository ?? DongengRepository();
  final DongengRepository _repository;

  DongengStatus _status = DongengStatus.initial;
  List<DongengModel> _dongengList = [];
  DongengModel? _selectedDongeng;
  String _errorMessage = '';
  String _searchQuery = '';

  DongengStatus get status => _status;
  DongengModel? get selectedDongeng => _selectedDongeng;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  List<DongengModel> get dongengList {
    if (_searchQuery.isEmpty) return List.unmodifiable(_dongengList);
    return _dongengList
        .where((d) => d.judul.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> loadDongeng() async {
    _setStatus(DongengStatus.loading);
    final result = await _repository.getDongeng();
    if (result.success && result.data != null) {
      _dongengList = result.data!;
      _setStatus(DongengStatus.success);
    } else {
      _errorMessage = result.message;
      _setStatus(DongengStatus.error);
    }
  }

  Future<void> loadDongengById(String id) async {
    _setStatus(DongengStatus.loading);
    final result = await _repository.getDongengById(id);
    if (result.success && result.data != null) {
      _selectedDongeng = result.data;
      _setStatus(DongengStatus.success);
    } else {
      _errorMessage = result.message;
      _setStatus(DongengStatus.error);
    }
  }

  Future<bool> addDongeng({
    required String judul, required String asal,
    required String sinopsis, required String pesan, required String tokoh,
    File? imageFile, Uint8List? imageBytes, String imageFilename = 'image.jpg',
  }) async {
    _setStatus(DongengStatus.loading);
    final result = await _repository.createDongeng(
      judul: judul, asal: asal, sinopsis: sinopsis,
      pesan: pesan, tokoh: tokoh,
      imageFile: imageFile, imageBytes: imageBytes, imageFilename: imageFilename,
    );
    if (result.success) { await loadDongeng(); return true; }
    _errorMessage = result.message;
    _setStatus(DongengStatus.error);
    return false;
  }

  Future<bool> editDongeng({
    required String id, required String judul, required String asal,
    required String sinopsis, required String pesan, required String tokoh,
    File? imageFile, Uint8List? imageBytes, String imageFilename = 'image.jpg',
  }) async {
    _setStatus(DongengStatus.loading);
    final result = await _repository.updateDongeng(
      id: id, judul: judul, asal: asal, sinopsis: sinopsis,
      pesan: pesan, tokoh: tokoh,
      imageFile: imageFile, imageBytes: imageBytes, imageFilename: imageFilename,
    );
    if (result.success) { await loadDongengById(id); return true; }
    _errorMessage = result.message;
    _setStatus(DongengStatus.error);
    return false;
  }

  Future<bool> removeDongeng(String id) async {
    _setStatus(DongengStatus.loading);
    final result = await _repository.deleteDongeng(id);
    if (result.success) {
      _dongengList.removeWhere((d) => d.id == id);
      _setStatus(DongengStatus.success);
      return true;
    }
    _errorMessage = result.message;
    _setStatus(DongengStatus.error);
    return false;
  }

  void updateSearchQuery(String query) { _searchQuery = query; notifyListeners(); }
  void clearSelected() { _selectedDongeng = null; notifyListeners(); }
  void _setStatus(DongengStatus s) { _status = s; notifyListeners(); }
}