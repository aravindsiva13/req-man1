import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'mock_api.dart';

class UserManagementScreen extends StatefulWidget {
  final MockApiService apiService;

  const UserManagementScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.history), text: 'Activity Logs'),
            Tab(icon: Icon(Icons.notifications), text: 'Notifications'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          UsersTab(apiService: widget.apiService),
          ActivityLogsTab(apiService: widget.apiService),
          NotificationsTab(apiService: widget.apiService),
        ],
      ),
    );
  }
}

class UsersTab extends StatefulWidget {
  final MockApiService apiService;

  const UsersTab({Key? key, required this.apiService}) : super(key: key);

  @override
  _UsersTabState createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  List<User> _users = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      final users = await widget.apiService.getUsers();
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: $e')),
      );
    }
  }

  List<User> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    return _users.where((user) =>
        user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        user.email.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showAddUserDialog(),
                icon: Icon(Icons.add),
                label: Text('Add User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredUsers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No users found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = _filteredUsers[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getUserStatusColor(user.status),
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(user.name, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.email),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: user.role == UserRole.admin ? Colors.purple : Colors.blue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    user.role.toString().split('.').last.toUpperCase(),
                                    style: TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getUserStatusColor(user.status),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    user.status.toString().split('.').last.toUpperCase(),
                                    style: TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) => _handleUserAction(value, user),
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'view', child: Text('View Details')),
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(value: 'permissions', child: Text('Permissions')),
                            PopupMenuItem(value: 'settings', child: Text('Notification Settings')),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Color _getUserStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return Colors.green;
      case UserStatus.inactive:
        return Colors.orange;
      case UserStatus.suspended:
        return Colors.red;
    }
  }

  void _handleUserAction(String action, User user) {
    switch (action) {
      case 'view':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailsScreen(user: user),
          ),
        );
        break;
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserFormScreen(
              apiService: widget.apiService,
              user: user,
            ),
          ),
        ).then((_) => _loadUsers());
        break;
      case 'permissions':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserPermissionsScreen(user: user),
          ),
        );
        break;
      case 'settings':
        _showNotificationSettingsDialog(user);
        break;
      case 'delete':
        _showDeleteUserDialog(user);
        break;
    }
  }

  void _showAddUserDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserFormScreen(apiService: widget.apiService),
      ),
    ).then((_) => _loadUsers());
  }

  void _showDeleteUserDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await widget.apiService.deleteUser(user.id);
                _loadUsers();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting user: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettingsDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => NotificationSettingsDialog(user: user),
    );
  }
}

class ActivityLogsTab extends StatefulWidget {
  final MockApiService apiService;

  const ActivityLogsTab({Key? key, required this.apiService}) : super(key: key);

  @override
  _ActivityLogsTabState createState() => _ActivityLogsTabState();
}

class _ActivityLogsTabState extends State<ActivityLogsTab> {
  List<ActivityLog> _logs = [];
  bool _loading = true;
  String? _selectedUserId;
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final logs = await widget.apiService.getActivityLogs(userId: _selectedUserId);
      final users = await widget.apiService.getUsers();
      setState(() {
        _logs = logs;
        _users = users;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading activity logs: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Filter by User',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedUserId,
                  onChanged: (value) {
                    setState(() => _selectedUserId = value);
                    _loadData();
                  },
                  items: [
                    DropdownMenuItem(value: null, child: Text('All Users')),
                    ..._users.map((user) => DropdownMenuItem(
                      value: user.id,
                      child: Text(user.name),
                    )),
                  ],
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _exportLogs,
                icon: Icon(Icons.download),
                label: Text('Export'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _logs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No activity logs found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          _getActivityIcon(log.action),
                          color: _getActivityColor(log.action),
                        ),
                        title: Text(log.description),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('User: ${log.userName}'),
                            Text('Time: ${_formatDateTime(log.timestamp)}'),
                            if (log.ipAddress != null)
                              Text('IP: ${log.ipAddress}'),
                          ],
                        ),
                        trailing: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getActivityColor(log.action),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            log.action.toUpperCase(),
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  IconData _getActivityIcon(String action) {
    switch (action.toLowerCase()) {
      case 'login':
        return Icons.login;
      case 'logout':
        return Icons.logout;
      case 'request_created':
        return Icons.add_circle;
      case 'user_updated':
        return Icons.edit;
      case 'user_created':
        return Icons.person_add;
      case 'profile_updated':
        return Icons.person;
      case 'status_changed':
        return Icons.update;
      case 'password_changed':
        return Icons.key;
      default:
        return Icons.info;
    }
  }

