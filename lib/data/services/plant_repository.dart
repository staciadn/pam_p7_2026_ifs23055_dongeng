import 'dart:io';
import 'dart:typed_data';
import '../models/plant_model.dart';
import '../models/api_response_model.dart';
import 'plant_service.dart';

class PlantRepository {
  PlantRepository({PlantService? service}) : _service = service ?? PlantService();
  final PlantService _service;

  Future<ApiResponse<List<PlantModel>>> getPlants({String search = ''}) async {
    try { return await _service.getPlants(search: search); }
    catch (e) { return ApiResponse(success: false, message: 'Error jaringan: $e'); }
  }

  Future<ApiResponse<PlantModel>> getPlantById(String id) async {
    try { return await _service.getPlantById(id); }
    catch (e) { return ApiResponse(success: false, message: 'Error jaringan: $e'); }
  }

  Future<ApiResponse<String>> createPlant({
    required String nama, required String deskripsi,
    required String manfaat, required String efekSamping,
    File? imageFile, Uint8List? imageBytes, String imageFilename = 'image.jpg',
  }) async {
    try {
      return await _service.createPlant(
        nama: nama, deskripsi: deskripsi, manfaat: manfaat,
        efekSamping: efekSamping, imageFile: imageFile,
        imageBytes: imageBytes, imageFilename: imageFilename,
      );
    } catch (e) { return ApiResponse(success: false, message: 'Error jaringan: $e'); }
  }

  Future<ApiResponse<void>> updatePlant({
    required String id, required String nama, required String deskripsi,
    required String manfaat, required String efekSamping,
    File? imageFile, Uint8List? imageBytes, String imageFilename = 'image.jpg',
  }) async {
    try {
      return await _service.updatePlant(
        id: id, nama: nama, deskripsi: deskripsi, manfaat: manfaat,
        efekSamping: efekSamping, imageFile: imageFile,
        imageBytes: imageBytes, imageFilename: imageFilename,
      );
    } catch (e) { return ApiResponse(success: false, message: 'Error jaringan: $e'); }
  }

  Future<ApiResponse<void>> deletePlant(String id) async {
    try { return await _service.deletePlant(id); }
    catch (e) { return ApiResponse(success: false, message: 'Error jaringan: $e'); }
  }
}