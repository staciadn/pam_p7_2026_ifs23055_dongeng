// lib/data/services/dongeng_service.dart
// PERBAIKAN: parsing response lebih robust + debug log

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
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.dongeng}')
          .replace(queryParameters: search.isNotEmpty ? {'search': search} : null);

      final response = await _client.get(uri);

      if (kIsWeb || true) {
        // ignore: avoid_print
        print('[DongengService] GET ${uri} → ${response.statusCode}');
        // ignore: avoid_print
        print('[DongengService] BODY: ${response.body}');
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // Pastikan decoded adalah Map
        if (decoded is! Map<String, dynamic>) {
          return ApiResponse(success: false, message: 'Format response tidak valid', data: []);
        }

        final body = decoded as Map<String, dynamic>;
        final dynamic rawData = body['data'];

        List<dynamic> jsonList = [];

        if (rawData == null) {
          // data null → kembalikan list kosong tapi success
          return ApiResponse(
            success: true,
            message: body['message'] as String? ?? 'OK',
            data: [],
          );
        }

        // CASE 1: data adalah List langsung → [{"id":...}, ...]
        if (rawData is List) {
          jsonList = rawData;
        }
        // CASE 2: data adalah Map dengan key 'dongeng' berisi List → {"dongeng": [...]}
        else if (rawData is Map<String, dynamic>) {
          final dynamic dongengField = rawData['dongengs'];
          if (dongengField is List) {
            jsonList = dongengField;
          }
          // CASE 3: data.dongeng adalah single object → {"dongeng": {...}}
          else if (dongengField is Map<String, dynamic>) {
            jsonList = [dongengField];
          }
          // CASE 4: data sendiri adalah single dongeng object (ada field 'id')
          else if (rawData.containsKey('id')) {
            jsonList = [rawData];
          }
        }

        final list = jsonList
            .whereType<Map<String, dynamic>>()
            .map((e) => DongengModel.fromJson(e))
            .toList();

        return ApiResponse(
          success: true,
          message: body['message'] as String? ?? 'OK',
          data: list,
        );
      }

      return ApiResponse(
        success: false,
        message: _parseError(response),
        data: [],
      );
    } catch (e, stack) {
      // ignore: avoid_print
      print('[DongengService] ERROR getDongeng: $e\n$stack');
      return ApiResponse(success: false, message: 'Error jaringan: $e', data: []);
    }
  }

  Future<ApiResponse<DongengModel>> getDongengById(String id) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.dongengById(id)}');
      final response = await _client.get(uri);

      // ignore: avoid_print
      print('[DongengService] GET by id → ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final dynamic rawData = body['data'];

        Map<String, dynamic>? itemJson;

        if (rawData is Map<String, dynamic>) {
          // Coba ambil dari data.dongeng dulu
          if (rawData['dongeng'] is Map<String, dynamic>) {
            itemJson = rawData['dongeng'] as Map<String, dynamic>;
          }
          // Atau data langsung adalah object dongeng
          else if (rawData.containsKey('id')) {
            itemJson = rawData;
          }
        }

        if (itemJson == null) {
          return ApiResponse(success: false, message: 'Data dongeng tidak ditemukan');
        }

        return ApiResponse(
          success: true,
          message: body['message'] as String? ?? 'OK',
          data: DongengModel.fromJson(itemJson),
        );
      }

      return ApiResponse(success: false, message: _parseError(response));
    } catch (e) {
      return ApiResponse(success: false, message: 'Error jaringan: $e');
    }
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
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.dongeng}');
      final request = http.MultipartRequest('POST', uri)
        ..fields['judul'] = judul
        ..fields['asal'] = asal
        ..fields['sinopsis'] = sinopsis
        ..fields['pesan'] = pesan
        ..fields['tokoh'] = tokoh;

      if (kIsWeb && imageBytes != null) {
        request.files.add(
            http.MultipartFile.fromBytes('file', imageBytes, filename: imageFilename));
      } else if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      // ignore: avoid_print
      print('[DongengService] POST → ${response.statusCode}: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final dynamic dataMap = body['data'];
        String? dongengId;

        if (dataMap is Map<String, dynamic>) {
          dongengId = dataMap['dongengId'] as String? ??
              dataMap['id'] as String?;
        }

        return ApiResponse(
          success: true,
          message: body['message'] as String? ?? 'Berhasil ditambahkan',
          data: dongengId,
        );
      }

      return ApiResponse(success: false, message: _parseError(response));
    } catch (e) {
      return ApiResponse(success: false, message: 'Error jaringan: $e');
    }
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
    try {
      final uri = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.dongengById(id)}');
      final request = http.MultipartRequest('PUT', uri)
        ..fields['judul'] = judul
        ..fields['asal'] = asal
        ..fields['sinopsis'] = sinopsis
        ..fields['pesan'] = pesan
        ..fields['tokoh'] = tokoh;

      if (kIsWeb && imageBytes != null) {
        request.files.add(
            http.MultipartFile.fromBytes('file', imageBytes, filename: imageFilename));
      } else if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse(
            success: true, message: body['message'] as String? ?? 'OK');
      }

      return ApiResponse(success: false, message: _parseError(response));
    } catch (e) {
      return ApiResponse(success: false, message: 'Error jaringan: $e');
    }
  }

  Future<ApiResponse<void>> deleteDongeng(String id) async {
    try {
      final uri = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.dongengById(id)}');
      final response = await _client.delete(uri);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const ApiResponse(success: true, message: 'Berhasil dihapus.');
      }

      return ApiResponse(success: false, message: _parseError(response));
    } catch (e) {
      return ApiResponse(success: false, message: 'Error jaringan: $e');
    }
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