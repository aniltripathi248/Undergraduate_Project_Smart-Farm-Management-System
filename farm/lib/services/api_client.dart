import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// ApiClient - Low-level HTTP client for backend communication
/// 
/// This is the foundation layer that handles all HTTP requests to the backend API.
/// It provides methods for GET, POST, and DELETE operations with:
/// - Automatic JSON encoding/decoding
/// - Token injection for authenticated requests
/// - Error handling and user-friendly error messages
/// 
/// Used by: AuthApi, AnimalApi (not directly by screens)
/// 
/// Flow: Screen → Service (AuthApi/AnimalApi) → ApiClient → Backend API
class ApiClient {
  /// Constructor - sets the backend API base URL
  /// Default: 'https://farm-companion-2.onrender.com'
  ApiClient({
    this.baseUrl = 'https://farm-companion-2.onrender.com',
  });

  /// Base URL of the backend API server
  final String baseUrl;

  /// Sends a POST request to the backend API
  /// 
  /// Used for: Creating/updating resources (signup, login, add animal, update animal)
  /// 
  /// Flow:
  /// 1. Receives path (e.g., '/api/auth/signup') and data body
  /// 2. Optionally receives token for authenticated requests
  /// 3. Builds full URL and sets headers
  /// 4. Encodes body to JSON and sends POST request
  /// 5. Handles response and errors
  /// 
  /// Parameters:
  /// - path: API endpoint path (e.g., '/api/auth/signup')
  /// - body: Data to send (will be JSON encoded)
  /// - token: Optional authentication token (adds Authorization header)
  /// 
  /// Returns: Map with response data from backend
  /// Throws: Exception if request fails or server error
  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    // Build full URL by combining base URL with endpoint path
    final uri = Uri.parse('$baseUrl$path');

    // Set headers - always send JSON content type
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    // If token provided, add Authorization header for authenticated requests
    // Format: "Bearer <token>" - standard JWT authentication
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    // Send POST request with JSON-encoded body
    // jsonEncode converts Dart Map to JSON string
    http.Response response;
    try {
      response =
          await http.post(uri, headers: headers, body: jsonEncode(body));
    } on SocketException catch (e) {
      // Network/DNS error - cannot reach server
      throw Exception(
        'Cannot connect to server. Please check your internet connection and try again.\n'
        'Error: ${e.message}'
      );
    } on HttpException catch (e) {
      // HTTP protocol error
      throw Exception(
        'Network error occurred. Please try again.\n'
        'Error: ${e.message}'
      );
    } catch (e) {
      // Other network errors (ClientException, etc.)
      final errorMsg = e.toString();
      if (errorMsg.contains('host lookup') || 
          errorMsg.contains('No address associated with hostname')) {
        throw Exception(
          'Cannot reach the server. The backend service may be down or the URL is incorrect.\n'
          'Please check your internet connection or contact support.'
        );
      }
      throw Exception(
        'Network error: ${e.toString()}'
      );
    }

    // Handle specific HTTP error codes with user-friendly messages
    if (response.statusCode == 503) {
      if (response.body.toLowerCase().contains('service suspended') ||
          response.body.toLowerCase().contains('suspended')) {
        throw Exception(
          'The server is currently unavailable. Please try again later or contact support.'
        );
      }
      throw Exception(
        'Service temporarily unavailable (503). Please try again in a few moments.'
      );
    }

    Map<String, dynamic> data = {};
    
