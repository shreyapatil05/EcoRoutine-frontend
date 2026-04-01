class ApiConstants {
  // Set this to true when testing locally
  static const bool useLocalhost = false;

  static String get baseUrl {
    if (useLocalhost) {
      return 'http://10.0.2.2:5000/api'; // Android emulator localhost
    } else {
      return 'https://ecoroutine-backend.onrender.com'; // Render backend
    }
  }
}