import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized access to the API base URL from the .env file.
/// Provides a fallback to localhost for safety.
final String apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';