    if (response.body.isNotEmpty) {
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        // If JSON parsing fails, provide a helpful error message
        if (e is FormatException) {
          // Check if it's an HTML response (common for error pages)
          if (response.body.trim().toLowerCase().startsWith('<!doctype html>') ||
              response.body.trim().toLowerCase().startsWith('<html')) {
            if (response.statusCode == 503) {
              throw Exception(
                'The server is currently unavailable. Please try again later.'
              );
            }
            throw Exception(
              'Server returned an error page. Status: ${response.statusCode}. '
              'The backend service may be down or unavailable.'
            );
          }
          final preview = response.body.length > 200 
              ? response.body.substring(0, 200) + "..." 
              : response.body;
          throw Exception(
            'Invalid JSON response from server. Status: ${response.statusCode}. '
            'Response: $preview'
          );
        }
        rethrow;
      }
    }

    // ============================================
    // SUCCESS/ERROR CHECK
    // ============================================
    // Status codes 200-299 = Success
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      // Status codes outside 200-299 = Error
      // Extract error message from response, or use default
      throw Exception(data['error'] ?? data['message'] ?? 'Request failed');
    }
  }

  /// Sends a GET request to the backend API
  /// 
  /// Used for: Fetching data (get animals, get animal by ID, etc.)
  /// 
  /// Flow:
  /// 1. Receives path (e.g., '/api/animals/mine')
  /// 2. Optionally receives token for authenticated requests
  /// 3. Builds full URL and sets headers
  /// 4. Sends GET request
  /// 5. Handles response and errors
  /// 
  /// Parameters:
  /// - path: API endpoint path (e.g., '/api/animals/mine')
  /// - token: Optional authentication token (adds Authorization header)
  /// 
  /// Returns: Map with response data from backend
  /// Throws: Exception if request fails or server error
  Future<Map<String, dynamic>> getJson(
    String path, {
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$path');

    final headers = <String, String>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    http.Response response;
    try {
      response = await http.get(uri, headers: headers);
    } on SocketException catch (e) {
      // Network/DNS error - cannot reach server
      throw Exception(
        'Cannot connect to server. Please check your internet connection and try again.\n'
        'Error: ${e.message}'
      );
    } on HttpException catch (e) {
      // HTTP protocol error
      throw Exception(
        'Network error occurred. Please try again.\n'
        'Error: ${e.message}'
      );
    } catch (e) {
      // Other network errors (ClientException, etc.)
      final errorMsg = e.toString();
      if (errorMsg.contains('host lookup') || 
          errorMsg.contains('No address associated with hostname')) {
        throw Exception(
          'Cannot reach the server. The backend service may be down or the URL is incorrect.\n'
          'Please check your internet connection or contact support.'
        );
      }
      throw Exception(
        'Network error: ${e.toString()}'
      );
    }
    
    // Handle specific HTTP error codes with user-friendly messages
    if (response.statusCode == 503) {
      if (response.body.toLowerCase().contains('service suspended') ||
          response.body.toLowerCase().contains('suspended')) {
        throw Exception(
          'The server is currently unavailable. Please try again later or contact support.'
        );
      }
      throw Exception(
        'Service temporarily unavailable (503). Please try again in a few moments.'
      );
    }
    
    Map<String, dynamic> data = {};
    
    if (response.body.isNotEmpty) {
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        // If JSON parsing fails, provide a helpful error message
        if (e is FormatException) {
          // Check if it's an HTML response (common for error pages)
          if (response.body.trim().toLowerCase().startsWith('<!doctype html>') ||
              response.body.trim().toLowerCase().startsWith('<html')) {
            if (response.statusCode == 503) {
              throw Exception(
                'The server is currently unavailable. Please try again later.'
              );
            }
            throw Exception(
              'Server returned an error page. Status: ${response.statusCode}. '
              'The backend service may be down or unavailable.'
            );
          }
          final preview = response.body.length > 200 
              ? response.body.substring(0, 200) + "..." 
              : response.body;
          throw Exception(
            'Invalid JSON response from server. Status: ${response.statusCode}. '
            'Response: $preview'
          );
        }
        rethrow;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['error'] ?? data['message'] ?? 'Request failed');
    }
  }

  /// Sends a DELETE request to the backend API
  /// 
  /// Used for: Deleting resources (delete animal)
  /// 
  /// Flow:
  /// 1. Receives path (e.g., '/api/animals/:id')
  /// 2. Optionally receives token for authenticated requests
  /// 3. Builds full URL and sets headers
  /// 4. Sends DELETE request
  /// 5. Handles response and errors
  /// 
  /// Parameters:
  /// - path: API endpoint path with ID (e.g., '/api/animals/123')
  /// - token: Optional authentication token (adds Authorization header)
  /// 
  /// Returns: Map with response data from backend
  /// Throws: Exception if request fails or server error
  Future<Map<String, dynamic>> deleteJson(
    String path, {
    String? token,
  }) async {
    // Build full URL by combining base URL with endpoint path
    final uri = Uri.parse('$baseUrl$path');

    // Set headers - DELETE requests don't need Content-Type
    final headers = <String, String>{};
    // If token provided, add Authorization header for authenticated requests
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    // Send DELETE request
    http.Response response;
    try {
      response = await http.delete(uri, headers: headers);
    } on SocketException catch (e) {
      // Network/DNS error - cannot reach server
      throw Exception(
        'Cannot connect to server. Please check your internet connection and try again.\n'
        'Error: ${e.message}'
      );
    } on HttpException catch (e) {
      // HTTP protocol error
      throw Exception(
        'Network error occurred. Please try again.\n'
        'Error: ${e.message}'
      );
    } catch (e) {
      // Other network errors (ClientException, etc.)
      final errorMsg = e.toString();
      if (errorMsg.contains('host lookup') || 
          errorMsg.contains('No address associated with hostname')) {
        throw Exception(
          'Cannot reach the server. The backend service may be down or the URL is incorrect.\n'
          'Please check your internet connection or contact support.'
        );
      }
      throw Exception(
        'Network error: ${e.toString()}'
      );
    }
    
    // Handle specific HTTP error codes with user-friendly messages
    if (response.statusCode == 503) {
      if (response.body.toLowerCase().contains('service suspended') ||
          response.body.toLowerCase().contains('suspended')) {
        throw Exception(
          'The server is currently unavailable. Please try again later or contact support.'
        );
      }
      throw Exception(
        'Service temporarily unavailable (503). Please try again in a few moments.'
      );
    }
    
    Map<String, dynamic> data = {};
    
    if (response.body.isNotEmpty) {
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        // If JSON parsing fails, provide a helpful error message
        if (e is FormatException) {
          // Check if it's an HTML response (common for error pages)
          if (response.body.trim().toLowerCase().startsWith('<!doctype html>') ||
              response.body.trim().toLowerCase().startsWith('<html')) {
            if (response.statusCode == 503) {
              throw Exception(
                'The server is currently unavailable. Please try again later.'
              );
            }
            throw Exception(
              'Server returned an error page. Status: ${response.statusCode}. '
              'The backend service may be down or unavailable.'
            );
          }
          final preview = response.body.length > 200 
              ? response.body.substring(0, 200) + "..." 
              : response.body;
          throw Exception(
            'Invalid JSON response from server. Status: ${response.statusCode}. '
            'Response: $preview'
          );
        }
        rethrow;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['error'] ?? data['message'] ?? 'Request failed');
    }
  }
}
