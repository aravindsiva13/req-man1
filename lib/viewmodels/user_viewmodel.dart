import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/mock_api_service.dart';

class UserViewModel extends ChangeNotifier {
  final MockApiService _apiService = MockApiService();
  
  // User's Requests
  List<Request> _myRequests = [];
  List<Request> _filteredRequests = [];
  bool _isLoadingRequests = false;
  String _searchQuery = '';
  String? _statusFilter;
  Priority? _priorityFilter;
  
  // Request Types
  List<RequestType> _requestTypes = [];
  bool _isLoadingTypes = false;
  
  // Templates
  List<RequestTemplate> _templates = [];
  bool _isLoadingTemplates = false;
  
  // Notifications
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoadingNotifications = false;
  
  // Form Data
  RequestType? _selectedRequestType;
  RequestTemplate? _selectedTemplate;
  Map<String, dynamic> _formData = {};
  List<String> _formTags = [];
  Priority _formPriority = Priority.medium;
  DateTime? _formDueDate;
  
  // Loading states
  bool _isSubmittingRequest = false;
  
  // Error handling
  String? _errorMessage;

  // Getters
  List<Request> get myRequests => _myRequests;
  List<Request> get filteredRequests => _filteredRequests;
  bool get isLoadingRequests => _isLoadingRequests;
  
  List<RequestType> get requestTypes => _requestTypes;
  bool get isLoadingTypes => _isLoadingTypes;
  
  List<RequestTemplate> get templates => _templates;
  List<RequestTemplate> get availableTemplates => _selectedRequestType != null
      ? _templates.where((t) => t.typeId == _selectedRequestType!.id).toList()
      : [];
  bool get isLoadingTemplates => _isLoadingTemplates;
  
  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoadingNotifications => _isLoadingNotifications;
  
  RequestType? get selectedRequestType => _selectedRequestType;
  RequestTemplate? get selectedTemplate => _selectedTemplate;
  Map<String, dynamic> get formData => _formData;
  List<String> get formTags => _formTags;
  Priority get formPriority => _formPriority;
  DateTime? get formDueDate => _formDueDate;
  
  bool get isSubmittingRequest => _isSubmittingRequest;
  String? get errorMessage => _errorMessage;

