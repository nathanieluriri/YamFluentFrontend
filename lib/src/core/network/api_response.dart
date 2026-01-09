class APIResponse<T> {
  final int? statusCode;
  final T? data;
  final String? detail;

  const APIResponse({
    this.statusCode,
    this.data,
    this.detail,
  });

  factory APIResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final statusRaw = json['status_code'];
    final statusCode = statusRaw is int
        ? statusRaw
        : statusRaw is String
            ? int.tryParse(statusRaw)
            : null;
    final dataJson = json['data'];
    final data = dataJson == null ? null : fromJsonT(dataJson);
    final detail = json['detail']?.toString();
    return APIResponse(
      statusCode: statusCode,
      data: data,
      detail: detail,
    );
  }
}

class ApiResponseException implements Exception {
  final String message;
  final int? statusCode;

  const ApiResponseException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
