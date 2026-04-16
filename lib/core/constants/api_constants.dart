class ApiConstants {
  ApiConstants._();

  // Backend Plants
  static const String baseUrl =
      'https://pam-2026-p4-ifs23055-be.stacia.fun:8080';


  static const String plants = '/plants';
  static String plantById(String id) => '/plants/$id';

  static const String dongeng = '/dongeng';
  static String dongengById(String id) => '/dongeng/$id';
}