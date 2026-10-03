import 'package:dio/dio.dart';

/// Pemetaan exception -> pesan ramah (refactoring). UI hanya menerima pesan.
String friendlyApiError(Object error) {
  if (error is DioException) {
    final code = error.response?.statusCode;
    if (code == 401) return 'Sesi berakhir. Silakan login kembali.';
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi lambat atau timeout. Coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
      case DioExceptionType.badResponse:
        return 'Server bermasalah (${code ?? '-'}). Coba lagi nanti.';
      default:
        return 'Terjadi kesalahan jaringan. Coba lagi.';
    }
  }
  final message = error.toString();
  return message.startsWith('Exception: ') ? message.substring(11) : message;
}
