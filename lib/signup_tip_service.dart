import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

// Same interface for the course endpoint and the offline mock.
abstract class SignupTipService {
  bool get isMock;

  Future<String> fetchTip();
}

// No endpoint was supplied, so this mock is used by default.
class MockSignupTipService implements SignupTipService {
  const MockSignupTipService();

  @override
  bool get isMock => true;

  @override
  Future<String> fetchTip() async {
    // A short delay lets the loading state show up on screen.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return 'Use a unique passphrase with at least four unrelated words. '
        'It is easier to remember than a short password and harder to guess.';
  }
}

class HttpSignupTipService implements SignupTipService {
  const HttpSignupTipService({required this.endpoint});

  final Uri endpoint;

  @override
  bool get isMock => false;

  @override
  Future<String> fetchTip() async {
    if (endpoint.scheme != 'https') {
      throw const SignupTipException();
    }

    try {
      final response = await http
          .post(
            endpoint,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(const {
              'task': 'signup_tip',
              'topic': 'password_help',
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw const SignupTipException();
      }

      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        throw const SignupTipException();
      }

      final tip = data['tip'];
      if (tip is! String || tip.trim().isEmpty) {
        throw const SignupTipException();
      }

      return shortenTip(tip);
    } on SignupTipException {
      rethrow;
    } catch (_) {
      // Timeouts, bad JSON, and network errors all use the same friendly state.
      throw const SignupTipException();
    }
  }
}

class SignupTipException implements Exception {
  const SignupTipException();
}

// Only keep the first 240 characters of plain text.
String shortenTip(String tip) {
  final clean = tip.trim();
  if (clean.length <= 240) {
    return clean;
  }
  return clean.substring(0, 240);
}

SignupTipService createSignupTipService() {
  // The instructor URL is passed at build time, never stored in the app.
  const String endpoint = String.fromEnvironment('SIGNUP_TIP_ENDPOINT');

  if (endpoint.isEmpty) {
    return const MockSignupTipService();
  }

  return HttpSignupTipService(endpoint: Uri.parse(endpoint));
}
