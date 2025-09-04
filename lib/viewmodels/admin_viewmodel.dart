import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/mock_api_service.dart';

class AdminViewModel extends ChangeNotifier {
  final MockApiService _apiService = MockApiService();
  
  // Dashboard Stats
  DashboardStats? _dashboardStats;
  bool _isLoadingStats = false;
  
  // Requests
  List<Request> _allRequests = [];
  List<Request> _filteredRequests = [];
  bool _isLoadingRequests = false;
  String _requestSearchQuery = '';
  String? _statusFilter;
  Priority? _priorityFilter;
  
  // Request Types
  List<RequestType> _requestTypes = [];
  bool _isLoadingTypes = false;
  
  // Templates
  List<RequestTemplate> _templates = [];
  bool _isLoadingTemplates = false;
  
  // Users
  List<User> _users = [];
  List<User> _adminUsers = [];
  bool _isLoadingUsers = false;
  
  // Notifications
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoadingNotifications = false;
  
  // Error handling
  String? _errorMessage;

  // Getters
  DashboardStats? get dashboardStats => _dashboardStats;
  bool get isLoadingStats => _isLoadingStats;
  
  List<Request> get allRequests => _allRequests;
  List<Request> get filteredRequests => _filteredRequests;
  bool get isLoadingRequests => _isLoadingRequests;
  
  List<RequestType> get requestTypes => _requestTypes;
  bool get isLoadingTypes => _isLoadingTypes;
  
  List<RequestTemplate> get templates => _templates;
  bool get isLoadingTemplates => _isLoadingTemplates;
  
  List<User> get users => _users;
  List<User> get adminUsers => _adminUsers;
  bool get isLoadingUsers => _isLoadingUsers;
  
  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoadingNotifications => _isLoadingNotifications;
  
  String? get errorMessage => _errorMessage;

  // Dashboard Methods
  Future<void> loadDashboardStats() async {
    _isLoadingStats = true;
    notifyListeners();
    
    try {
      _dashboardStats = await _apiService.getDashboardStats();
      _setError(null);
    } catch (e) {
      _setError('Error loading dashboard stats: ${e.toString()}');
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  // Request Methods
  Future<void> loadAllRequests() async {
    _isLoadingRequests = true;
    notifyListeners();
    
    try {
      _allRequests = await _apiService.getRequests();
      _applyRequestFilters();
      _setError(null);
    } catch (e) {
      _setError('Error loading requests: ${e.toString()}');
    } finally {
      _isLoadingRequests = false;
      notifyListeners();
    }
  }

  void updateRequestFilters({String? searchQuery, String? status, Priority? priority}) {
    if (searchQuery != null) _requestSearchQuery = searchQuery;
    if (status != null) _statusFilter = status;
    if (priority != null) _priorityFilter = priority;
    
    _applyRequestFilters();
  }

  void _applyRequestFilters() {
    _filteredRequests = _allRequests.where((request) {
      // Search filter
      bool matchesSearch = _requestSearchQuery.isEmpty ||
          request.typeName.toLowerCase().contains(_requestSearchQuery.toLowerCase()) ||
          request.fieldValues.values.any((value) => 
            value.toString().toLowerCase().contains(_requestSearchQuery.toLowerCase()));
      
      // Status filter
      bool matchesStatus = _statusFilter == null || 
          _statusFilter!.isEmpty || 
          request.status == _statusFilter;
      
      // Priority filter
      bool matchesPriority = _priorityFilter == null || 
          request.priority == _priorityFilter;
      
      return matchesSearch && matchesStatus && matchesPriority;
    }).toList();
    
    notifyListeners();
  }

  void clearRequestFilters() {
    _requestSearchQuery = '';
    _statusFilter = null;
    _priorityFilter = null;
    _applyRequestFilters();
  }

  Future<void> updateRequestStatus(String requestId, String newStatus, {String? comments}) async {
    try {
      final updatedRequest = await _apiService.updateRequestStatus(
        requestId, 
        newStatus, 
        adminComments: comments,
        adminName: 'Admin'
      );
      
      // Update local list
      final index = _allRequests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _allRequests[index] = updatedRequest;
        _applyRequestFilters();
      }
      
      _setError(null);
    } catch (e) {
      _setError('Error updating request status: ${e.toString()}');
    }
  }

  Future<void> assignRequest(String requestId, String adminId, String adminName) async {
    try {
      final updatedRequest = await _apiService.assignRequest(requestId, adminId, adminName);
      
      // Update local list
      final index = _allRequests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _allRequests[index] = updatedRequest;
        _applyRequestFilters();
      }
      
      _setError(null);
    } catch (e) {
      _setError('Error assigning request: ${e.toString()}');
    }
  }

