import 'dart:typed_data';
import 'dart:convert';
import 'dart:math';

// Enums
enum Priority { low, medium, high, urgent }
enum UserRole { user, admin }
enum UserStatus { active, inactive, suspended }
enum NotificationType { info, warning, error, success }

// Core Models
class RequestType {
  final String id;
  final String name;
  final String description;
  final String category;
  final bool active;
  final String createdBy;
  final DateTime createdAt;
  final List<CustomField> fields;
  final List<StatusWorkflow> statusWorkflow;

  RequestType({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.active = true,
    required this.createdBy,
    required this.createdAt,
    this.fields = const [],
    this.statusWorkflow = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'active': active,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'fields': fields.map((f) => f.toJson()).toList(),
      'statusWorkflow': statusWorkflow.map((s) => s.toJson()).toList(),
    };
  }

  static RequestType fromJson(Map<String, dynamic> json) {
    return RequestType(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      active: json['active'] ?? true,
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      fields: json['fields'] != null
          ? (json['fields'] as List).map((f) => CustomField.fromJson(f)).toList()
          : [],
      statusWorkflow: json['statusWorkflow'] != null
          ? (json['statusWorkflow'] as List).map((s) => StatusWorkflow.fromJson(s)).toList()
          : [],
    );
  }
}

class StatusWorkflow {
  final String id;
  final String name;
  final String color;
  final int order;
  final bool autoTransition;
  final int? autoTransitionDays;

  StatusWorkflow({
    required this.id,
    required this.name,
    required this.color,
    required this.order,
    this.autoTransition = false,
    this.autoTransitionDays,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'order': order,
      'autoTransition': autoTransition,
      'autoTransitionDays': autoTransitionDays,
    };
  }

  static StatusWorkflow fromJson(Map<String, dynamic> json) {
    return StatusWorkflow(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      order: json['order'],
      autoTransition: json['autoTransition'] ?? false,
      autoTransitionDays: json['autoTransitionDays'],
    );
  }
}

enum FieldType { text, number, email, date, dropdown, checkbox, textarea }

class CustomField {
  final String id;
  final String name;
  final FieldType type;
  final List<String> options;
  final bool required;

  CustomField({
    required this.id,
    required this.name,
    required this.type,
    this.options = const [],
    this.required = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'options': options,
      'required': required,
    };
  }

  static CustomField fromJson(Map<String, dynamic> json) {
    return CustomField(
      id: json['id'],
      name: json['name'],
      type: FieldType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      options: List<String>.from(json['options'] ?? []),
      required: json['required'] ?? false,
    );
  }
}

class Request {
  final String id;
  final String typeId;
  final String typeName;
  final String category;
  final Map<String, dynamic> fieldValues;
  final String status;
  final Priority priority;
  final String submittedBy;
  final DateTime submittedAt;
  final DateTime? updatedAt;
  final DateTime? dueDate;
  final String? adminComments;
  final String? assignedAdminId;
  final String? assignedAdminName;
  final List<String> tags;
  final List<StatusChangeHistory> statusHistory;
  final List<FileAttachment> attachments;

  Request({
    required this.id,
    required this.typeId,
    required this.typeName,
    required this.category,
    required this.fieldValues,
    required this.status,
    this.priority = Priority.medium,
    required this.submittedBy,
    required this.submittedAt,
    this.updatedAt,
    this.dueDate,
    this.adminComments,
    this.assignedAdminId,
    this.assignedAdminName,
    this.tags = const [],
    this.statusHistory = const [],
    this.attachments = const [],
  });

  bool get isOverdue => dueDate != null && 
      DateTime.now().isAfter(dueDate!) && 
      !['Completed', 'Approved', 'Delivered', 'Rejected'].contains(status);

  Request copyWith({
    String? status,
    Priority? priority,
    DateTime? updatedAt,
    DateTime? dueDate,
    String? adminComments,
    String? assignedAdminId,
    String? assignedAdminName,
    List<String>? tags,
    List<StatusChangeHistory>? statusHistory,
    List<FileAttachment>? attachments,
  }) {
    return Request(
      id: this.id,
      typeId: this.typeId,
      typeName: this.typeName,
      category: this.category,
      fieldValues: this.fieldValues,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      submittedBy: this.submittedBy,
      submittedAt: this.submittedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      adminComments: adminComments ?? this.adminComments,
      assignedAdminId: assignedAdminId ?? this.assignedAdminId,
      assignedAdminName: assignedAdminName ?? this.assignedAdminName,
      tags: tags ?? this.tags,
      statusHistory: statusHistory ?? this.statusHistory,
      attachments: attachments ?? this.attachments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'typeId': typeId,
      'typeName': typeName,
      'category': category,
      'fieldValues': fieldValues,
      'status': status,
      'priority': priority.toString().split('.').last,
      'submittedBy': submittedBy,
      'submittedAt': submittedAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'adminComments': adminComments,
      'assignedAdminId': assignedAdminId,
      'assignedAdminName': assignedAdminName,
      'tags': tags,
      'statusHistory': statusHistory.map((h) => h.toJson()).toList(),
      'attachments': attachments.map((a) => a.toJson()).toList(),
    };
  }

