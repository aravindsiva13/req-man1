// Core Enums
enum Priority { low, medium, high, urgent }
enum UserRole { user, admin }
enum UserStatus { active, inactive, suspended }
enum NotificationType { info, warning, error, success }
enum FieldType { text, number, email, date, dropdown, checkbox, textarea }

// User Model
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
    required this.department,
    required this.active,
  });

  User copyWith({
    String? name,
    String? email,
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
      password: this.password,
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
}

// Request Type Model
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
}

// Custom Field Model
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
}

// Status Workflow Model
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
}

// Request Model
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
    String? adminComments,
    String? assignedAdminId,
    String? assignedAdminName,
    List<StatusChangeHistory>? statusHistory,
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
      dueDate: this.dueDate,
      adminComments: adminComments ?? this.adminComments,
      assignedAdminId: assignedAdminId ?? this.assignedAdminId,
      assignedAdminName: assignedAdminName ?? this.assignedAdminName,
      tags: this.tags,
      statusHistory: statusHistory ?? this.statusHistory,
      attachments: this.attachments,
    );
  }
}

// Status Change History Model
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
}

// File Attachment Model
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
}

// Request Template Model
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
}

// App Notification Model
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
}

// Request Comment Model
class RequestComment {
  final String id;
  final String requestId;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final bool isPrivate;

  RequestComment({
    required this.id,
    required this.requestId,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.isPrivate = false,
  });
}

// Dashboard Stats Model
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