import 'package:get_storage/get_storage.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final GetStorage _storage = GetStorage();

  // Storage keys
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _usersKey = 'registered_users';

  // Initialize storage
  Future<void> init() async {
    await GetStorage.init();
  }

  // Check if user is logged in
  bool get isLoggedIn => _storage.read(_isLoggedInKey) ?? false;

  // Get current user email
  String? get currentUserEmail => _storage.read(_userEmailKey);

  // Get current user name
  String? get currentUserName => _storage.read(_userNameKey);

  // Get all registered users
  List<Map<String, dynamic>> get registeredUsers {
    final users = _storage.read(_usersKey);
    if (users == null) return [];
    return List<Map<String, dynamic>>.from(users);
  }

  // Register a new user
  Future<AuthResult> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Check if user already exists
      final existingUsers = registeredUsers;
      final userExists = existingUsers.any((user) => user['email'] == email);

      if (userExists) {
        return AuthResult(
          success: false,
          message: 'User with this email already exists',
        );
      }

      // Validate inputs
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        return AuthResult(
          success: false,
          message: 'All fields are required',
        );
      }

      if (!_isValidEmail(email)) {
        return AuthResult(
          success: false,
          message: 'Please enter a valid email address',
        );
      }

      if (password.length < 6) {
        return AuthResult(
          success: false,
          message: 'Password must be at least 6 characters long',
        );
      }

      // Add new user to registered users list
      final newUser = {
        'name': name,
        'email': email,
        'password': password, // In a real app, this should be hashed
        'createdAt': DateTime.now().toIso8601String(),
      };

      existingUsers.add(newUser);
      await _storage.write(_usersKey, existingUsers);

      return AuthResult(
        success: true,
        message: 'Account created successfully',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Failed to create account: ${e.toString()}',
      );
    }
  }

  // Login user
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        return AuthResult(
          success: false,
          message: 'Email and password are required',
        );
      }

      // Find user in registered users
      final users = registeredUsers;
      final user = users.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
        orElse: () => {},
      );

      if (user.isEmpty) {
        return AuthResult(
          success: false,
          message: 'Invalid email or password',
        );
      }

      // Save login state
      await _storage.write(_isLoggedInKey, true);
      await _storage.write(_userEmailKey, email);
      await _storage.write(_userNameKey, user['name']);

      return AuthResult(
        success: true,
        message: 'Login successful',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Login failed: ${e.toString()}',
      );
    }
  }

  // Logout user
  Future<void> logout() async {
    await _storage.write(_isLoggedInKey, false);
    await _storage.remove(_userEmailKey);
    await _storage.remove(_userNameKey);
  }

  // Clear all data (for testing purposes)
  Future<void> clearAllData() async {
    await _storage.erase();
  }

  // Email validation helper
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

// Result class for authentication operations
class AuthResult {
  final bool success;
  final String message;

  AuthResult({
    required this.success,
    required this.message,
  });
}
