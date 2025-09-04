import 'dart:math';
import '../models/models.dart';

class MockApiService {
  static final MockApiService _instance = MockApiService._internal();
  factory MockApiService() => _instance;
  MockApiService._internal() {
    _initializeSampleData();
  }

  // Mock data storage
  final List<User> _users = [];
  final List<RequestType> _requestTypes = [];
  final List<Request> _requests = [];
  final List<RequestTemplate> _templates = [];
  final List<RequestComment> _comments = [];
  final List<AppNotification> _notifications = [];
  
  // Counters
  int _userCounter = 4;
  int _requestCounter = 2;
  int _typeCounter = 2;
  int _templateCounter = 1;
  int _commentCounter = 1;
  int _notificationCounter = 0;
  int _historyCounter = 3;

  void _initializeSampleData() {
    // Initialize sample users
    _users.addAll([
      User(
        id: '1',
        name: 'John Admin',
        email: 'admin@example.com',
        password: 'password123',
        role: UserRole.admin,
        status: UserStatus.active,
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        lastLoginAt: DateTime.now().subtract(Duration(hours: 2)),
        profileData: {'department': 'IT', 'designation': 'System Administrator'},
        permissions: ['manage_users', 'create_request_types', 'update_status'],
        department: 'IT',
        active: true,
      ),
      User(
        id: '2',
        name: 'Jane User',
        email: 'user@example.com',
        password: 'password123',
        role: UserRole.user,
        status: UserStatus.active,
        createdAt: DateTime.now().subtract(Duration(days: 15)),
        lastLoginAt: DateTime.now().subtract(Duration(days: 1)),
        profileData: {'department': 'HR', 'designation': 'HR Assistant'},
        permissions: ['create_requests', 'view_own_requests'],
        department: 'HR',
        active: true,
      ),
      User(
        id: '3',
        name: 'Mike Manager',
        email: 'manager@example.com',
        password: 'password123',
        role: UserRole.admin,
        status: UserStatus.active,
        createdAt: DateTime.now().subtract(Duration(days: 45)),
        lastLoginAt: DateTime.now().subtract(Duration(hours: 8)),
        profileData: {'department': 'Operations', 'designation': 'Operations Manager'},
        permissions: ['manage_requests', 'assign_requests', 'view_analytics'],
        department: 'Operations',
        active: true,
      ),
    ]);

    // Initialize sample request types
    _requestTypes.addAll([
      RequestType(
        id: '1',
        name: 'Leave Request',
        description: 'Request for time off',
        category: 'HR',
        createdBy: 'John Admin',
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        fields: [
          CustomField(id: '1', name: 'Leave Type', type: FieldType.dropdown, 
            options: ['Annual', 'Sick', 'Personal', 'Emergency'], required: true),
          CustomField(id: '2', name: 'Start Date', type: FieldType.date, required: true),
          CustomField(id: '3', name: 'End Date', type: FieldType.date, required: true),
          CustomField(id: '4', name: 'Reason', type: FieldType.textarea, required: true),
        ],
        statusWorkflow: [
          StatusWorkflow(id: '1', name: 'Pending', color: '#FFA500', order: 0),
          StatusWorkflow(id: '2', name: 'Under Review', color: '#2196F3', order: 1),
          StatusWorkflow(id: '3', name: 'Approved', color: '#4CAF50', order: 2),
          StatusWorkflow(id: '4', name: 'Rejected', color: '#F44336', order: 3),
        ],
      ),
      RequestType(
        id: '2',
        name: 'IT Support',
        description: 'Technical support requests',
        category: 'IT',
        createdBy: 'John Admin',
        createdAt: DateTime.now().subtract(Duration(days: 25)),
        fields: [
          CustomField(id: '1', name: 'Issue Type', type: FieldType.dropdown, 
            options: ['Hardware', 'Software', 'Network', 'Account'], required: true),
          CustomField(id: '2', name: 'Priority', type: FieldType.dropdown, 
            options: ['Low', 'Medium', 'High', 'Critical'], required: true),
          CustomField(id: '3', name: 'Description', type: FieldType.textarea, required: true),
        ],
        statusWorkflow: [
          StatusWorkflow(id: '1', name: 'Open', color: '#FFA500', order: 0),
          StatusWorkflow(id: '2', name: 'In Progress', color: '#2196F3', order: 1),
          StatusWorkflow(id: '3', name: 'Resolved', color: '#4CAF50', order: 2),
          StatusWorkflow(id: '4', name: 'Closed', color: '#9E9E9E', order: 3),
        ],
      ),
    ]);

    // Initialize sample requests
    _requests.addAll([
      Request(
        id: '1',
        typeId: '1',
        typeName: 'Leave Request',
        category: 'HR',
        fieldValues: {
          'Leave Type': 'Annual',
          'Start Date': '2024-03-15',
          'End Date': '2024-03-20',
          'Reason': 'Family vacation',
        },
        status: 'Pending',
        priority: Priority.medium,
        submittedBy: '2',
        submittedAt: DateTime.now().subtract(Duration(days: 2)),
        dueDate: DateTime.now().add(Duration(days: 5)),
        tags: ['vacation', 'family'],
        statusHistory: [
          StatusChangeHistory(
            id: '1',
            fromStatus: '',
            toStatus: 'Pending',
            changedBy: 'Jane User',
            changedAt: DateTime.now().subtract(Duration(days: 2)),
          ),
        ],
      ),
      Request(
        id: '2',
        typeId: '2',
        typeName: 'IT Support',
        category: 'IT',
        fieldValues: {
          'Issue Type': 'Hardware',
          'Priority': 'High',
          'Description': 'Laptop screen is flickering',
        },
        status: 'In Progress',
        priority: Priority.high,
        submittedBy: '2',
        submittedAt: DateTime.now().subtract(Duration(days: 1)),
        assignedAdminId: '1',
        assignedAdminName: 'John Admin',
        tags: ['hardware', 'urgent'],
        statusHistory: [
          StatusChangeHistory(
            id: '2',
            fromStatus: '',
            toStatus: 'Open',
            changedBy: 'Jane User',
            changedAt: DateTime.now().subtract(Duration(days: 1)),
          ),
          StatusChangeHistory(
            id: '3',
            fromStatus: 'Open',
            toStatus: 'In Progress',
            changedBy: 'John Admin',
            changedAt: DateTime.now().subtract(Duration(hours: 4)),
          ),
        ],
      ),
    ]);

    // Initialize sample templates
    _templates.addAll([
      RequestTemplate(
        id: '1',
        name: 'Standard Leave Request',
        description: 'Template for common leave requests',
        typeId: '1',
        predefinedValues: {'Leave Type': 'Annual'},
        createdBy: '1',
        createdAt: DateTime.now().subtract(Duration(days: 10)),
      ),
    ]);

    // Initialize sample comments
    _comments.addAll([
      RequestComment(
        id: '1',
        requestId: '2',
        authorId: '1',
        authorName: 'John Admin',
        content: 'I\'ll look into this hardware issue. Can you bring your laptop to the IT office?',
        createdAt: DateTime.now().subtract(Duration(hours: 3)),
      ),
    ]);
  }