  static Request fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['id'],
      typeId: json['typeId'],
      typeName: json['typeName'],
      category: json['category'] ?? 'General',
      fieldValues: json['fieldValues'],
      status: json['status'],
      priority: Priority.values.firstWhere(
        (p) => p.toString().split('.').last == (json['priority'] ?? 'medium'),
        orElse: () => Priority.medium,
      ),
      submittedBy: json['submittedBy'],
      submittedAt: DateTime.parse(json['submittedAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : null,
      adminComments: json['adminComments'],
      assignedAdminId: json['assignedAdminId'],
      assignedAdminName: json['assignedAdminName'],
      tags: List<String>.from(json['tags'] ?? []),
      statusHistory: json['statusHistory'] != null
          ? (json['statusHistory'] as List)
              .map((h) => StatusChangeHistory.fromJson(h))
              .toList()
          : [],
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((a) => FileAttachment.fromJson(a))
              .toList()
          : [],
    );
  }
}

class StatusChangeHistory {
  final String id;
  final String fromStatus;
  final String toStatus;
  final String changedBy;
  final DateTime changedAt;
  final String? comments;

  StatusChangeHistory({
    required this.id,
    required this.fromStatus,
    required this.toStatus,
    required this.changedBy,
    required this.changedAt,
    this.comments,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromStatus': fromStatus,
      'toStatus': toStatus,
      'changedBy': changedBy,
      'changedAt': changedAt.toIso8601String(),
      'comments': comments,
    };
  }

  static StatusChangeHistory fromJson(Map<String, dynamic> json) {
    return StatusChangeHistory(
      id: json['id'],
      fromStatus: json['fromStatus'],
      toStatus: json['toStatus'],
      changedBy: json['changedBy'],
      changedAt: DateTime.parse(json['changedAt']),
      comments: json['comments'],
    );
  }
}

class FileAttachment {
  final String id;
  final String name;
  final String type;
  final int size;
  final String url;
  final DateTime uploadedAt;
  final String uploadedBy;

  FileAttachment({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.url,
    required this.uploadedAt,
    required this.uploadedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'size': size,
      'url': url,
      'uploadedAt': uploadedAt.toIso8601String(),
      'uploadedBy': uploadedBy,
    };
  }

  static FileAttachment fromJson(Map<String, dynamic> json) {
    return FileAttachment(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      size: json['size'],
      url: json['url'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      uploadedBy: json['uploadedBy'],
    );
  }
}

class RequestTemplate {
  final String id;
  final String name;
  final String description;
  final String typeId;
  final Map<String, dynamic> predefinedValues;
  final String createdBy;
  final DateTime createdAt;

  RequestTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.typeId,
    required this.predefinedValues,
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'typeId': typeId,
      'predefinedValues': predefinedValues,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static RequestTemplate fromJson(Map<String, dynamic> json) {
    return RequestTemplate(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      typeId: json['typeId'],
      predefinedValues: json['predefinedValues'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class RequestComment {
  final String id;
  final String requestId;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final bool isPrivate;
  final List<String> mentions;
  final String? parentCommentId;

  RequestComment({
    required this.id,
    required this.requestId,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.isPrivate = false,
    this.mentions = const [],
    this.parentCommentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestId': requestId,
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'isPrivate': isPrivate,
      'mentions': mentions,
      'parentCommentId': parentCommentId,
    };
  }

  static RequestComment fromJson(Map<String, dynamic> json) {
    return RequestComment(
      id: json['id'],
      requestId: json['requestId'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      isPrivate: json['isPrivate'] ?? false,
      mentions: List<String>.from(json['mentions'] ?? []),
      parentCommentId: json['parentCommentId'],
    );
  }
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String? requestId;
  final List<String> targetUserIds;
  final String senderName;
  final DateTime createdAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.type = NotificationType.info,
    this.requestId,
    required this.targetUserIds,
    required this.senderName,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'requestId': requestId,
      'targetUserIds': targetUserIds,
      'senderName': senderName,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  static AppNotification fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values.firstWhere(
        (t) => t.toString().split('.').last == (json['type'] ?? 'info'),
        orElse: () => NotificationType.info,
      ),
      requestId: json['requestId'],
      targetUserIds: List<String>.from(json['targetUserIds']),
      senderName: json['senderName'],
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
    );
  }
}

// User Management Models
class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final UserStatus status;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic> profileData;
  final List<String> permissions;
  final String department;
final bool active;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.status = UserStatus.active,
    required this.createdAt,
    this.lastLoginAt,
    this.profileData = const {},
    this.permissions = const [],
     required this.department,  // Add this
  required this.active,      // Add this
  });

  User copyWith({
    String? name,
    String? email,
    String? password,
    UserRole? role,
    UserStatus? status,
    DateTime? lastLoginAt,
    Map<String, dynamic>? profileData,
    List<String>? permissions,
  }) {
   return User(
  id: this.id,
  name: name ?? this.name,
  email: email ?? this.email,
  password: password ?? this.password,
  role: role ?? this.role,
  status: status ?? this.status,
  createdAt: this.createdAt,
  lastLoginAt: lastLoginAt ?? this.lastLoginAt,
  profileData: profileData ?? this.profileData,
  permissions: permissions ?? this.permissions,
  department: this.department,
  active: this.active,
);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'profileData': profileData,
      'permissions': permissions,
    };
  }

