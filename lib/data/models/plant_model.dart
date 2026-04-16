// lib/data/models/plant_model.dart
// PERBAIKAN: konstruksi URL gambar lengkap jika backend hanya kirim pathGambar

import '../../core/constants/api_constants.dart';

class PlantModel {
  const PlantModel({
    this.id,
    required this.nama,
    this.gambar = '',
    this.pathGambar = '',
    required this.deskripsi,
    required this.manfaat,
    required this.efekSamping,
  });

  final String? id;
  final String nama;

  /// URL publik gambar — bisa langsung dipakai Image.network()
  final String gambar;

  /// Path relatif file di server, contoh: "uploads/plants/uuid.png"
  final String pathGambar;

  final String deskripsi;
  final String manfaat;
  final String efekSamping;

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    String gambar = json['gambar'] as String? ?? '';
    final String pathGambar = json['pathGambar'] as String? ?? '';

    // Jika gambar kosong tapi pathGambar ada → konstruksi URL lengkap
    if (gambar.isEmpty && pathGambar.isNotEmpty) {
      gambar = '${ApiConstants.baseUrl}/static/$pathGambar';
    }

    // Jika gambar ada tapi tidak dimulai dengan http → tambahkan base URL
    if (gambar.isNotEmpty && !gambar.startsWith('http')) {
      gambar = '${ApiConstants.baseUrl}/$gambar';
    }

    return PlantModel(
      id: json['id'] as String?,
      nama: json['nama'] as String? ?? '',
      gambar: gambar,
      pathGambar: pathGambar,
      deskripsi: json['deskripsi'] as String? ?? '',
      manfaat: json['manfaat'] as String? ?? '',
      efekSamping: json['efekSamping'] as String? ?? '',
    );
  }

  PlantModel copyWith({
    String? id, String? nama, String? gambar,
    String? pathGambar, String? deskripsi,
    String? manfaat, String? efekSamping,
  }) {
    return PlantModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      gambar: gambar ?? this.gambar,
      pathGambar: pathGambar ?? this.pathGambar,
      deskripsi: deskripsi ?? this.deskripsi,
      manfaat: manfaat ?? this.manfaat,
      efekSamping: efekSamping ?? this.efekSamping,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PlantModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PlantModel(id: $id, nama: $nama)';
}