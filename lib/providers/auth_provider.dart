import 'package:flutter/foundation.dart';
import '../models/user_dto.dart';
import '../services/auth_service.dart';
import '../services/token_service.dart';
import '../exceptions/auth_exception.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final TokenService _tokenService = TokenService();
  
  UserDto? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  UserDto? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  /// Initialize auth state on app start
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final isAuth = await _authService.isAuthenticated();
      _isAuthenticated = isAuth;
      
      // For MVP, we don't persist user data
      // User data is only available after login
      _currentUser = null;
      
      _clearError();
    } catch (e) {
      _setError('Failed to initialize auth: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Login user
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    print('DEBUG AuthProvider: Received email: "$email"');
    print('DEBUG AuthProvider: Email is null: ${email == null}');
    print('DEBUG AuthProvider: Email length: ${email.length}');
    print('DEBUG AuthProvider: Password length: ${password.length}');
    
    try {
      _currentUser = await _authService.login(email, password);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Logout user
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _currentUser = null;
      _isAuthenticated = false;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Logout from all devices
  Future<void> logoutAll() async {
    _setLoading(true);
    try {
      await _authService.logoutAll();
      _currentUser = null;
      _isAuthenticated = false;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Logout all failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.changePassword(currentPassword, newPassword);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Password change failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Check if user can access mobile app
  bool get canAccessMobile {
    return _currentUser?.canAccessMobile ?? false;
  }
  
  /// Check if user can access dashboard
  bool get canAccessDashboard {
    return _currentUser?.canAccessDashboard ?? false;
  }
  
  /// Get user role name
  String get userRole {
    return _currentUser?.role.name ?? '';
  }
  
  /// Get user full name
  String get userName {
    return _currentUser?.fullName ?? '';
  }
  
  /// Get available warehouses
  List<String> get availableWarehouses {
    return _currentUser?.entrepotCodes ?? [];
  }
  
  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
