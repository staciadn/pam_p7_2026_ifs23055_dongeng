class RouteConstants {
  RouteConstants._();

  static const String home = '/';
  static const String plants = '/plants';
  static const String plantsAdd = '/plants/add';
  static String plantsDetail(String id) => '/plants/$id';
  static String plantsEdit(String id) => '/plants/$id/edit';

  static const String dongeng = '/dongeng';
  static const String dongengAdd = '/dongeng/add';
  static String dongengDetail(String id) => '/dongeng/$id';
  static String dongengEdit(String id) => '/dongeng/$id/edit';

  static const String profile = '/profile';
}