  Color _getActivityColor(String action) {
    switch (action.toLowerCase()) {
      case 'login':
        return Colors.green;
      case 'logout':
        return Colors.grey;
      case 'request_created':
        return Colors.blue;
      case 'user_updated':
        return Colors.orange;
      case 'user_created':
        return Colors.purple;
      case 'profile_updated':
        return Colors.indigo;
      case 'status_changed':
        return Colors.amber;
      case 'password_changed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _exportLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Activity Logs'),
        content: Text('Choose export format:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final url = await widget.apiService.exportActivityLogsToExcel(_logs);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logs exported successfully: $url')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Export failed: $e')),
                );
              }
            },
            child: Text('Excel'),
          ),
        ],
      ),
    );
  }
}

class NotificationsTab extends StatefulWidget {
  final MockApiService apiService;

  const NotificationsTab({Key? key, required this.apiService}) : super(key: key);

  @override
  _NotificationsTabState createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  List<UserNotification> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _loading = true);
    try {
      final notifications = await widget.apiService.getUserNotifications();
      setState(() {
        _notifications = notifications;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading notifications: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'System Notifications',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showSendNotificationDialog,
                  icon: Icon(Icons.send),
                  label: Text('Send Notification'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No notifications sent', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        SizedBox(height: 8),
                        Text('Send notifications to keep users informed', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 16),
                        child: ExpansionTile(
                          title: Text(notification.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(notification.message),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.person, size: 16, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text('${notification.targetUserIds.length} recipients'),
                                  SizedBox(width: 16),
                                  Icon(Icons.schedule, size: 16, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(_formatDateTime(notification.createdAt)),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) => _handleNotificationAction(value, notification),
                            itemBuilder: (context) => [
                              PopupMenuItem(value: 'resend', child: Text('Resend')),
                              PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Sent by: ${notification.senderName}'),
                                  SizedBox(height: 8),
                                  Text('Recipients: ${notification.targetUserIds.length} users'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _handleNotificationAction(String action, UserNotification notification) {
    switch (action) {
      case 'resend':
        _resendNotification(notification);
        break;
      case 'delete':
        _deleteNotification(notification);
        break;
    }
  }

  void _resendNotification(UserNotification notification) async {
    try {
      await widget.apiService.createUserNotification(UserNotification(
        id: '',
        title: '[RESENT] ${notification.title}',
        message: notification.message,
        createdAt: DateTime.now(),
        targetUserIds: notification.targetUserIds,
        senderName: notification.senderName,
      ));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification resent successfully')),
      );
      _loadNotifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resending notification: $e')),
      );
    }
  }

  void _deleteNotification(UserNotification notification) async {
    try {
      await widget.apiService.deleteUserNotification(notification.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification deleted successfully')),
      );
      _loadNotifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting notification: $e')),
      );
    }
  }

  void _showSendNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => SendNotificationDialog(
        apiService: widget.apiService,
        onNotificationSent: _loadNotifications,
      ),
    );
  }
}

class UserDetailsScreen extends StatefulWidget {
  final User user;

  const UserDetailsScreen({Key? key, required this.user}) : super(key: key);

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.name),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Profile'),
            Tab(text: 'Activity'),
            Tab(text: 'Permissions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(),
          _buildActivityTab(),
          _buildPermissionsTab(),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Text(
                widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : '?',
                style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 24),
          _buildInfoCard('Basic Information', [
            _buildInfoRow('Name', widget.user.name),
            _buildInfoRow('Email', widget.user.email),
            _buildInfoRow('Role', widget.user.role.toString().split('.').last.toUpperCase()),
            _buildInfoRow('Status', widget.user.status.toString().split('.').last.toUpperCase()),
            _buildInfoRow('Created', '${widget.user.createdAt.day}/${widget.user.createdAt.month}/${widget.user.createdAt.year}'),
            if (widget.user.lastLoginAt != null)
              _buildInfoRow('Last Login', '${widget.user.lastLoginAt!.day}/${widget.user.lastLoginAt!.month}/${widget.user.lastLoginAt!.year} ${widget.user.lastLoginAt!.hour.toString().padLeft(2, '0')}:${widget.user.lastLoginAt!.minute.toString().padLeft(2, '0')}'),
          ]),
          SizedBox(height: 16),
          if (widget.user.profileData.isNotEmpty)
            _buildInfoCard('Profile Data', 
              widget.user.profileData.entries.map((entry) => 
                _buildInfoRow(entry.key, entry.value.toString())).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    return Center(
      child: Text('User activity logs would be displayed here'),
    );
  }

  Widget _buildPermissionsTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Permissions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          if (widget.user.permissions.isEmpty)
            Text('No permissions assigned', style: TextStyle(color: Colors.grey))
          else
            ...widget.user.permissions.map((permission) => Card(
              child: ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text(permission),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class UserPermissionsScreen extends StatefulWidget {
  final User user;

  const UserPermissionsScreen({Key? key, required this.user}) : super(key: key);

  @override
  _UserPermissionsScreenState createState() => _UserPermissionsScreenState();
}

class _UserPermissionsScreenState extends State<UserPermissionsScreen> {
  List<Permission> _allPermissions = [];
  List<String> _userPermissions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _userPermissions = List.from(widget.user.permissions);
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    setState(() => _loading = true);
    try {
      final apiService = MockApiService();
      final permissions = await apiService.getAllPermissions();
      setState(() {
        _allPermissions = permissions;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading permissions: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text('User Permissions')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Permissions - ${widget.user.name}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _savePermissions,
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _allPermissions.length,
        itemBuilder: (context, index) {
          final permission = _allPermissions[index];
          final hasPermission = _userPermissions.contains(permission.id);
          
          return Card(
            child: CheckboxListTile(
              title: Text(permission.name),
              subtitle: Text(permission.description),
              value: hasPermission,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _userPermissions.add(permission.id);
                  } else {
                    _userPermissions.remove(permission.id);
                  }
                });
              },
            ),
          );
        },
      ),
    );
  }

  void _savePermissions() async {
    try {
      final apiService = MockApiService();
      final updatedUser = widget.user.copyWith(permissions: _userPermissions);
      await apiService.updateUser(updatedUser);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permissions updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating permissions: $e')),
      );
    }
  }
}

