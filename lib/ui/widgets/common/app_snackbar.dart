import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../src/core/utils/failure.dart';

SnackBar buildAppSnackBar(String message) {
  return SnackBar(
    content: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF002331),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_rounded,
            color: Color(0xFF2EA9DE),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    ),
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    backgroundColor: Colors.transparent,
    elevation: 0,
    duration: const Duration(seconds: 3),
  );
}

void showAppSnackBar(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(buildAppSnackBar(message));
}

String formatSnackBarError(Object? error) {
  if (error == null) {
    return 'Something went wrong. Please try again.';
  }

  if (error is Failure) {
    if (error is ServerFailure && error.statusCode == 401) {
      return _detailOrMessage(error.message);
    }
    return error.message;
  }

  if (error is DioException) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return _detailOrMessage(_extractDetail(error.response?.data));
    }
    if (error.message != null && error.message!.isNotEmpty) {
      return error.message!;
    }
  }

  return error.toString();
}

String _detailOrMessage(String? message) {
  if (message == null || message.trim().isEmpty) {
    return 'Unauthorized. Please sign in again.';
  }
  return message;
}

String _extractDetail(Object? data) {
  if (data is Map) {
    final detail = data['detail'] ?? data['message'] ?? data['error'];
    if (detail != null) {
      return detail.toString();
    }
  }
  return '';
}