  // Request Methods
  Future<void> loadMyRequests(String userId) async {
    _isLoadingRequests = true;
    notifyListeners();
    
    try {
      _myRequests = await _apiService.getRequests(userId: userId);
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
    if (searchQuery != null) _searchQuery = searchQuery;
    if (status != null) _statusFilter = status;
    if (priority != null) _priorityFilter = priority;
    
    _applyRequestFilters();
  }

  void _applyRequestFilters() {
    _filteredRequests = _myRequests.where((request) {
      // Search filter
      bool matchesSearch = _searchQuery.isEmpty ||
          request.typeName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          request.fieldValues.values.any((value) => 
            value.toString().toLowerCase().contains(_searchQuery.toLowerCase()));
      
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
    _searchQuery = '';
    _statusFilter = null;
    _priorityFilter = null;
    _applyRequestFilters();
  }

  Future<List<Request>> searchRequests(String query, String userId) async {
    try {
      final results = await _apiService.searchRequests(query);
      // Filter to only show user's own requests
      return results.where((r) => r.submittedBy == userId).toList();
    } catch (e) {
      _setError('Error searching requests: ${e.toString()}');
      return [];
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

  // Form Management Methods
  void selectRequestType(RequestType? requestType) {
    _selectedRequestType = requestType;
    _selectedTemplate = null;
    _clearFormData();
    notifyListeners();
  }

  void selectTemplate(RequestTemplate? template) {
    _selectedTemplate = template;
    if (template != null) {
      _formData.addAll(template.predefinedValues);
    }
    notifyListeners();
  }

  void updateFormField(String fieldId, dynamic value) {
    _formData[fieldId] = value;
    notifyListeners();
  }

  void updateFormPriority(Priority priority) {
    _formPriority = priority;
    notifyListeners();
  }

  void updateFormDueDate(DateTime? dueDate) {
    _formDueDate = dueDate;
    notifyListeners();
  }

  void addFormTag(String tag) {
    if (tag.isNotEmpty && !_formTags.contains(tag)) {
      _formTags.add(tag);
      notifyListeners();
    }
  }

  void removeFormTag(String tag) {
    _formTags.remove(tag);
    notifyListeners();
  }

  void _clearFormData() {
    _formData.clear();
    _formTags.clear();
    _formPriority = Priority.medium;
    _formDueDate = null;
    notifyListeners();
  }

  // Request Submission
  Future<bool> submitRequest(String userId) async {
    if (_selectedRequestType == null) {
      _setError('Please select a request type');
      return false;
    }

    // Validate required fields
    for (final field in _selectedRequestType!.fields) {
      if (field.required && (_formData[field.id] == null || 
          (_formData[field.id] is String && _formData[field.id].isEmpty))) {
        _setError('Please fill in all required fields: ${field.name}');
        return false;
      }
    }

    _isSubmittingRequest = true;
    notifyListeners();

    try {
      final request = Request(
        id: '',
        typeId: _selectedRequestType!.id,
        typeName: _selectedRequestType!.name,
        category: _selectedRequestType!.category,
        fieldValues: Map<String, dynamic>.from(_formData),
        status: 'Pending',
        priority: _formPriority,
        submittedBy: userId,
        submittedAt: DateTime.now(),
        dueDate: _formDueDate,
        tags: List<String>.from(_formTags),
        statusHistory: [],
        attachments: [],
      );

      final createdRequest = await _apiService.createRequest(request);
      
      // Add to local list
      _myRequests.insert(0, createdRequest);
      _applyRequestFilters();
      
      // Clear form
      _selectedRequestType = null;
      _selectedTemplate = null;
      _clearFormData();
      
      _setError(null);
      return true;
    } catch (e) {
      _setError('Error submitting request: ${e.toString()}');
      return false;
    } finally {
      _isSubmittingRequest = false;
      notifyListeners();
    }
  }

  // Cancel form and clear data
  void cancelForm() {
    _selectedRequestType = null;
    _selectedTemplate = null;
    _clearFormData();
    notifyListeners();
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

  // Comments Methods
  Future<List<RequestComment>> getRequestComments(String requestId) async {
    try {
      return await _apiService.getComments(requestId);
    } catch (e) {
      _setError('Error loading comments: ${e.toString()}');
      return [];
    }
  }

  Future<void> addRequestComment(String requestId, String content, String userId, String userName) async {
    try {
      final comment = RequestComment(
        id: '',
        requestId: requestId,
        authorId: userId,
        authorName: userName,
        content: content,
        createdAt: DateTime.now(),
      );
      
      await _apiService.addComment(comment);
      _setError(null);
    } catch (e) {
      _setError('Error adding comment: ${e.toString()}');
    }
  }

  // Get request by ID
  Request? getRequestById(String requestId) {
    try {
      return _myRequests.firstWhere((r) => r.id == requestId);
    } catch (e) {
      return null;
    }
  }

  // Get request type by ID
  Future<RequestType?> getRequestTypeById(String typeId) async {
    try {
      return await _apiService.getRequestTypeById(typeId);
    } catch (e) {
      _setError('Error loading request type: ${e.toString()}');
      return null;
    }
  }

  // Form validation
  bool validateForm() {
    if (_selectedRequestType == null) return false;
    
    for (final field in _selectedRequestType!.fields) {
      if (field.required && (_formData[field.id] == null || 
          (_formData[field.id] is String && _formData[field.id].isEmpty))) {
        return false;
      }
    }
    
    return true;
  }

  // Get form field value
  dynamic getFormFieldValue(String fieldId) {
    return _formData[fieldId];
  }

  // Initialize user data
  Future<void> initializeUserData(String userId) async {
    await Future.wait([
      loadMyRequests(userId),
      loadRequestTypes(),
      loadTemplates(),
      loadNotifications(userId),
    ]);
  }

  // Refresh user data
  Future<void> refreshUserData(String userId) async {
    await initializeUserData(userId);
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

  // Get available statuses for user's requests
  List<String> getAvailableStatuses() {
    final statuses = <String>{};
    for (final request in _myRequests) {
      statuses.add(request.status);
    }
    return statuses.toList()..sort();
  }

  // Get requests by status
  List<Request> getRequestsByStatus(String status) {
    return _myRequests.where((r) => r.status == status).toList();
  }

  // Get overdue requests
  List<Request> getOverdueRequests() {
    return _myRequests.where((r) => r.isOverdue).toList();
  }
}