class NotificationSettingsDialog extends StatefulWidget {
  final User user;

  const NotificationSettingsDialog({Key? key, required this.user}) : super(key: key);

  @override
  _NotificationSettingsDialogState createState() => _NotificationSettingsDialogState();
}

class _NotificationSettingsDialogState extends State<NotificationSettingsDialog> {
  late NotificationSettings _settings;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _loading = true);
    try {
      final apiService = MockApiService();
      final settings = await apiService.getNotificationSettings(widget.user.id);
      setState(() {
        _settings = settings;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading settings: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Notification Settings - ${widget.user.name}'),
      content: _loading
          ? SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: Text('Email Notifications'),
                  subtitle: Text('Receive notifications via email'),
                  value: _settings.emailNotifications,
                  onChanged: (value) {
                    setState(() {
                      _settings = NotificationSettings(
                        userId: _settings.userId,
                        emailNotifications: value,
                        pushNotifications: _settings.pushNotifications,
                        smsNotifications: _settings.smsNotifications,
                      );
                    });
                  },
                ),
                SwitchListTile(
                  title: Text('Push Notifications'),
                  subtitle: Text('Receive push notifications'),
                  value: _settings.pushNotifications,
                  onChanged: (value) {
                    setState(() {
                      _settings = NotificationSettings(
                        userId: _settings.userId,
                        emailNotifications: _settings.emailNotifications,
                        pushNotifications: value,
                        smsNotifications: _settings.smsNotifications,
                      );
                    });
                  },
                ),
                SwitchListTile(
                  title: Text('SMS Notifications'),
                  subtitle: Text('Receive notifications via SMS'),
                  value: _settings.smsNotifications,
                  onChanged: (value) {
                    setState(() {
                      _settings = NotificationSettings(
                        userId: _settings.userId,
                        emailNotifications: _settings.emailNotifications,
                        pushNotifications: _settings.pushNotifications,
                        smsNotifications: value,
                      );
                    });
                  },
                ),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _saveSettings,
          child: Text('Save'),
        ),
      ],
    );
  }

  void _saveSettings() async {
    try {
      final apiService = MockApiService();
      await apiService.updateNotificationSettings(_settings);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Settings updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating settings: $e')),
      );
    }
  }
}

class SendNotificationDialog extends StatefulWidget {
  final MockApiService apiService;
  final VoidCallback onNotificationSent;

  const SendNotificationDialog({
    Key? key,
    required this.apiService,
    required this.onNotificationSent,
  }) : super(key: key);

  @override
  _SendNotificationDialogState createState() => _SendNotificationDialogState();
}

