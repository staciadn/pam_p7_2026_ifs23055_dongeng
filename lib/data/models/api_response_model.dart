class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final T? data;

  @override
  String toString() =>
      'ApiResponse(success: $success, message: $message, data: $data)';
}