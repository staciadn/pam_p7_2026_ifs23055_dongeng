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
  final String gambar;
  final String pathGambar;
  final String deskripsi;
  final String manfaat;
  final String efekSamping;

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      id: json['id'] as String?,
      nama: json['nama'] as String? ?? '',
      gambar: json['gambar'] as String? ?? '',
      pathGambar: json['pathGambar'] as String? ?? '',
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
      id: id ?? this.id, nama: nama ?? this.nama,
      gambar: gambar ?? this.gambar, pathGambar: pathGambar ?? this.pathGambar,
      deskripsi: deskripsi ?? this.deskripsi, manfaat: manfaat ?? this.manfaat,
      efekSamping: efekSamping ?? this.efekSamping,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PlantModel && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PlantModel(id: $id, nama: $nama)';
}