class _SendNotificationDialogState extends State<SendNotificationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  List<User> _users = [];
  List<String> _selectedUserIds = [];
  bool _selectAll = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await widget.apiService.getUsers();
      setState(() {
        _users = users;
        _selectedUserIds = users.map((u) => u.id).toList();
        _selectAll = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Send Notification'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text('Recipients', style: TextStyle(fontWeight: FontWeight.bold)),
              CheckboxListTile(
                title: Text('Select All'),
                value: _selectAll,
                onChanged: (value) {
                  setState(() {
                    _selectAll = value ?? false;
                    if (_selectAll) {
                      _selectedUserIds = _users.map((u) => u.id).toList();
                    } else {
                      _selectedUserIds.clear();
                    }
                  });
                },
              ),
              Container(
                height: 200,
                child: ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return CheckboxListTile(
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      value: _selectedUserIds.contains(user.id),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedUserIds.add(user.id);
                          } else {
                            _selectedUserIds.remove(user.id);
                          }
                          _selectAll = _selectedUserIds.length == _users.length;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _sendNotification,
          child: _loading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Send'),
        ),
      ],
    );
  }

  void _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one recipient')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final notification = UserNotification(
        id: '',
        title: _titleController.text,
        message: _messageController.text,
        createdAt: DateTime.now(),
        targetUserIds: _selectedUserIds,
        senderName: 'Admin',
      );

      await widget.apiService.createUserNotification(notification);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification sent successfully')),
      );
      
      widget.onNotificationSent();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending notification: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}

class UserFormScreen extends StatefulWidget {
  final MockApiService apiService;
  final User? user;

  const UserFormScreen({Key? key, required this.apiService, this.user}) : super(key: key);

  @override
  _UserFormScreenState createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  final _designationController = TextEditingController();
   final Map<String, dynamic> _profileData = {};
  
  UserRole _selectedRole = UserRole.user;
  UserStatus _selectedStatus = UserStatus.active;
  List<String> _selectedPermissions = [];
  List<Permission> _allPermissions = [];
  bool _loading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.user != null;
    _loadPermissions();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.user != null) {
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email;
      _selectedRole = widget.user!.role;
      _selectedStatus = widget.user!.status;
      _selectedPermissions = List.from(widget.user!.permissions);
      
      // Load profile data
      if (widget.user!.profileData.containsKey('phone')) {
        _phoneController.text = widget.user!.profileData['phone'];
      }
      if (widget.user!.profileData.containsKey('department')) {
        _departmentController.text = widget.user!.profileData['department'];
      }
      if (widget.user!.profileData.containsKey('designation')) {
        _designationController.text = widget.user!.profileData['designation'];
      }
    }
  }

  Future<void> _loadPermissions() async {
    try {
      final permissions = await widget.apiService.getAllPermissions();
      setState(() {
        _allPermissions = permissions;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading permissions: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit User' : 'Add User'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _loading ? null : _saveUser,
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Basic Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              if (!_isEditing)
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (!_isEditing && (value == null || value.length < 6)) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
              if (!_isEditing) SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<UserRole>(
                      decoration: InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedRole,
                      onChanged: (value) {
                        setState(() => _selectedRole = value!);
                      },
                      items: UserRole.values.map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role.toString().split('.').last.toUpperCase()),
                      )).toList(),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<UserStatus>(
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedStatus,
                      onChanged: (value) {
                        setState(() => _selectedStatus = value!);
                      },
                      items: UserStatus.values.map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.toString().split('.').last.toUpperCase()),
                      )).toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text('Profile Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _departmentController,
                decoration: InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _designationController,
                decoration: InputDecoration(
                  labelText: 'Designation',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),
              Text('Permissions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              if (_allPermissions.isEmpty)
                Text('Loading permissions...', style: TextStyle(color: Colors.grey))
              else
                for (final permission in _allPermissions) 
                  CheckboxListTile(
                    title: Text(permission.name),
                    subtitle: Text(permission.description),
                    value: _selectedPermissions.contains(permission.id),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedPermissions.add(permission.id);
                        } else {
                          _selectedPermissions.remove(permission.id);
                        }
                      });
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final profileData = {
        'phone': _phoneController.text,
        'department': _departmentController.text,
        'designation': _designationController.text,
      };

      if (_isEditing) {
        final updatedUser = widget.user!.copyWith(
          name: _nameController.text,
          email: _emailController.text,
          role: _selectedRole,
          status: _selectedStatus,
          profileData: profileData,
          permissions: _selectedPermissions,
        );
        await widget.apiService.updateUser(updatedUser);
      } else {
        final newUser = User(
  id: widget.user?.id ?? '',
  name: _nameController.text,
  email: _emailController.text,
  password: _passwordController.text,
  role: _selectedRole,
  status: _selectedStatus,
  createdAt: widget.user?.createdAt ?? DateTime.now(),
  profileData: _profileData,
  permissions: widget.user?.permissions ?? [],
  department: _profileData['department'] ?? 'General',
  active: true,
);
        await widget.apiService.createUser(newUser);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ${_isEditing ? 'updated' : 'created'} successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error ${_isEditing ? 'updating' : 'creating'} user: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
    super.dispose();
  }
}