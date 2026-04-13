import 'dart:io';
import 'dart:typed_data';
import '../models/dongeng_model.dart';
import '../models/api_response_model.dart';
import 'dongeng_service.dart';

class DongengRepository {
  DongengRepository({DongengService? service}) : _service = service ?? DongengService();
  final DongengService _service;

  Future<ApiResponse<List<DongengModel>>> getDongeng({String search = ''}) async {
    try { return await _service.getDongeng(search: search); }
    catch (e) { return ApiResponse(success: false, message: 'Error jaringan: $e'); }
  }

  Future<ApiResponse<DongengModel>> getDongengById(String id) async {
    try { return await _service.getDongengById(id); }
    catch (e) { return ApiResponse(success: false, message: 'Error jaringan: $e'); }
  }

  Future<ApiResponse<String>> createDongeng({
    required String judul, required String asal, required String sinopsis,
    required String pesan, required String tokoh,
    File? imageFile, Uint8List? imageBytes, String imageFilename = 'image.jpg',
  }) async {
    try {
      return await _service.createDongeng(
        judul: judul, asal: asal, sinopsis: sinopsis,
        pesan: pesan, tokoh: tokoh,
        imageFile: imageFile, imageBytes: imageBytes, imageFilename: imageFilename,
      );
    } catch (e) { return ApiResponse(success: false, message: 'Error jaringan: $e'); }
  }

  Future<ApiResponse<void>> updateDongeng({
    required String id, required String judul, required String asal,
    required String sinopsis, required String pesan, required String tokoh,
    File? imageFile, Uint8List? imageBytes, String imageFilename = 'image.jpg',
  }) async {
    try {
      return await _service.updateDongeng(
        id: id, judul: judul, asal: asal, sinopsis: sinopsis,
        pesan: pesan, tokoh: tokoh,
        imageFile: imageFile, imageBytes: imageBytes, imageFilename: imageFilename,
      );
    } catch (e) { return ApiResponse(success: false, message: 'Error jaringan: $e'); }
  }

  Future<ApiResponse<void>> deleteDongeng(String id) async {
    try { return await _service.deleteDongeng(id); }
    catch (e) { return ApiResponse(success: false, message: 'Error jaringan: $e'); }
  }
}