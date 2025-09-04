import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../shared/shared_widgets.dart';
import '../auth/login_screen.dart';

class AdminDashboard extends StatefulWidget {
  final User currentUser;

  const AdminDashboard({Key? key, required this.currentUser}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    
    // Initialize admin data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().initializeAdminData(widget.currentUser.id);
    });
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
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          _buildNotificationIcon(),
          _buildProfileMenu(),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.assignment), text: 'Requests'),
            Tab(icon: Icon(Icons.category), text: 'Types'),
            Tab(icon: Icon(Icons.description), text: 'Templates'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
          ],
        ),
      ),
      body: Consumer<AdminViewModel>(
        builder: (context, adminViewModel, child) {
          if (adminViewModel.errorMessage != null) {
            return ErrorDisplay(
              message: adminViewModel.errorMessage!,
              onRetry: () {
                adminViewModel.clearError();
                adminViewModel.refreshAllData(widget.currentUser.id);
              },
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _OverviewTab(),
              _RequestsTab(),
              _RequestTypesTab(),
              _TemplatesTab(),
              _AnalyticsTab(),
              _UsersTab(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Consumer<AdminViewModel>(
      builder: (context, adminViewModel, child) {
        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () => _showNotifications(context, adminViewModel),
            ),
            if (adminViewModel.unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${adminViewModel.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildProfileMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'profile':
            _showProfile();
            break;
          case 'settings':
            _showSettings();
            break;
          case 'logout':
            _logout();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person),
              SizedBox(width: 8),
              Text('Profile'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings),
              SizedBox(width: 8),
              Text('Settings'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              child: Text(widget.currentUser.name.substring(0, 1).toUpperCase()),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context, AdminViewModel adminViewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => NotificationBottomSheet(
        notifications: adminViewModel.notifications,
        onMarkAsRead: (id) => adminViewModel.markNotificationAsRead(id),
      ),
    );
  }

  void _showProfile() {
    showDialog(
      context: context,
      builder: (context) => UserProfileDialog(user: widget.currentUser),
    );
  }

  void _showSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings coming soon!')),
    );
  }

  void _logout() {
    context.read<AuthViewModel>().logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }
}

// Tab Widgets
class _OverviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminViewModel>(
      builder: (context, adminViewModel, child) {
        if (adminViewModel.isLoadingStats) {
          return const LoadingIndicator();
        }

        final stats = adminViewModel.dashboardStats;
        if (stats == null) {
          return const Center(child: Text('No data available'));
        }

        return RefreshIndicator(
          onRefresh: () => adminViewModel.loadDashboardStats(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickStats(stats),
                const SizedBox(height: 24),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                _buildRequestsChart(stats),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(DashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Stats',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            StatCard(
              title: 'Total Requests',
              value: stats.totalRequests.toString(),
              icon: Icons.assignment,
              color: Colors.blue,
            ),
            StatCard(
              title: 'Pending',
              value: stats.pendingRequests.toString(),
              icon: Icons.pending,
              color: Colors.orange,
            ),
            StatCard(
              title: 'In Progress',
              value: stats.inProgressRequests.toString(),
              icon: Icons.work,
              color: Colors.purple,
            ),
            StatCard(
              title: 'Completed',
              value: stats.completedRequests.toString(),
              icon: Icons.check_circle,
              color: Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ActionButton(
              icon: Icons.add,
              label: 'New Request Type',
              color: Colors.green,
              onPressed: () => _showCreateRequestTypeDialog(context),
            ),
            ActionButton(
              icon: Icons.download,
              label: 'Export Data',
              color: Colors.blue,
              onPressed: () => _showExportDialog(context),
            ),
            ActionButton(
              icon: Icons.send,
              label: 'Send Notification',
              color: Colors.orange,
              onPressed: () => _showSendNotificationDialog(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRequestsChart(DashboardStats stats) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'By Status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...stats.requestsByStatus.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              entry.value.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'By Category',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...stats.requestsByCategory.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              entry.value.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCreateRequestTypeDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create request type feature coming soon!')),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ExportDialog(),
    );
  }

  void _showSendNotificationDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Send notification feature coming soon!')),
    );
  }
}

class _RequestsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminViewModel>(
      builder: (context, adminViewModel, child) {
        if (adminViewModel.isLoadingRequests) {
          return const LoadingIndicator();
        }

        return Column(
          children: [
            _buildFiltersSection(context, adminViewModel),
            Expanded(
              child: adminViewModel.filteredRequests.isEmpty
                  ? const EmptyState(
                      icon: Icons.assignment,
                      title: 'No requests found',
                      subtitle: 'Try adjusting your filters',
                    )
                  : RefreshIndicator(
                      onRefresh: () => adminViewModel.loadAllRequests(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: adminViewModel.filteredRequests.length,
                        itemBuilder: (context, index) {
                          final request = adminViewModel.filteredRequests[index];
                          return RequestCard(
                            request: request,
                            onTap: () => _showRequestDetails(context, request),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFiltersSection(BuildContext context, AdminViewModel adminViewModel) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search requests...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                adminViewModel.updateRequestFilters(searchQuery: value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    value: null,
                    onChanged: (value) {
                      adminViewModel.updateRequestFilters(status: value);
                    },
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                      DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<Priority>(
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    value: null,
                    onChanged: (value) {
                      adminViewModel.updateRequestFilters(priority: value);
                    },
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All')),
                      ...Priority.values.map((priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority.toString().split('.').last.toUpperCase()),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestDetails(BuildContext context, Request request) {
    showDialog(
      context: context,
      builder: (context) => RequestDetailsDialog(request: request),
    );
  }
}

class _RequestTypesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminViewModel>(
      builder: (context, adminViewModel, child) {
        if (adminViewModel.isLoadingTypes) {
          return const LoadingIndicator();
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Request Types',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateTypeDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Type'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: adminViewModel.requestTypes.isEmpty
                  ? const EmptyState(
                      icon: Icons.category,
                      title: 'No request types found',
                      subtitle: 'Create your first request type',
                    )
                  : RefreshIndicator(
                      onRefresh: () => adminViewModel.loadRequestTypes(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: adminViewModel.requestTypes.length,
                        itemBuilder: (context, index) {
                          final type = adminViewModel.requestTypes[index];
                          return RequestTypeCard(
                            requestType: type,
                            onEdit: () => _editRequestType(context, type),
                            onDelete: () => _deleteRequestType(context, type),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showCreateTypeDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create request type feature coming soon!')),
    );
  }

  void _editRequestType(BuildContext context, RequestType type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${type.name} feature coming soon!')),
    );
  }

  void _deleteRequestType(BuildContext context, RequestType type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Request Type'),
        content: Text('Are you sure you want to delete "${type.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delete feature coming soon!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _TemplatesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminViewModel>(
      builder: (context, adminViewModel, child) {
        if (adminViewModel.isLoadingTemplates) {
          return const LoadingIndicator();
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Templates',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateTemplateDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Template'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: adminViewModel.templates.isEmpty
                  ? const EmptyState(
                      icon: Icons.description,
                      title: 'No templates found',
                      subtitle: 'Create templates to speed up request creation',
                    )
                  : RefreshIndicator(
                      onRefresh: () => adminViewModel.loadTemplates(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: adminViewModel.templates.length,
                        itemBuilder: (context, index) {
                          final template = adminViewModel.templates[index];
                          return TemplateCard(
                            template: template,
                            onEdit: () => _editTemplate(context, template),
                            onDelete: () => _deleteTemplate(context, template, adminViewModel),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showCreateTemplateDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create template feature coming soon!')),
    );
  }

  void _editTemplate(BuildContext context, RequestTemplate template) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${template.name} feature coming soon!')),
    );
  }

  void _deleteTemplate(BuildContext context, RequestTemplate template, AdminViewModel adminViewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await adminViewModel.deleteTemplate(template.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminViewModel>(
      builder: (context, adminViewModel, child) {
        if (adminViewModel.isLoadingStats) {
          return const LoadingIndicator();
        }

        final stats = adminViewModel.dashboardStats;
        if (stats == null) {
          return const Center(child: Text('No analytics data available'));
        }

        return RefreshIndicator(
          onRefresh: () => adminViewModel.loadDashboardStats(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Analytics Dashboard',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildAnalyticsMetrics(stats),
                const SizedBox(height: 24),
                _buildTopPerformers(stats),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsMetrics(DashboardStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        MetricCard(
          title: 'Total Requests',
          value: stats.totalRequests.toString(),
          icon: Icons.assignment,
          color: Colors.blue,
        ),
        MetricCard(
          title: 'Overdue',
          value: stats.overdueRequests.toString(),
          icon: Icons.warning,
          color: Colors.red,
        ),
        MetricCard(
          title: 'Avg. Resolution',
          value: '2.3 days',
          icon: Icons.timer,
          color: Colors.green,
        ),
        MetricCard(
          title: 'Satisfaction',
          value: '4.2/5',
          icon: Icons.star,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildTopPerformers(DashboardStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Performers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (stats.topPerformers.isEmpty)
              const Text('No performance data available')
            else
              ...stats.topPerformers.map((performer) => ListTile(
                leading: CircleAvatar(
                  child: Text(performer.completedRequests.toString()),
                ),
                title: Text(performer.adminName),
                trailing: Text('${performer.completedRequests} requests'),
              )),
          ],
        ),
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminViewModel>(
      builder: (context, adminViewModel, child) {
        if (adminViewModel.isLoadingUsers) {
          return const LoadingIndicator();
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Users',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateUserDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add User'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: adminViewModel.users.isEmpty
                  ? const EmptyState(
                      icon: Icons.people,
                      title: 'No users found',
                      subtitle: 'Add users to get started',
                    )
                  : RefreshIndicator(
                      onRefresh: () => adminViewModel.loadUsers(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: adminViewModel.users.length,
                        itemBuilder: (context, index) {
                          final user = adminViewModel.users[index];
                          return UserCard(
                            user: user,
                            onEdit: () => _editUser(context, user),
                            onDelete: () => _deleteUser(context, user, adminViewModel),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showCreateUserDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create user feature coming soon!')),
    );
  }

  void _editUser(BuildContext context, User user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${user.name} feature coming soon!')),
    );
  }

  void _deleteUser(BuildContext context, User user, AdminViewModel adminViewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete "${user.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await adminViewModel.deleteUser(user.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}