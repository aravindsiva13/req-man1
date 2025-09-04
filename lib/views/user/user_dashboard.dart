import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../shared/shared_widgets.dart';
import '../auth/login_screen.dart';

class UserDashboard extends StatefulWidget {
  final User currentUser;

  const UserDashboard({Key? key, required this.currentUser}) : super(key: key);

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Initialize user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserViewModel>().initializeUserData(widget.currentUser.id);
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
        title: const Text('User Dashboard'),
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
            Tab(icon: Icon(Icons.add_circle_outline), text: 'New Request'),
            Tab(icon: Icon(Icons.track_changes), text: 'My Requests'),
            Tab(icon: Icon(Icons.description), text: 'Templates'),
            Tab(icon: Icon(Icons.search), text: 'Search'),
          ],
        ),
      ),
      body: Consumer<UserViewModel>(
        builder: (context, userViewModel, child) {
          if (userViewModel.errorMessage != null) {
            return ErrorDisplay(
              message: userViewModel.errorMessage!,
              onRetry: () {
                userViewModel.clearError();
                userViewModel.refreshUserData(widget.currentUser.id);
              },
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _NewRequestTab(currentUser: widget.currentUser),
              _MyRequestsTab(currentUser: widget.currentUser),
              _TemplatesTab(),
              _SearchTab(currentUser: widget.currentUser),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Consumer<UserViewModel>(
      builder: (context, userViewModel, child) {
        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () => _showNotifications(context, userViewModel),
            ),
            if (userViewModel.unreadCount > 0)
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
                    '${userViewModel.unreadCount}',
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

  void _showNotifications(BuildContext context, UserViewModel userViewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => NotificationBottomSheet(
        notifications: userViewModel.notifications,
        onMarkAsRead: (id) => userViewModel.markNotificationAsRead(id),
      ),
    );
  }

  void _showProfile() {
    showDialog(
      context: context,
      builder: (context) => UserProfileDialog(user: widget.currentUser),
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
class _NewRequestTab extends StatelessWidget {
  final User currentUser;

  const _NewRequestTab({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, userViewModel, child) {
        if (userViewModel.selectedRequestType == null) {
          return _RequestTypeSelection();
        }

        return _DynamicRequestForm(currentUser: currentUser);
      },
    );
  }
}

class _RequestTypeSelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, userViewModel, child) {
        if (userViewModel.isLoadingTypes) {
          return const LoadingIndicator();
        }

        if (userViewModel.requestTypes.isEmpty) {
          return const EmptyState(
            icon: Icons.category,
            title: 'No request types available',
            subtitle: 'Contact admin to create request types',
          );
        }

        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Request Type',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: userViewModel.requestTypes.length,
                itemBuilder: (context, index) {
                  final type = userViewModel.requestTypes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.category),
                      ),
                      title: Text(type.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(type.description),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              type.category,
                              style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        userViewModel.selectRequestType(type);
                        if (userViewModel.availableTemplates.isNotEmpty) {
                          _showTemplateSelection(context, userViewModel);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showTemplateSelection(BuildContext context, UserViewModel userViewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Template (Optional)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Start from scratch'),
                leading: const Icon(Icons.add),
                onTap: () {
                  Navigator.pop(context);
                  userViewModel.selectTemplate(null);
                },
              ),
              const Divider(),
              ...userViewModel.availableTemplates.map((template) => ListTile(
                title: Text(template.name),
                subtitle: Text(template.description),
                leading: const Icon(Icons.description),
                onTap: () {
                  Navigator.pop(context);
                  userViewModel.selectTemplate(template);
                },
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _DynamicRequestForm extends StatefulWidget {
  final User currentUser;

  const _DynamicRequestForm({required this.currentUser});

  @override
  __DynamicRequestFormState createState() => __DynamicRequestFormState();
}

class __DynamicRequestFormState extends State<_DynamicRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final userViewModel = context.read<UserViewModel>();
    if (userViewModel.selectedRequestType != null) {
      for (final field in userViewModel.selectedRequestType!.fields) {
        if (field.type == FieldType.text || 
            field.type == FieldType.email || 
            field.type == FieldType.textarea) {
          _controllers[field.id] = TextEditingController();
          
          // Pre-fill from template if available
          final value = userViewModel.getFormFieldValue(field.id);
          if (value != null) {
            _controllers[field.id]!.text = value.toString();
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, userViewModel, child) {
        final requestType = userViewModel.selectedRequestType!;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(requestType.name),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => userViewModel.cancelForm(),
            ),
            actions: [
              TextButton(
                onPressed: userViewModel.isSubmittingRequest ? null : _submitRequest,
                child: userViewModel.isSubmittingRequest
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('SUBMIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Request Information Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Request Information', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(requestType.description),
                        if (userViewModel.selectedTemplate != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.description, color: Colors.blue, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Using template: ${userViewModel.selectedTemplate!.name}',
                                  style: TextStyle(color: Colors.blue, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Priority and Due Date Card
                _buildPriorityAndDueDateCard(userViewModel),
                
                const SizedBox(height: 16),
                
                // Form Fields Card
                _buildFormFieldsCard(requestType, userViewModel),
                
                const SizedBox(height: 16),
                
                // Tags Card
                _buildTagsCard(userViewModel),
                
                const SizedBox(height: 24),
                
                // Submit Button
                _buildSubmitButton(userViewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriorityAndDueDateCard(UserViewModel userViewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Request Settings', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<Priority>(
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    value: userViewModel.formPriority,
                    items: Priority.values.map((priority) => DropdownMenuItem(
                      value: priority,
                      child: Row(
                        children: [
                          Icon(
                            Icons.flag,
                            color: _getPriorityColor(priority),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(priority.toString().split('.').last.toUpperCase()),
                        ],
                      ),
                    )).toList(),
                    onChanged: (value) => userViewModel.updateFormPriority(value!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Due Date (Optional)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: userViewModel.formDueDate != null 
                          ? _formatDate(userViewModel.formDueDate!) 
                          : '',
                    ),
                    onTap: () => _selectDueDate(userViewModel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFieldsCard(RequestType requestType, UserViewModel userViewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fill in the details', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ...requestType.fields.map((field) => _buildDynamicField(field, userViewModel)),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicField(CustomField field, UserViewModel userViewModel) {
    Widget fieldWidget;

    switch (field.type) {
      case FieldType.text:
      case FieldType.email:
        fieldWidget = TextFormField(
          controller: _controllers[field.id],
          decoration: InputDecoration(
            labelText: field.name + (field.required ? ' *' : ''),
            border: const OutlineInputBorder(),
          ),
          keyboardType: field.type == FieldType.email ? TextInputType.emailAddress : TextInputType.text,
          validator: field.required
              ? (value) => value?.isEmpty == true ? '${field.name} is required' : null
              : null,
          onChanged: (value) => userViewModel.updateFormField(field.id, value),
        );
        break;

      case FieldType.textarea:
        fieldWidget = TextFormField(
          controller: _controllers[field.id],
          decoration: InputDecoration(
            labelText: field.name + (field.required ? ' *' : ''),
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: field.required
              ? (value) => value?.isEmpty == true ? '${field.name} is required' : null
              : null,
          onChanged: (value) => userViewModel.updateFormField(field.id, value),
        );
        break;

      case FieldType.number:
        fieldWidget = TextFormField(
          controller: _controllers[field.id],
          decoration: InputDecoration(
            labelText: field.name + (field.required ? ' *' : ''),
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: field.required
              ? (value) {
                  if (value?.isEmpty == true) return '${field.name} is required';
                  if (double.tryParse(value!) == null) return 'Please enter a valid number';
                  return null;
                }
              : null,
          onChanged: (value) {
            final numValue = double.tryParse(value);
            userViewModel.updateFormField(field.id, numValue ?? value);
          },
        );
        break;

      case FieldType.dropdown:
        fieldWidget = DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: field.name + (field.required ? ' *' : ''),
            border: const OutlineInputBorder(),
          ),
          value: userViewModel.getFormFieldValue(field.id),
          items: field.options.map((option) => DropdownMenuItem(
            value: option,
            child: Text(option),
          )).toList(),
          validator: field.required
              ? (value) => value == null ? 'Please select ${field.name}' : null
              : null,
          onChanged: (value) => userViewModel.updateFormField(field.id, value),
        );
        break;

      case FieldType.checkbox:
        fieldWidget = CheckboxListTile(
          title: Text(field.name + (field.required ? ' *' : '')),
          value: userViewModel.getFormFieldValue(field.id) == true,
          onChanged: (value) => userViewModel.updateFormField(field.id, value),
          controlAffinity: ListTileControlAffinity.leading,
        );
        break;

      case FieldType.date:
        fieldWidget = TextFormField(
          decoration: InputDecoration(
            labelText: field.name + (field.required ? ' *' : ''),
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          readOnly: true,
          validator: field.required
              ? (value) => value?.isEmpty == true ? 'Please select ${field.name}' : null
              : null,
          onTap: () => _selectFieldDate(field, userViewModel),
          controller: TextEditingController(
            text: userViewModel.getFormFieldValue(field.id) != null
                ? _formatDate(userViewModel.getFormFieldValue(field.id))
                : '',
          ),
        );
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: fieldWidget,
    );
  }

  Widget _buildTagsCard(UserViewModel userViewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tags (Optional)', style: Theme.of(context).textTheme.titleMedium),
                TextButton.icon(
                  onPressed: () => _addTag(userViewModel),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Tag'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (userViewModel.formTags.isNotEmpty)
              Wrap(
                spacing: 8,
                children: userViewModel.formTags.map((tag) => Chip(
                  label: Text(tag),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => userViewModel.removeFormTag(tag),
                )).toList(),
              )
            else
              const Text('No tags added', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(UserViewModel userViewModel) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: userViewModel.isSubmittingRequest ? null : _submitRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        child: userViewModel.isSubmittingRequest
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Text('Submitting...'),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send),
                  SizedBox(width: 8),
                  Text('Submit Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
      case Priority.urgent:
        return Colors.purple;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDueDate(UserViewModel userViewModel) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      userViewModel.updateFormDueDate(picked);
    }
  }

  Future<void> _selectFieldDate(CustomField field, UserViewModel userViewModel) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      userViewModel.updateFormField(field.id, picked);
    }
  }

  void _addTag(UserViewModel userViewModel) {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Tag'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter tag name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  userViewModel.addFormTag(controller.text);
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final userViewModel = context.read<UserViewModel>();
    
    final success = await userViewModel.submitRequest(widget.currentUser.id);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request submitted successfully!')),
      );
    }
  }
}

class _MyRequestsTab extends StatelessWidget {
  final User currentUser;

  const _MyRequestsTab({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, userViewModel, child) {
        if (userViewModel.isLoadingRequests) {
          return const LoadingIndicator();
        }

        return Column(
          children: [
            _buildFiltersSection(userViewModel),
            Expanded(
              child: userViewModel.filteredRequests.isEmpty
                  ? const EmptyState(
                      icon: Icons.assignment,
                      title: 'No requests found',
                      subtitle: 'Create your first request to get started',
                    )
                  : RefreshIndicator(
                      onRefresh: () => userViewModel.loadMyRequests(currentUser.id),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: userViewModel.filteredRequests.length,
                        itemBuilder: (context, index) {
                          final request = userViewModel.filteredRequests[index];
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

  Widget _buildFiltersSection(UserViewModel userViewModel) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search my requests...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                userViewModel.updateRequestFilters(searchQuery: value);
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
                      userViewModel.updateRequestFilters(status: value);
                    },
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All')),
                      ...userViewModel.getAvailableStatuses().map(
                        (status) => DropdownMenuItem(value: status, child: Text(status)),
                      ),
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
                      userViewModel.updateRequestFilters(priority: value);
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

class _TemplatesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, userViewModel, child) {
        if (userViewModel.isLoadingTemplates) {
          return const LoadingIndicator();
        }

        if (userViewModel.templates.isEmpty) {
          return const EmptyState(
            icon: Icons.description,
            title: 'No templates available',
            subtitle: 'Templates will help you create requests faster',
          );
        }

        return RefreshIndicator(
          onRefresh: () => userViewModel.loadTemplates(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: userViewModel.templates.length,
            itemBuilder: (context, index) {
              final template = userViewModel.templates[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.description, color: Colors.white),
                  ),
                  title: Text(template.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(template.description),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _useTemplate(context, template, userViewModel),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _useTemplate(BuildContext context, RequestTemplate template, UserViewModel userViewModel) async {
    // Load the request type for this template
    final requestType = await userViewModel.getRequestTypeById(template.typeId);
    
    if (requestType != null) {
      userViewModel.selectRequestType(requestType);
      userViewModel.selectTemplate(template);
      
      // Switch to New Request tab
      DefaultTabController.of(context).animateTo(0);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Using template: ${template.name}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading template')),
      );
    }
  }
}

class _SearchTab extends StatefulWidget {
  final User currentUser;

  const _SearchTab({required this.currentUser});

  @override
  __SearchTabState createState() => __SearchTabState();
}

class __SearchTabState extends State<_SearchTab> {
  final _searchController = TextEditingController();
  List<Request> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search your requests...',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults.clear();
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) => _performSearch(value),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isSearching
                ? const LoadingIndicator()
                : _searchResults.isEmpty
                    ? _buildEmptySearchState()
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final request = _searchResults[index];
                          return RequestCard(
                            request: request,
                            onTap: () => _showRequestDetails(context, request),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return const EmptyState(
      icon: Icons.search,
      title: 'Search your requests',
      subtitle: 'Enter keywords to find specific requests',
    );
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final userViewModel = context.read<UserViewModel>();
      final results = await userViewModel.searchRequests(query, widget.currentUser.id);
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $e')),
      );
    }
  }

  void _showRequestDetails(BuildContext context, Request request) {
    showDialog(
      context: context,
      builder: (context) => RequestDetailsDialog(request: request),
    );
  }
}