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
      return '权限不足，无法访问该资源';
    }

    if (errorStr.contains('404') || errorStr.contains('Not Found')) {
      return '请求的资源不存在';
    }

    if (errorStr.contains('409') || errorStr.contains('Conflict')) {
      return '资源冲突，请检查数据';
    }

    if (errorStr.contains('500') || errorStr.contains('Internal Server Error')) {
      return '服务器错误，请稍后重试';
    }

    if (errorStr.contains('Exception')) {
      final message = errorStr.replaceFirst('Exception: ', '');
      if (message.isNotEmpty && !message.contains('操作失败') && 
          !message.contains('网络') && 
          !message.contains('超时') && 
          !message.contains('登录') && 
          !message.contains('权限') && 
          !message.contains('资源') && 
          !message.contains('服务器')) {
        return message;
      }
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