  static User fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      role: UserRole.values.firstWhere(
        (r) => r.toString().split('.').last == json['role'],
      ),
      status: UserStatus.values.firstWhere(
        (s) => s.toString().split('.').last == json['status'],
        orElse: () => UserStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
      profileData: json['profileData'] ?? {},
      permissions: List<String>.from(json['permissions'] ?? []),
      department: json['department'] ?? 'General',
active: json['active'] ?? true,
    );
  }
}

class Permission {
  final String id;
  final String name;
  final String description;

  Permission({
    required this.id,
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  static Permission fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

class UserProfileField {
  final String id;
  final String name;
  final String type;
  final List<String> options;
  final bool required;

  UserProfileField({
    required this.id,
    required this.name,
    required this.type,
    this.options = const [],
    this.required = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'options': options,
      'required': required,
    };
  }

  static UserProfileField fromJson(Map<String, dynamic> json) {
    return UserProfileField(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      options: List<String>.from(json['options'] ?? []),
      required: json['required'] ?? false,
    );
  }
}

class ActivityLog {
  final String id;
  final String userId;
  final String userName;
  final String action;
  final String description;
  final DateTime timestamp;
  final String? ipAddress;
  final String? requestId;

  ActivityLog({
    required this.id,
    required this.userId,
    required this.userName,
    required this.action,
    required this.description,
    required this.timestamp,
    this.ipAddress,
    this.requestId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'action': action,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'ipAddress': ipAddress,
      'requestId': requestId,
    };
  }

  static ActivityLog fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      action: json['action'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      ipAddress: json['ipAddress'],
      requestId: json['requestId'],
    );
  }
}

class UserNotification {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final List<String> targetUserIds;
  final String senderName;

  UserNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.targetUserIds,
    required this.senderName,
  });

  UserNotification copyWith({
    String? id,
    DateTime? createdAt,
  }) {
    return UserNotification(
      id: id ?? this.id,
      title: this.title,
      message: this.message,
      createdAt: createdAt ?? this.createdAt,
      targetUserIds: this.targetUserIds,
      senderName: this.senderName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'targetUserIds': targetUserIds,
      'senderName': senderName,
    };
  }

  static UserNotification fromJson(Map<String, dynamic> json) {
    return UserNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
      targetUserIds: List<String>.from(json['targetUserIds']),
      senderName: json['senderName'],
    );
  }
}

class NotificationSettings {
  final String userId;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;

  NotificationSettings({
    required this.userId,
    this.emailNotifications = true,
    this.pushNotifications = false,
    this.smsNotifications = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'smsNotifications': smsNotifications,
    };
  }

  static NotificationSettings fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      userId: json['userId'],
      emailNotifications: json['emailNotifications'] ?? true,
      pushNotifications: json['pushNotifications'] ?? false,
      smsNotifications: json['smsNotifications'] ?? false,
    );
  }
}

// Dashboard Models
class DashboardStats {
  final int totalRequests;
  final int pendingRequests;
  final int inProgressRequests;
  final int completedRequests;
  final int overdueRequests;
  final Map<String, int> requestsByCategory;
  final Map<String, int> requestsByStatus;
  final Map<String, int> requestsByPriority;
  final List<TopPerformer> topPerformers;
  final List<RequestTrend> trends;

  DashboardStats({
    required this.totalRequests,
    required this.pendingRequests,
    required this.inProgressRequests,
    required this.completedRequests,
    required this.overdueRequests,
    required this.requestsByCategory,
    required this.requestsByStatus,
    required this.requestsByPriority,
    required this.topPerformers,
    required this.trends,
  });
}

class TopPerformer {
  final String adminId;
  final String adminName;
  final int completedRequests;

  TopPerformer({
    required this.adminId,
    required this.adminName,
    required this.completedRequests,
  });
}

class RequestTrend {
  final DateTime date;
  final int requestCount;

  RequestTrend({
    required this.date,
    required this.requestCount,
  });
}

// Main Mock API Service
class MockApiService {
  static final MockApiService _instance = MockApiService._internal();
  factory MockApiService() => _instance;
  MockApiService._internal() {
    _initializeSampleData();
  }

  // Mock data storage
  final List<String> _adminNames = ['Admin Smith', 'Admin Johnson', 'Admin Davis', 'Admin Wilson'];
  final List<String> _categories = ['IT', 'HR', 'Finance', 'Operations', 'Maintenance', 'General'];

  // In-memory storage
  final List<RequestType> _requestTypes = [];
  final List<Request> _requests = [];
  final List<RequestTemplate> _templates = [];
  final List<RequestComment> _comments = [];
  final List<FileAttachment> _attachments = [];
  final List<AppNotification> _appNotifications = [];

  int _requestCounter = 0;
  int _typeCounter = 0;
  int _historyCounter = 0;
  int _templateCounter = 0;
  int _commentCounter = 0;
  int _attachmentCounter = 0;
  int _notificationCounter = 0;

  // User Management Storage
  final List<User> _users = [];
  final List<UserProfileField> _profileFields = [];
  final List<Permission> _permissions = [];
  final List<ActivityLog> _activityLogs = [];
  final List<UserNotification> _notifications = [];