  Future<void> updateRequestPriority(String requestId, Priority priority) async {
    try {
      final updatedRequest = await _apiService.updateRequestPriority(requestId, priority);
      
      // Update local list
      final index = _allRequests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _allRequests[index] = updatedRequest;
        _applyRequestFilters();
      }
      
      _setError(null);
    } catch (e) {
      _setError('Error updating request priority: ${e.toString()}');
    }
  }

  // Request Type Methods
  Future<void> loadRequestTypes() async {
    _isLoadingTypes = true;
    notifyListeners();
    
    try {
      _requestTypes = await _apiService.getRequestTypes();
      _setError(null);
    } catch (e) {
      _setError('Error loading request types: ${e.toString()}');
    } finally {
      _isLoadingTypes = false;
      notifyListeners();
    }
  }

  Future<void> createRequestType(RequestType requestType) async {
    try {
      final newType = await _apiService.createRequestType(requestType);
      _requestTypes.add(newType);
      notifyListeners();
      _setError(null);
    } catch (e) {
      _setError('Error creating request type: ${e.toString()}');
    }
  }

  // Template Methods
  Future<void> loadTemplates() async {
    _isLoadingTemplates = true;
    notifyListeners();
    
    try {
      _templates = await _apiService.getTemplates();
      _setError(null);
    } catch (e) {
      _setError('Error loading templates: ${e.toString()}');
    } finally {
      _isLoadingTemplates = false;
      notifyListeners();
    }
  }

  Future<void> createTemplate(RequestTemplate template) async {
    try {
      final newTemplate = await _apiService.createTemplate(template);
      _templates.add(newTemplate);
      notifyListeners();
      _setError(null);
    } catch (e) {
      _setError('Error creating template: ${e.toString()}');
    }
  }

  Future<void> deleteTemplate(String templateId) async {
    try {
      await _apiService.deleteTemplate(templateId);
      _templates.removeWhere((t) => t.id == templateId);
      notifyListeners();
      _setError(null);
    } catch (e) {
      _setError('Error deleting template: ${e.toString()}');
    }
  }

  // User Management Methods
  Future<void> loadUsers() async {
    _isLoadingUsers = true;
    notifyListeners();
    
    try {
      _users = await _apiService.getUsers();
      _adminUsers = await _apiService.getAdminUsers();
      _setError(null);
    } catch (e) {
      _setError('Error loading users: ${e.toString()}');
    } finally {
      _isLoadingUsers = false;
      notifyListeners();
    }
  }

  Future<void> createUser(User user) async {
    try {
      final newUser = await _apiService.createUser(user);
      _users.add(newUser);
      if (newUser.role == UserRole.admin) {
        _adminUsers.add(newUser);
      }
      notifyListeners();
      _setError(null);
    } catch (e) {
      _setError('Error creating user: ${e.toString()}');
    }
  }

  Future<void> updateUser(User user) async {
    try {
      final updatedUser = await _apiService.updateUser(user);
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = updatedUser;
      }
      
      final adminIndex = _adminUsers.indexWhere((u) => u.id == user.id);
      if (updatedUser.role == UserRole.admin) {
        if (adminIndex != -1) {
          _adminUsers[adminIndex] = updatedUser;
        } else {
          _adminUsers.add(updatedUser);
        }
      } else if (adminIndex != -1) {
        _adminUsers.removeAt(adminIndex);
      }
      
      notifyListeners();
      _setError(null);
    } catch (e) {
      _setError('Error updating user: ${e.toString()}');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _apiService.deleteUser(userId);
      _users.removeWhere((u) => u.id == userId);
      _adminUsers.removeWhere((u) => u.id == userId);
      notifyListeners();
      _setError(null);
    } catch (e) {
      _setError('Error deleting user: ${e.toString()}');
    }
  }

  // Notification Methods
  Future<void> loadNotifications(String userId) async {
    _isLoadingNotifications = true;
    notifyListeners();
    
    try {
      _notifications = await _apiService.getNotifications(userId);
      _unreadCount = await _apiService.getUnreadNotificationCount(userId);
      _setError(null);
    } catch (e) {
      _setError('Error loading notifications: ${e.toString()}');
    } finally {
      _isLoadingNotifications = false;
      notifyListeners();
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _apiService.markNotificationAsRead(notificationId);
      
      // Update local notification
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = AppNotification(
          id: _notifications[index].id,
          title: _notifications[index].title,
          message: _notifications[index].message,
          type: _notifications[index].type,
          requestId: _notifications[index].requestId,
          targetUserIds: _notifications[index].targetUserIds,
          senderName: _notifications[index].senderName,
          createdAt: _notifications[index].createdAt,
          isRead: true,
        );
      }
      
      // Update unread count
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
      _setError(null);
    } catch (e) {
      _setError('Error marking notification as read: ${e.toString()}');
    }
  }

  // Export Methods
  Future<String?> exportRequestsToExcel() async {
    try {
      final url = await _apiService.exportRequestsToExcel(_allRequests);
      _setError(null);
      return url;
    } catch (e) {
      _setError('Error exporting to Excel: ${e.toString()}');
      return null;
    }
  }

  Future<String?> exportRequestsToPdf() async {
    try {
      final url = await _apiService.exportRequestsToPdf(_allRequests);
      _setError(null);
      return url;
    } catch (e) {
      _setError('Error exporting to PDF: ${e.toString()}');
      return null;
    }
  }

  // Initialize all admin data
  Future<void> initializeAdminData(String userId) async {
    await Future.wait([
      loadDashboardStats(),
      loadAllRequests(),
      loadRequestTypes(),
      loadTemplates(),
      loadUsers(),
      loadNotifications(userId),
    ]);
  }

  // Refresh all data
  Future<void> refreshAllData(String userId) async {
    await initializeAdminData(userId);
  }

  // Private helper methods
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}