  // Authentication
  Future<User?> validateLogin(String email, String password) async {
    await Future.delayed(Duration(milliseconds: 500));
    
    try {
      final user = _users.firstWhere(
        (u) => u.email == email && u.password == password && u.status == UserStatus.active
      );
      
      // Update last login
      final userIndex = _users.indexWhere((u) => u.id == user.id);
      if (userIndex != -1) {
        _users[userIndex] = user.copyWith(lastLoginAt: DateTime.now());
      }
      
      return _users[userIndex];
    } catch (e) {
      return null;
    }
  }

  // Request Types
  Future<List<RequestType>> getRequestTypes() async {
    await Future.delayed(Duration(milliseconds: 300));
    return List.from(_requestTypes.where((type) => type.active));
  }

  Future<RequestType> getRequestTypeById(String id) async {
    await Future.delayed(Duration(milliseconds: 300));
    return _requestTypes.firstWhere((type) => type.id == id);
  }

  Future<RequestType> createRequestType(RequestType requestType) async {
    await Future.delayed(Duration(milliseconds: 500));
    final newType = RequestType(
      id: (++_typeCounter).toString(),
      name: requestType.name,
      description: requestType.description,
      category: requestType.category,
      createdBy: requestType.createdBy,
      createdAt: DateTime.now(),
      fields: requestType.fields,
      statusWorkflow: requestType.statusWorkflow,
    );
    _requestTypes.add(newType);
    return newType;
  }

