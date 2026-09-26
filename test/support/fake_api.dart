import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Answers every request with the API's envelope around what [answer] returns.
class FakeApi implements HttpClientAdapter {
  FakeApi(this.answer);

  final Object? Function(RequestOptions request) answer;
  final requests = <RequestOptions>[];

  Dio get dio =>
      Dio(BaseOptions(baseUrl: 'https://api.test'))..httpClientAdapter = this;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({'status_code': 200, 'data': answer(options), 'detail': 'ok'}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
