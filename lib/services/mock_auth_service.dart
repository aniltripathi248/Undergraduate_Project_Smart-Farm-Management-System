import 'dart:async';
import '../models/user_model.dart';

class MockAuthService {
  MockAuthService._internal();
  static final MockAuthService instance = MockAuthService._internal();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // In-memory mock database of registered users
  final Map<String, _MockUserCredentials> _users = {
    'farmer@sfms.com': _MockUserCredentials(
      user: const UserModel(
        id: 'usr_001',
        name: 'Ram Bahadur Farmer',
        email: 'farmer@sfms.com',
        phone: '9841234567',
      ),
      password: 'password123',
    ),
  };

  /// Simulated login with delay
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final normalizedEmail = email.trim().toLowerCase();
    final userEntry = _users[normalizedEmail];

    if (userEntry == null) {
      throw Exception('No account found with this email. Please register.');
    }

    if (userEntry.password != password) {
      throw Exception('Incorrect password. Please try again.');
    }

    _currentUser = userEntry.user;
    return _currentUser!;
  }

  /// Simulated registration with delay
  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final normalizedEmail = email.trim().toLowerCase();

    if (_users.containsKey(normalizedEmail)) {
      throw Exception('An account with this email already exists.');
    }

    final newUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: normalizedEmail,
      phone: phone.trim(),
    );

    _users[normalizedEmail] = _MockUserCredentials(
      user: newUser,
      password: password,
    );

    _currentUser = newUser;
    return newUser;
  }

  void logout() {
    _currentUser = null;
  }
}

class _MockUserCredentials {
  final UserModel user;
  final String password;

  const _MockUserCredentials({
    required this.user,
    required this.password,
  });
}