  // Requests
  Future<List<Request>> getRequests({String? userId, String? assignedAdminId}) async {
    await Future.delayed(Duration(milliseconds: 500));
    
    var filteredRequests = List<Request>.from(_requests);
    
    if (userId != null) {
      filteredRequests = filteredRequests.where((r) => r.submittedBy == userId).toList();
    }
    
    if (assignedAdminId != null) {
      filteredRequests = filteredRequests.where((r) => r.assignedAdminId == assignedAdminId).toList();
    }
    
    return filteredRequests..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  Future<Request> createRequest(Request request) async {
    await Future.delayed(Duration(milliseconds: 500));
    
    final newRequest = Request(
      id: (++_requestCounter).toString(),
      typeId: request.typeId,
      typeName: request.typeName,
      category: request.category,
      fieldValues: request.fieldValues,
      status: 'Pending',
      priority: request.priority,
      submittedBy: request.submittedBy,
      submittedAt: DateTime.now(),
      dueDate: request.dueDate,
      tags: request.tags,
      statusHistory: [
        StatusChangeHistory(
          id: (++_historyCounter).toString(),
          fromStatus: '',
          toStatus: 'Pending',
          changedBy: request.submittedBy,
          changedAt: DateTime.now(),
        ),
      ],
    );
    
    _requests.add(newRequest);
    
    // Send notification to admins
    final adminUsers = _users.where((u) => u.role == UserRole.admin).toList();
    _sendNotificationToUsers(
      adminUsers.map((u) => u.id).toList(),
      'New Request Submitted',
      'A new ${request.typeName} request has been submitted.',
      requestId: newRequest.id,
    );
    
    return newRequest;
  }

  Future<Request> updateRequestStatus(String requestId, String newStatus, 
      {String? adminComments, String? adminName}) async {
    await Future.delayed(Duration(milliseconds: 500));
    
    final requestIndex = _requests.indexWhere((r) => r.id == requestId);
    if (requestIndex == -1) {
      throw Exception('Request not found');
    }
    
    final currentRequest = _requests[requestIndex];
    final oldStatus = currentRequest.status;
    
    final updatedHistory = List<StatusChangeHistory>.from(currentRequest.statusHistory);
    updatedHistory.add(
      StatusChangeHistory(
        id: (++_historyCounter).toString(),
        fromStatus: oldStatus,
        toStatus: newStatus,
        changedBy: adminName ?? 'System',
        changedAt: DateTime.now(),
        comments: adminComments,
      ),
    );
    
    _requests[requestIndex] = currentRequest.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
      adminComments: adminComments,
      statusHistory: updatedHistory,
    );
    
    // Send notification to request submitter
    _sendNotificationToUsers(
      [currentRequest.submittedBy],
      'Request Status Updated',
      'Your request status has been changed to $newStatus.',
      requestId: requestId,
    );
    
    return _requests[requestIndex];
  }

  Future<Request> assignRequest(String requestId, String adminId, String adminName) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    final requestIndex = _requests.indexWhere((r) => r.id == requestId);
    if (requestIndex == -1) {
      throw Exception('Request not found');
    }
    
    _requests[requestIndex] = _requests[requestIndex].copyWith(
      assignedAdminId: adminId,
      assignedAdminName: adminName,
      updatedAt: DateTime.now(),
    );
    
    // Send notification to assigned admin
    _sendNotificationToUsers(
      [adminId],
      'Request Assigned',
      'A new request has been assigned to you.',
      requestId: requestId,
    );
    