  int _userCounter = 4;
  int _profileFieldCounter = 4;
  int _activityCounter = 0;
  int _userNotificationCounter = 0;

  void _initializeSampleData() {
    // Initialize users
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
        profileData: {
          'department': 'IT',
          'designation': 'System Administrator',
          'phone': '+1234567890',
        },
        permissions: ['manage_users', 'create_request_types', 'update_status', 'view_analytics'],
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
        profileData: {
          'department': 'HR',
          'designation': 'HR Assistant',
          'phone': '+1234567891',
        },
        permissions: ['create_requests', 'view_own_requests'],
        department: 'IT',
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
        profileData: {
          'department': 'Operations',
          'designation': 'Operations Manager',
          'phone': '+1234567892',
        },
        permissions: ['manage_requests', 'assign_requests', 'view_analytics'],
        department: 'IT',
active: true,
      ),
      User(
        id: '4',
        name: 'Sarah Analyst',
        email: 'analyst@example.com',
        password: 'password123',
        role: UserRole.user,
        status: UserStatus.inactive,
        createdAt: DateTime.now().subtract(Duration(days: 60)),
        lastLoginAt: DateTime.now().subtract(Duration(days: 10)),
        profileData: {
          'department': 'Finance',
          'designation': 'Financial Analyst',
          'phone': '+1234567893',
        },
        permissions: ['create_requests', 'view_own_requests'],
        department: 'IT',
active: true,
      ),
    ]);

    // Initialize profile fields
    _profileFields.addAll([
      UserProfileField(id: '1', name: 'Department', type: 'dropdown', 
        options: ['IT', 'HR', 'Finance', 'Operations'], required: true),
      UserProfileField(id: '2', name: 'Designation', type: 'text', required: true),
      UserProfileField(id: '3', name: 'Phone', type: 'text', required: false),
      UserProfileField(id: '4', name: 'Emergency Contact', type: 'text', required: false),
    ]);

    // Initialize permissions
    _permissions.addAll([
      Permission(
        id: 'manage_users',
        name: 'Manage Users',
        description: 'Create, edit, and delete users',
      ),
      Permission(
        id: 'create_request_types',
        name: 'Create Request Types',
        description: 'Create and edit request types',
      ),
      Permission(
        id: 'update_status',
        name: 'Update Status',
        description: 'Update request status',
      ),
      Permission(
        id: 'view_analytics',
        name: 'View Analytics',
        description: 'Access analytics and reports',
      ),
      Permission(
        id: 'send_notifications',
        name: 'Send Notifications',
        description: 'Send notifications to users',
      ),
      Permission(
        id: 'manage_assignments',
        name: 'Manage Assignments',
        description: 'Assign and reassign requests',
      ),
    ]);

    // Initialize sample activity logs
    _activityLogs.addAll([
      ActivityLog(
        id: '1',
        userId: '1',
        userName: 'John Admin',
        action: 'login',
        description: 'Admin logged in',
        timestamp: DateTime.now().subtract(Duration(hours: 2)),
        ipAddress: '192.168.1.100',
      ),
      ActivityLog(
        id: '2',
        userId: '2',
        userName: 'Jane User',
        action: 'request_created',
        description: 'Created a new leave request',
        timestamp: DateTime.now().subtract(Duration(hours: 5)),
        ipAddress: '192.168.1.101',
      ),
      ActivityLog(
        id: '3',
        userId: '3',
        userName: 'Mike Manager',
        action: 'status_changed',
        description: 'Changed request status from Pending to Approved',
        timestamp: DateTime.now().subtract(Duration(hours: 8)),
        ipAddress: '192.168.1.102',
      ),
    ]);
    _activityCounter = 3;

    // Initialize sample notifications
    _notifications.addAll([
      UserNotification(
        id: '1',
        title: 'System Maintenance',
        message: 'The system will be down for maintenance on Sunday from 2 AM to 4 AM.',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        targetUserIds: _users.map((u) => u.id).toList(),
        senderName: 'John Admin',
      ),
      UserNotification(
        id: '2',
        title: 'New Request Type Available',
        message: 'A new request type "Equipment Maintenance" has been added.',
        createdAt: DateTime.now().subtract(Duration(hours: 6)),
        targetUserIds: ['2', '4'],
        senderName: 'John Admin',
      ),
    ]);
    _userNotificationCounter = 2;

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
    _typeCounter = 2;

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
        submittedBy: '4',
        submittedAt: DateTime.now().subtract(Duration(days: 1)),
        assignedAdminId: '1',
        assignedAdminName: 'John Admin',
        tags: ['hardware', 'urgent'],
        statusHistory: [
          StatusChangeHistory(
            id: '2',
            fromStatus: '',
            toStatus: 'Open',
            changedBy: 'Sarah Analyst',
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
    _requestCounter = 2;

    // Initialize sample templates
    _templates.addAll([
      RequestTemplate(
        id: '1',
        name: 'Standard Leave Request',
        description: 'Template for common leave requests',
        typeId: '1',
        predefinedValues: {
          'Leave Type': 'Annual',
        },
        createdBy: '1',
        createdAt: DateTime.now().subtract(Duration(days: 10)),
      ),
    ]);
    _templateCounter = 1;

    // Initialize sample comments
    _comments.addAll([
      RequestComment(
        id: '1',
        requestId: '2',
        authorId: '1',
        authorName: 'John Admin',
        content: 'I\'ll look into this hardware issue. Can you bring your laptop to the IT office?',
        createdAt: DateTime.now().subtract(Duration(hours: 3)),
        mentions: ['Sarah Analyst'],
      ),
    ]);
    _commentCounter = 1;
  }

  // Authentication
  Future<User?> login(String email, String password) async {
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
      
      _logActivity(user.id, 'login', 'User logged in');
      return _users[userIndex];
    } catch (e) {
      return null;
    }
  }

  // Request Types Management
  Future<List<RequestType>> getRequestTypes() async {
    await Future.delayed(Duration(milliseconds: 300));
    return List.from(_requestTypes.where((type) => type.active));
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
    
    _logActivity(requestType.createdBy, 'type_created', 
      'Created request type: ${requestType.name}');
    
    return newType;
  }

  Future<RequestType> updateRequestType(RequestType requestType) async {
    await Future.delayed(Duration(milliseconds: 500));
    final index = _requestTypes.indexWhere((type) => type.id == requestType.id);
    if (index != -1) {
      _requestTypes[index] = requestType;
      _logActivity(requestType.createdBy, 'type_updated', 
        'Updated request type: ${requestType.name}');
      return requestType;
    }
    throw Exception('Request type not found');
  }

  Future<void> deleteRequestType(String id) async {
    await Future.delayed(Duration(milliseconds: 300));
    final index = _requestTypes.indexWhere((type) => type.id == id);
    if (index != -1) {
      _requestTypes[index] = RequestType(
        id: _requestTypes[index].id,
        name: _requestTypes[index].name,
        description: _requestTypes[index].description,
        category: _requestTypes[index].category,
        active: false,
        createdBy: _requestTypes[index].createdBy,
        createdAt: _requestTypes[index].createdAt,
        fields: _requestTypes[index].fields,
        statusWorkflow: _requestTypes[index].statusWorkflow,
      );
    }
  }

  // Request Management
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
    
    _logActivity(request.submittedBy, 'request_created', 
      'Created ${request.typeName} request', requestId: newRequest.id);
    
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
    
    _logActivity(adminName ?? 'System', 'status_changed', 
      'Changed status from $oldStatus to $newStatus', requestId: requestId);
    
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
    
    _logActivity(adminId, 'request_assigned', 
      'Request assigned to $adminName', requestId: requestId);
    
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

  Future<Request> updateRequestTags(String requestId, List<String> tags) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    final requestIndex = _requests.indexWhere((r) => r.id == requestId);
    if (requestIndex == -1) {
      throw Exception('Request not found');
    }
    
    _requests[requestIndex] = _requests[requestIndex].copyWith(
      tags: tags,
      updatedAt: DateTime.now(),
    );
    
    return _requests[requestIndex];
  }

  // Search and Filtering
  Future<List<Request>> searchRequests(String query, {
    String? status,
    Priority? priority,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    String? assignedAdminId,
  }) async {
    await Future.delayed(Duration(milliseconds: 400));
    
    var results = List<Request>.from(_requests);
    
    // Text search
    if (query.isNotEmpty) {
      results = results.where((request) {
        return request.typeName.toLowerCase().contains(query.toLowerCase()) ||
               request.fieldValues.values.any((value) => 
                 value.toString().toLowerCase().contains(query.toLowerCase())) ||
               request.tags.any((tag) => 
                 tag.toLowerCase().contains(query.toLowerCase()));
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
    
    // Date range filter
    if (startDate != null) {
      results = results.where((r) => r.submittedAt.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      results = results.where((r) => r.submittedAt.isBefore(endDate)).toList();
    }
    
    // Assigned admin filter
    if (assignedAdminId != null && assignedAdminId.isNotEmpty) {
      results = results.where((r) => r.assignedAdminId == assignedAdminId).toList();
    }
    
    return results..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
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
    
    _logActivity(template.createdBy, 'template_created', 
      'Created template: ${template.name}');
    
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
      mentions: comment.mentions,
      parentCommentId: comment.parentCommentId,
    );
    _comments.add(newComment);
    
    _logActivity(comment.authorId, 'comment_added', 
      'Added comment to request', requestId: comment.requestId);
    
    // Send notifications for mentions
    if (comment.mentions.isNotEmpty) {
      final mentionedUsers = _users.where((u) => 
        comment.mentions.contains(u.name) || comment.mentions.contains('@${u.name}')).toList();
      
      for (final user in mentionedUsers) {
        _sendNotificationToUsers(
          [user.id],
          'You were mentioned',
          '${comment.authorName} mentioned you in a comment.',
          requestId: comment.requestId,
        );
      }
    }
    
    // Notify request owner of new comment (if not private and not the commenter)
    final request = _requests.firstWhere((r) => r.id == comment.requestId);
    if (!comment.isPrivate && request.submittedBy != comment.authorId) {
      _sendNotificationToUsers(
        [request.submittedBy],
        'New Comment',
        '${comment.authorName} added a comment to your request.',
        requestId: comment.requestId,
      );
    }
    
    return newComment;
  }

  Future<void> deleteComment(String commentId) async {
    await Future.delayed(Duration(milliseconds: 300));
    final comment = _comments.where((c) => c.id == commentId).firstOrNull;
    if (comment != null) {
      _comments.removeWhere((c) => c.id == commentId);
      _logActivity(comment.authorId, 'comment_deleted', 
        'Deleted comment', requestId: comment.requestId);
    }
  }

  // File Attachments
  Future<FileAttachment> uploadFile(String requestId, String fileName, String fileType, 
      Uint8List fileData, String uploadedBy) async {
    await Future.delayed(Duration(milliseconds: 800)); // Simulate upload time
    
    final attachment = FileAttachment(
      id: (++_attachmentCounter).toString(),
      name: fileName,
      type: fileType,
      size: fileData.length,
      url: 'mock://files/${_attachmentCounter}/$fileName',
      uploadedAt: DateTime.now(),
      uploadedBy: uploadedBy,
    );
    
    _attachments.add(attachment);
    
    // Add to request
    final requestIndex = _requests.indexWhere((r) => r.id == requestId);
    if (requestIndex != -1) {
      final currentAttachments = List<FileAttachment>.from(_requests[requestIndex].attachments);
      currentAttachments.add(attachment);
      _requests[requestIndex] = _requests[requestIndex].copyWith(attachments: currentAttachments);
    }
    
    _logActivity(uploadedBy, 'file_uploaded', 
      'Uploaded file: $fileName', requestId: requestId);
    
    return attachment;
  }

  Future<void> deleteAttachment(String requestId, String attachmentId) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    final attachment = _attachments.where((a) => a.id == attachmentId).firstOrNull;
    if (attachment != null) {
      _attachments.removeWhere((a) => a.id == attachmentId);
      
      // Remove from request
      final requestIndex = _requests.indexWhere((r) => r.id == requestId);
      if (requestIndex != -1) {
        final currentAttachments = _requests[requestIndex].attachments
            .where((a) => a.id != attachmentId).toList();
        _requests[requestIndex] = _requests[requestIndex].copyWith(attachments: currentAttachments);
      }
      
      _logActivity(attachment.uploadedBy, 'file_deleted', 
        'Deleted file: ${attachment.name}', requestId: requestId);
    }
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
    
    // Top performers (mock data for now)
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
    return _appNotifications
        .where((n) => n.targetUserIds.contains(userId))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await Future.delayed(Duration(milliseconds: 200));
    final index = _appNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _appNotifications[index] = AppNotification(
        id: _appNotifications[index].id,
        title: _appNotifications[index].title,
        message: _appNotifications[index].message,
        type: _appNotifications[index].type,
        requestId: _appNotifications[index].requestId,
        targetUserIds: _appNotifications[index].targetUserIds,
        senderName: _appNotifications[index].senderName,
        createdAt: _appNotifications[index].createdAt,
        isRead: true,
      );
    }
  }

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
    _appNotifications.add(notification);
  }

  // Utility methods
  Future<List<String>> getAvailableAdmins() async {
    await Future.delayed(Duration(milliseconds: 200));
    return _adminNames;
  }

  Future<List<String>> getCategories() async {
    await Future.delayed(Duration(milliseconds: 200));
    return _categories;
  }

  Future<List<String>> getPopularTags({int limit = 10}) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    final tagCounts = <String, int>{};
    for (final request in _requests) {
      for (final tag in request.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }
    
    final sortedTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedTags.take(limit).map((e) => e.key).toList();
  }

  // Auto-transition for status workflow
  Future<void> processAutoTransitions() async {
    await Future.delayed(Duration(milliseconds: 300));
    
    for (final request in _requests) {
      final requestType = _requestTypes.firstWhere((t) => t.id == request.typeId);
      final currentStatus = requestType.statusWorkflow
          .where((s) => s.name == request.status).firstOrNull;
      
      if (currentStatus != null && currentStatus.autoTransition && 
          currentStatus.autoTransitionDays != null) {
        final daysSinceUpdate = DateTime.now()
            .difference(request.updatedAt ?? request.submittedAt).inDays;
        
        if (daysSinceUpdate >= currentStatus.autoTransitionDays!) {
          // Find next status
          final nextStatusIndex = requestType.statusWorkflow
              .indexWhere((s) => s.id == currentStatus.id) + 1;
          
          if (nextStatusIndex < requestType.statusWorkflow.length) {
            final nextStatus = requestType.statusWorkflow[nextStatusIndex];
            
            await updateRequestStatus(
              request.id,
              nextStatus.name,
              adminComments: 'Auto-transitioned after ${currentStatus.autoTransitionDays} days',
              adminName: 'System',
            );
          }
        }
      }
    }
  }

  // User Management Methods
  Future<List<User>> getUsers() async {
    await Future.delayed(Duration(milliseconds: 500));
    return List.from(_users);
  }

  Future<User> getUserById(String id) async {
    await Future.delayed(Duration(milliseconds: 300));
    return _users.firstWhere((user) => user.id == id);
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
    
    _logActivity(newUser.id, 'user_created', 'User account created');
    
    return newUser;
  }

  Future<User> updateUser(User user) async {
    await Future.delayed(Duration(milliseconds: 500));
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
      _logActivity(user.id, 'user_updated', 'User profile updated');
      return user;
    }
    throw Exception('User not found');
  }

  Future<void> deleteUser(String id) async {
    await Future.delayed(Duration(milliseconds: 500));
    _users.removeWhere((user) => user.id == id);
    _logActivity(id, 'user_deleted', 'User account deleted');
  }

  Future<List<UserProfileField>> getProfileFields() async {
    await Future.delayed(Duration(milliseconds: 300));
    return List.from(_profileFields);
  }

  Future<UserProfileField> createProfileField(UserProfileField field) async {
    await Future.delayed(Duration(milliseconds: 300));
    final newField = UserProfileField(
      id: (++_profileFieldCounter).toString(),
      name: field.name,
      type: field.type,
      options: field.options,
      required: field.required,
    );
    _profileFields.add(newField);
    return newField;
  }

  Future<UserProfileField> updateProfileField(UserProfileField field) async {
    await Future.delayed(Duration(milliseconds: 300));
    final index = _profileFields.indexWhere((f) => f.id == field.id);
    if (index != -1) {
      _profileFields[index] = field;
      return field;
    }
    throw Exception('Profile field not found');
  }

  Future<void> deleteProfileField(String id) async {
    await Future.delayed(Duration(milliseconds: 300));
    _profileFields.removeWhere((field) => field.id == id);
  }

  Future<List<Permission>> getAllPermissions() async {
    await Future.delayed(Duration(milliseconds: 300));
    return List.from(_permissions);
  }

  Future<List<ActivityLog>> getActivityLogs({String? userId}) async {
    await Future.delayed(Duration(milliseconds: 500));
    if (userId != null) {
      return _activityLogs.where((log) => log.userId == userId).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
    return _activityLogs..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<List<UserNotification>> getUserNotifications() async {
    await Future.delayed(Duration(milliseconds: 500));
    return List.from(_notifications)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<UserNotification> createUserNotification(UserNotification notification) async {
    await Future.delayed(Duration(milliseconds: 500));
    final newNotification = notification.copyWith(
      id: (++_userNotificationCounter).toString(),
      createdAt: DateTime.now(),
    );
    _notifications.add(newNotification);
    
    _logActivity(newNotification.senderName, 'notification_sent', 
      'Sent notification: ${newNotification.title}');
    
    return newNotification;
  }

  Future<void> deleteUserNotification(String id) async {
    await Future.delayed(Duration(milliseconds: 500));
    _notifications.removeWhere((notification) => notification.id == id);
  }

  Future<NotificationSettings> getNotificationSettings(String userId) async {
    await Future.delayed(Duration(milliseconds: 300));
    return NotificationSettings(
      userId: userId,
      emailNotifications: true,
      pushNotifications: false,
      smsNotifications: false,
    );
  }

  Future<NotificationSettings> updateNotificationSettings(NotificationSettings settings) async {
    await Future.delayed(Duration(milliseconds: 500));
    return settings;
  }

  // Activity logging helper
  void _logActivity(String userId, String action, String description, {String? requestId}) {
    final user = _users.where((u) => u.id == userId).firstOrNull;
    final log = ActivityLog(
      id: (++_activityCounter).toString(),
      userId: userId,
      userName: user?.name ?? 'Unknown User',
      action: action,
      description: description,
      timestamp: DateTime.now(),
      ipAddress: '192.168.1.${100 + Random().nextInt(50)}',
      requestId: requestId,
    );
    _activityLogs.add(log);
  }

  // Export functionality
  Future<String> exportRequestsToExcel(List<Request> requests) async {
    await Future.delayed(Duration(milliseconds: 1000)); // Simulate export time
    return 'mock://exports/requests_${DateTime.now().millisecondsSinceEpoch}.xlsx';
  }

  Future<String> exportRequestsToPdf(List<Request> requests) async {
    await Future.delayed(Duration(milliseconds: 1000)); // Simulate export time
    return 'mock://exports/requests_${DateTime.now().millisecondsSinceEpoch}.pdf';
  }

  Future<String> exportRequestsToPDF(List<Request> requests) async {
    return exportRequestsToPdf(requests); // Alias for compatibility
  }

  Future<String> exportUsersToExcel(List<User> users) async {
    await Future.delayed(Duration(milliseconds: 1000)); // Simulate export time
    return 'mock://exports/users_${DateTime.now().millisecondsSinceEpoch}.xlsx';
  }

  Future<String> exportActivityLogsToExcel(List<ActivityLog> logs) async {
    await Future.delayed(Duration(milliseconds: 1000)); // Simulate export time
    return 'mock://exports/activity_logs_${DateTime.now().millisecondsSinceEpoch}.xlsx';
  }

  // Authentication and user validation
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
      
      _logActivity(user.id, 'login', 'User logged in');
      return _users[userIndex];
    } catch (e) {
      return null;
    }
  }

  // Additional user methods
  Future<List<User>> getAdminUsers() async {
    await Future.delayed(Duration(milliseconds: 300));
    return _users.where((user) => user.role == UserRole.admin).toList();
  }

  Future<RequestType> getRequestTypeById(String id) async {
    await Future.delayed(Duration(milliseconds: 300));
    return _requestTypes.firstWhere((type) => type.id == id);
  }

  Future<List<RequestComment>> getRequestComments(String requestId) async {
    await Future.delayed(Duration(milliseconds: 300));
    return getComments(requestId, includePrivate: true);
  }

  Future<List<Request>> getOverdueRequests() async {
    await Future.delayed(Duration(milliseconds: 300));
    return _requests.where((request) => request.isOverdue).toList();
  }

  Future<List<String>> getAllTags() async {
    await Future.delayed(Duration(milliseconds: 300));
    return getPopularTags(limit: 50);
  }

  Future<int> getUnreadNotificationCount(String userId) async {
    await Future.delayed(Duration(milliseconds: 200));
    final notifications = await getNotifications(userId);
    return notifications.where((n) => !n.isRead).length;
  }

  // User notifications with userId parameter
  Future<List<AppNotification>> getUserNotificationsAdmin([String? userId]) async { {
    await Future.delayed(Duration(milliseconds: 300));
    if (userId != null) {
      return getNotifications(userId);
    }
    return _appNotifications..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Reminder system
  Future<List<Request>> getRequestsNearingDueDate({int daysAhead = 3}) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    final cutoffDate = DateTime.now().add(Duration(days: daysAhead));
    return _requests.where((request) => 
      request.dueDate != null && 
      request.dueDate!.isBefore(cutoffDate) &&
      request.dueDate!.isAfter(DateTime.now()) &&
      !['Completed', 'Approved', 'Delivered', 'Rejected'].contains(request.status)
    ).toList();
  }

  // Auto-assignment rules (mock implementation)
  Future<void> processAutoAssignments() async {
    await Future.delayed(Duration(milliseconds: 300));
    
    final unassignedRequests = _requests.where((r) => 
      r.assignedAdminId == null && r.status == 'Pending').toList();
    
    for (final request in unassignedRequests) {
      // Simple auto-assignment based on category
      String? adminId;
      String? adminName;
      
      switch (request.category) {
        case 'IT':
          adminId = '1';
          adminName = 'John Admin';
          break;
        case 'HR':
          adminId = '3';
          adminName = 'Mike Manager';
          break;
        default:
          // Round-robin assignment for other categories
          final adminUsers = _users.where((u) => u.role == UserRole.admin).toList();
          if (adminUsers.isNotEmpty) {
            final selectedAdmin = adminUsers[Random().nextInt(adminUsers.length)];
            adminId = selectedAdmin.id;
            adminName = selectedAdmin.name;
          }
      }
      
      if (adminId != null && adminName != null) {
        await assignRequest(request.id, adminId, adminName);
      }
    }
  }

  // Bulk operations
  Future<void> bulkUpdateRequestStatus(List<String> requestIds, String newStatus, 
      String adminName) async {
    await Future.delayed(Duration(milliseconds: 800));
    
    for (final requestId in requestIds) {
      await updateRequestStatus(requestId, newStatus, adminName: adminName);
    }
  }

  Future<void> bulkAssignRequests(List<String> requestIds, String adminId, 
      String adminName) async {
    await Future.delayed(Duration(milliseconds: 800));
    
    for (final requestId in requestIds) {
      await assignRequest(requestId, adminId, adminName);
    }
  }

  Future<void> bulkDeleteRequests(List<String> requestIds) async {
    await Future.delayed(Duration(milliseconds: 500));
    
    for (final requestId in requestIds) {
      _requests.removeWhere((r) => r.id == requestId);
      _comments.removeWhere((c) => c.requestId == requestId);
      _attachments.removeWhere((a) => 
        _requests.any((r) => r.id == requestId && r.attachments.any((att) => att.id == a.id)));
    }
  }

  // System settings (mock)
  Future<Map<String, dynamic>> getSystemSettings() async {
    await Future.delayed(Duration(milliseconds: 300));
    return {
      'autoAssignmentEnabled': true,
      'emailNotificationsEnabled': true,
      'autoTransitionEnabled': true,
      'defaultDueDays': 7,
      'maxFileSize': 10485760, // 10MB
      'allowedFileTypes': ['pdf', 'doc', 'docx', 'jpg', 'png', 'gif'],
    };
  }

  Future<void> updateSystemSettings(Map<String, dynamic> settings) async {
    await Future.delayed(Duration(milliseconds: 500));
    // In a real app, this would persist the settings
  }

  // Advanced search with full-text capabilities
  Future<List<dynamic>> globalSearch(String query) async {
    await Future.delayed(Duration(milliseconds: 600));
    
    final results = <dynamic>[];
    
    // Search in requests
    final requestResults = await searchRequests(query);
    results.addAll(requestResults);
    
    // Search in users
    final userResults = _users.where((user) => 
      user.name.toLowerCase().contains(query.toLowerCase()) ||
      user.email.toLowerCase().contains(query.toLowerCase()) ||
      user.profileData.values.any((value) => 
        value.toString().toLowerCase().contains(query.toLowerCase()))).toList();
    results.addAll(userResults);
    
    // Search in comments
    final commentResults = _comments.where((comment) => 
      comment.content.toLowerCase().contains(query.toLowerCase())).toList();
    results.addAll(commentResults);
    
    return results;
  }
}
} 