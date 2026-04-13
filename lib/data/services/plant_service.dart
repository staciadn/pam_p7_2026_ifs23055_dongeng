import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/plant_model.dart';
import '../models/api_response_model.dart';
import '../../core/constants/api_constants.dart';

class PlantService {
  PlantService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<ApiResponse<List<PlantModel>>> getPlants({String search = ''}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.plants}')
        .replace(queryParameters: search.isNotEmpty ? {'search': search} : null);
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final dataMap = body['data'] as Map<String, dynamic>;
      final List<dynamic> jsonList = dataMap['plants'] as List<dynamic>;
      final plants = jsonList
          .map((e) => PlantModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse(success: true, message: body['message'] as String? ?? 'OK', data: plants);
    }
    return ApiResponse(success: false, message: _parseError(response));
  }

  Future<ApiResponse<PlantModel>> getPlantById(String id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.plantById(id)}');
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final dataMap = body['data'] as Map<String, dynamic>;
      final plant = PlantModel.fromJson(dataMap['plant'] as Map<String, dynamic>);
      return ApiResponse(success: true, message: body['message'] as String? ?? 'OK', data: plant);
    }
    return ApiResponse(success: false, message: _parseError(response));
  }

  Future<ApiResponse<String>> createPlant({
    required String nama, required String deskripsi,
    required String manfaat, required String efekSamping,
    File? imageFile, Uint8List? imageBytes, String imageFilename = 'image.jpg',
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.plants}');
    final request = http.MultipartRequest('POST', uri)
      ..fields['nama'] = nama ..fields['deskripsi'] = deskripsi
      ..fields['manfaat'] = manfaat ..fields['efekSamping'] = efekSamping;
    if (kIsWeb && imageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: imageFilename));
    } else if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    }
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 201 || response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final dataMap = body['data'] as Map<String, dynamic>;
      return ApiResponse(success: true, message: body['message'] as String? ?? 'OK', data: dataMap['plantId'] as String);
    }
    return ApiResponse(success: false, message: _parseError(response));
  }

  Future<ApiResponse<void>> updatePlant({
    required String id, required String nama, required String deskripsi,
    required String manfaat, required String efekSamping,
    File? imageFile, Uint8List? imageBytes, String imageFilename = 'image.jpg',
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.plantById(id)}');
    final request = http.MultipartRequest('PUT', uri)
      ..fields['nama'] = nama ..fields['deskripsi'] = deskripsi
      ..fields['manfaat'] = manfaat ..fields['efekSamping'] = efekSamping;
    if (kIsWeb && imageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: imageFilename));
    } else if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    }
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiResponse(success: true, message: body['message'] as String? ?? 'OK');
    }
    return ApiResponse(success: false, message: _parseError(response));
  }

  Future<ApiResponse<void>> deletePlant(String id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.plantById(id)}');
    final response = await _client.delete(uri);
    if (response.statusCode == 200 || response.statusCode == 204) {
      return const ApiResponse(success: true, message: 'Berhasil dihapus.');
    }
    return ApiResponse(success: false, message: _parseError(response));
  }

  String _parseError(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['message'] as String? ?? 'Error ${response.statusCode}';
    } catch (_) {
      return 'Error ${response.statusCode}';
    }
  }

  void dispose() => _client.close();
}