    return _requests[requestIndex];
  }

  Future<Request> updateRequestPriority(String requestId, Priority priority) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    final requestIndex = _requests.indexWhere((r) => r.id == requestId);
    if (requestIndex == -1) {
      throw Exception('Request not found');
    }
    
    _requests[requestIndex] = _requests[requestIndex].copyWith(
      priority: priority,
      updatedAt: DateTime.now(),
    );
    
    return _requests[requestIndex];
  }

  // Templates
  Future<List<RequestTemplate>> getTemplates({String? typeId}) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    if (typeId != null) {
      return _templates.where((t) => t.typeId == typeId).toList();
    }
    return List.from(_templates);
  }

  Future<RequestTemplate> createTemplate(RequestTemplate template) async {
    await Future.delayed(Duration(milliseconds: 500));
    
    final newTemplate = RequestTemplate(
      id: (++_templateCounter).toString(),
      name: template.name,
      description: template.description,
      typeId: template.typeId,
      predefinedValues: template.predefinedValues,
      createdBy: template.createdBy,
      createdAt: DateTime.now(),
    );
    
    _templates.add(newTemplate);
    return newTemplate;
  }

  Future<void> deleteTemplate(String id) async {
    await Future.delayed(Duration(milliseconds: 300));
    _templates.removeWhere((template) => template.id == id);
  }

  // Comments
  Future<List<RequestComment>> getComments(String requestId, {bool includePrivate = false}) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    var comments = _comments.where((c) => c.requestId == requestId).toList();
    
    if (!includePrivate) {
      comments = comments.where((c) => !c.isPrivate).toList();
    }
    
    return comments..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<RequestComment> addComment(RequestComment comment) async {
    await Future.delayed(Duration(milliseconds: 300));
    final newComment = RequestComment(
      id: (++_commentCounter).toString(),
      requestId: comment.requestId,
      authorId: comment.authorId,
      authorName: comment.authorName,
      content: comment.content,
      createdAt: DateTime.now(),
      isPrivate: comment.isPrivate,
    );
    _comments.add(newComment);
    return newComment;
  }

  Future<void> deleteComment(String commentId) async {
    await Future.delayed(Duration(milliseconds: 300));
    _comments.removeWhere((c) => c.id == commentId);
  }

  // Dashboard Analytics
  Future<DashboardStats> getDashboardStats() async {
    await Future.delayed(Duration(milliseconds: 500));
    
    final totalRequests = _requests.length;
    final pendingRequests = _requests.where((r) => 
      r.status.toLowerCase().contains('pending')).length;
    final inProgressRequests = _requests.where((r) => 
      r.status.toLowerCase().contains('review') || 
      r.status.toLowerCase().contains('progress')).length;
    final completedRequests = _requests.where((r) => 
      ['approved', 'completed', 'delivered'].any((s) => r.status.toLowerCase().contains(s))).length;
    final overdueRequests = _requests.where((r) => r.isOverdue).length;
    
    // Group by category
    final requestsByCategory = <String, int>{};
    for (final request in _requests) {
      requestsByCategory[request.category] = 
        (requestsByCategory[request.category] ?? 0) + 1;
    }
    
    // Group by status
    final requestsByStatus = <String, int>{};
    for (final request in _requests) {
      requestsByStatus[request.status] = 
        (requestsByStatus[request.status] ?? 0) + 1;
    }
    
    // Group by priority
    final requestsByPriority = <String, int>{};
    for (final request in _requests) {
      final priority = request.priority.toString().split('.').last;
      requestsByPriority[priority] = 
        (requestsByPriority[priority] ?? 0) + 1;
    }
    
    // Top performers (mock data)
    final topPerformers = [
      TopPerformer(adminId: '1', adminName: 'John Admin', completedRequests: 15),
      TopPerformer(adminId: '3', adminName: 'Mike Manager', completedRequests: 12),
    ];
    
    // Request trends (mock data for last 30 days)
    final trends = <RequestTrend>[];
    for (int i = 29; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final count = Random().nextInt(5) + 1;
      trends.add(RequestTrend(date: date, requestCount: count));
    }
    
    return DashboardStats(
      totalRequests: totalRequests,
      pendingRequests: pendingRequests,
      inProgressRequests: inProgressRequests,
      completedRequests: completedRequests,
      overdueRequests: overdueRequests,
      requestsByCategory: requestsByCategory,
      requestsByStatus: requestsByStatus,
      requestsByPriority: requestsByPriority,
      topPerformers: topPerformers,
      trends: trends,
    );
  }

  // Notifications
  Future<List<AppNotification>> getNotifications(String userId) async {
    await Future.delayed(Duration(milliseconds: 300));
    return _notifications
        .where((n) => n.targetUserIds.contains(userId))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await Future.delayed(Duration(milliseconds: 200));
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
  }

  Future<int> getUnreadNotificationCount(String userId) async {
    await Future.delayed(Duration(milliseconds: 200));
    final notifications = await getNotifications(userId);
    return notifications.where((n) => !n.isRead).length;
  }

  // Users
  Future<List<User>> getUsers() async {
    await Future.delayed(Duration(milliseconds: 500));
    return List.from(_users);
  }

  Future<List<User>> getAdminUsers() async {
    await Future.delayed(Duration(milliseconds: 300));
    return _users.where((user) => user.role == UserRole.admin).toList();
  }

  Future<User> createUser(User user) async {
    await Future.delayed(Duration(milliseconds: 500));
    final newUser = User(
      id: (++_userCounter).toString(),
      name: user.name,
      email: user.email,
      password: user.password,
      role: user.role,
      status: user.status,
      createdAt: DateTime.now(),
      profileData: user.profileData,
      permissions: user.permissions,
      department: user.department,
      active: user.active,
    );
    _users.add(newUser);
    return newUser;
  }

  Future<User> updateUser(User user) async {
    await Future.delayed(Duration(milliseconds: 500));
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
      return user;
    }
    throw Exception('User not found');
  }

  Future<void> deleteUser(String id) async {
    await Future.delayed(Duration(milliseconds: 500));
    _users.removeWhere((user) => user.id == id);
  }

  // Search
  Future<List<Request>> searchRequests(String query, {
    String? status,
    Priority? priority,
    String? category,
  }) async {
    await Future.delayed(Duration(milliseconds: 400));
    
    var results = List<Request>.from(_requests);
    
    // Text search
    if (query.isNotEmpty) {
      results = results.where((request) {
        return request.typeName.toLowerCase().contains(query.toLowerCase()) ||
               request.fieldValues.values.any((value) => 
                 value.toString().toLowerCase().contains(query.toLowerCase()));
      }).toList();
    }
    
    // Status filter
    if (status != null && status.isNotEmpty) {
      results = results.where((r) => r.status == status).toList();
    }
    
    // Priority filter
    if (priority != null) {
      results = results.where((r) => r.priority == priority).toList();
    }
    
    // Category filter
    if (category != null && category.isNotEmpty) {
      results = results.where((r) => r.category == category).toList();
    }
    
    return results..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  // Helper method for sending notifications
  void _sendNotificationToUsers(List<String> userIds, String title, String message, 
      {String? requestId}) {
    final notification = AppNotification(
      id: (++_notificationCounter).toString(),
      title: title,
      message: message,
      requestId: requestId,
      targetUserIds: userIds,
      senderName: 'System',
      createdAt: DateTime.now(),
    );
    _notifications.add(notification);
  }

  // Export functionality (mock)
  Future<String> exportRequestsToExcel(List<Request> requests) async {
    await Future.delayed(Duration(milliseconds: 1000));
    return 'mock://exports/requests_${DateTime.now().millisecondsSinceEpoch}.xlsx';
  }

  Future<String> exportRequestsToPdf(List<Request> requests) async {
    await Future.delayed(Duration(milliseconds: 1000));
    return 'mock://exports/requests_${DateTime.now().millisecondsSinceEpoch}.pdf';
  }
}