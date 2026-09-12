class ApiConfig {
  ApiConfig._();

  /// Configurable REST API Base URL.
  /// Change this constant to point to a different environment.
  static const String baseUrl =
      'https://studentshonoringsystem-o46s.onrender.com/api/';

  /// Network timeouts.
  /// 30 s connect / 30 s receive to accommodate Render free-tier cold starts.
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Endpoint paths (relative to [baseUrl])
  static const String adminLogin = 'admin/login';
  static const String publicStudents = 'students';
  static const String adminStudents = 'admin/students';
  static const String adminExportCsv = 'admin/students/export/csv';
  static const String logout = 'logout';

  /// Helper for per-student detail / update / delete endpoint
  static String adminStudentById(int id) => 'admin/students/$id';
}
