class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://pam-2026-p7-ifs23055-be.delcom.org:8080';

  static const String plants = '/plants';
  static String plantById(String id) => '/plants/$id';

  static const String dongeng = '/dongeng';
  static String dongengById(String id) => '/dongeng/$id';
}