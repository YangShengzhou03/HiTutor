import 'package:flutter/material.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error == null) {
      return '操作失败，请稍后重试';
    }

    final errorStr = error.toString();

    if (errorStr.contains('SocketException') || errorStr.contains('Connection refused')) {
      return '网络连接失败，请检查网络设置';
    }

    if (errorStr.contains('TimeoutException')) {
      return '请求超时，请稍后重试';
    }

    if (errorStr.contains('401') || errorStr.contains('Unauthorized')) {
      return '登录已过期，请重新登录';
    }

    if (errorStr.contains('403') || errorStr.contains('Forbidden')) {
      return '没有权限执行此操作';
    }

    if (errorStr.contains('404') || errorStr.contains('Not Found')) {
      return '请求的资源不存在';
    }

    if (errorStr.contains('500') || errorStr.contains('Internal Server Error')) {
      return '服务器错误，请稍后重试';
    }

    if (errorStr.contains('Exception')) {
      return errorStr.replaceFirst('Exception: ', '');
    }

    return errorStr;
  }

  static void showErrorSnackBar(BuildContext context, dynamic error) {
    final message = getErrorMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
