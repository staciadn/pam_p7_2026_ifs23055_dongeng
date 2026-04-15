import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/dongeng_model.dart';
import '../models/api_response_model.dart';
import '../../core/constants/api_constants.dart';

class DongengService {
  DongengService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<ApiResponse<List<DongengModel>>> getDongeng({String search = ''}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.dongeng}')
        .replace(queryParameters: search.isNotEmpty ? {'search': search} : null);

    final response = await _client.get(uri);

    // ✅ DEBUG (WAJIB, biar tau error backend)
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);

        // ✅ pastikan response Map
        if (decoded is! Map<String, dynamic>) {
          return ApiResponse(
            success: false,
            message: "Format response bukan Map",
            data: [],
          );
        }

        final body = decoded;

        // ✅ amanin data
        final dataMap = body['data'];
        if (dataMap == null || dataMap is! Map<String, dynamic>) {
          return ApiResponse(
            success: false,
            message: "Field 'data' null / salah format",
            data: [],
          );
        }

        // ✅ amanin dongeng list
        final jsonList = dataMap['dongeng'];
        if (jsonList == null || jsonList is! List) {
          return ApiResponse(
            success: false,
            message: "Field 'dongeng' bukan List / kosong",
            data: [],
          );
        }

        final list = jsonList
            .map((e) => DongengModel.fromJson(e as Map<String, dynamic>))
            .toList();

        return ApiResponse(
          success: true,
          message: body['message'] as String? ?? 'OK',
          data: list,
        );
      } catch (e) {
        return ApiResponse(
          success: false,
          message: "Parsing error: $e",
          data: [],
        );
      }
    }

    return ApiResponse(success: false, message: _parseError(response));
  }

  Future<ApiResponse<DongengModel>> getDongengById(String id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.dongengById(id)}');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);

        if (decoded is! Map<String, dynamic>) {
          return ApiResponse(success: false, message: "Format response salah");
        }

        final body = decoded;
        final dataMap = body['data'];

        if (dataMap == null || dataMap is! Map<String, dynamic>) {
          return ApiResponse(success: false, message: "Data null");
        }

        final itemJson = dataMap['dongeng'];
        if (itemJson == null || itemJson is! Map<String, dynamic>) {
          return ApiResponse(success: false, message: "Dongeng tidak valid");
        }

        final item = DongengModel.fromJson(itemJson);

        return ApiResponse(
          success: true,
          message: body['message'] as String? ?? 'OK',
          data: item,
        );
      } catch (e) {
        return ApiResponse(success: false, message: "Parsing error: $e");
      }
    }

    return ApiResponse(success: false, message: _parseError(response));
  }

  Future<ApiResponse<String>> createDongeng({
    required String judul,
    required String asal,
    required String sinopsis,
    required String pesan,
    required String tokoh,
    File? imageFile,
    Uint8List? imageBytes,
    String imageFilename = 'image.jpg',
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.dongeng}');
    final request = http.MultipartRequest('POST', uri)
      ..fields['judul'] = judul
      ..fields['asal'] = asal
      ..fields['sinopsis'] = sinopsis
      ..fields['pesan'] = pesan
      ..fields['tokoh'] = tokoh;

    if (kIsWeb && imageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: imageFilename));
    } else if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 201 || response.statusCode == 200) {
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final dataMap = body['data'] as Map<String, dynamic>?;

        return ApiResponse(
          success: true,
          message: body['message'] as String? ?? 'OK',
          data: dataMap?['dongengId'] as String?,
        );
      } catch (e) {
        return ApiResponse(success: false, message: "Parsing error: $e");
      }
    }

    return ApiResponse(success: false, message: _parseError(response));
  }

  Future<ApiResponse<void>> updateDongeng({
    required String id,
    required String judul,
    required String asal,
    required String sinopsis,
    required String pesan,
    required String tokoh,
    File? imageFile,
    Uint8List? imageBytes,
    String imageFilename = 'image.jpg',
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.dongengById(id)}');
    final request = http.MultipartRequest('PUT', uri)
      ..fields['judul'] = judul
      ..fields['asal'] = asal
      ..fields['sinopsis'] = sinopsis
      ..fields['pesan'] = pesan
      ..fields['tokoh'] = tokoh;

    if (kIsWeb && imageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes('file', imageBytes, filename: imageFilename));
    } else if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse(success: true, message: body['message'] as String? ?? 'OK');
      } catch (e) {
        return ApiResponse(success: false, message: "Parsing error: $e");
      }
    }

    return ApiResponse(success: false, message: _parseError(response));
  }

  Future<ApiResponse<void>> deleteDongeng(String id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.dongengById(id)}');
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