/// Wrapper sederhana pengganti Either<Failure, Success> dari package dartz.
/// Dipakai di semua repository supaya Bloc tidak perlu try-catch Dio langsung.
///
/// Contoh pemakaian di repository:
/// ```dart
/// Future<Result<UserModel>> login(String email, String password) async {
///   try {
///     final res = await _dio.post(ApiEndpoints.login, data: {...});
///     return Result.success(UserModel.fromJson(res.data['data']));
///   } on DioException catch (e) {
///     return Result.failure(e.response?.data['message'] ?? 'Terjadi kesalahan');
///   }
/// }
/// ```
class Result<T> {
  final T? data;
  final String? errorMessage;
  final bool isSuccess;

  Result.success(this.data)
      : errorMessage = null,
        isSuccess = true;

  Result.failure(this.errorMessage)
      : data = null,
        isSuccess = false;
}
