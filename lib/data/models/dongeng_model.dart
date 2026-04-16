// lib/data/models/dongeng_model.dart
// PERBAIKAN: konstruksi URL gambar lengkap dari pathGambar (sama seperti PlantModel)

import '../../core/constants/api_constants.dart';

class DongengModel {
  const DongengModel({
    this.id,
    required this.judul,
    this.gambar = '',
    this.pathGambar = '',
    required this.asal,
    required this.sinopsis,
    required this.pesan,
    required this.tokoh,
  });

  final String? id;
  final String judul;

  /// URL publik gambar — bisa langsung dipakai Image.network()
  final String gambar;

  /// Path relatif di server, contoh: "uploads/dongeng/uuid.png"
  final String pathGambar;

  final String asal;
  final String sinopsis;
  final String pesan;
  final String tokoh;

  factory DongengModel.fromJson(Map<String, dynamic> json) {
    // Ambil gambar — backend mungkin mengirim URL lengkap atau hanya path
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

    return DongengModel(
      id: json['id'] as String?,
      judul: json['judul'] as String? ?? '',
      gambar: gambar,
      pathGambar: pathGambar,
      asal: json['asal'] as String? ?? '',
      sinopsis: json['sinopsis'] as String? ?? '',
      pesan: json['pesan'] as String? ?? '',
      tokoh: json['tokoh'] as String? ?? '',
    );
  }

  DongengModel copyWith({
    String? id, String? judul, String? gambar,
    String? pathGambar, String? asal, String? sinopsis,
    String? pesan, String? tokoh,
  }) {
    return DongengModel(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      gambar: gambar ?? this.gambar,
      pathGambar: pathGambar ?? this.pathGambar,
      asal: asal ?? this.asal,
      sinopsis: sinopsis ?? this.sinopsis,
      pesan: pesan ?? this.pesan,
      tokoh: tokoh ?? this.tokoh,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DongengModel && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'DongengModel(id: $id, judul: $judul)';
}