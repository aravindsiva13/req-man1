import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'mock_api.dart';

class UserDashboard extends StatefulWidget {
  final User currentUser;
  final MockApiService apiService;

  UserDashboard({required this.currentUser, required this.apiService});

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MockApiService _apiService = MockApiService();
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
  try {
    final notifications = await _apiService.getNotifications(widget.currentUser.id);
    final unreadCount = await _apiService.getUnreadNotificationCount(widget.currentUser.id);
    setState(() {
      _notifications = notifications;
      _unreadCount = unreadCount;
    });
  } catch (e) {
    // Handle error
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Dashboard'),
        actions: [
          // Notifications bell
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () => _showNotifications(),
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '$_unreadCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // User profile menu
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                _showProfile();
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              PopupMenuItem(
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
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16,
                    child: Text(widget.currentUser.name.substring(0, 1).toUpperCase()),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(icon: Icon(Icons.add_circle_outline), text: 'New Request'),
            Tab(icon: Icon(Icons.track_changes), text: 'My Requests'),
            Tab(icon: Icon(Icons.description), text: 'Templates'),
            Tab(icon: Icon(Icons.search), text: 'Search'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // NewRequestTab(apiService: _apiService, currentUser: widget.currentUser),
          // MyRequestsTab(apiService: _apiService, currentUser: widget.currentUser),
          // TemplatesTab(apiService: _apiService, currentUser: widget.currentUser),
          // SearchTab(apiService: _apiService, currentUser: widget.currentUser),


          Container(child: Center(child: Text('My Requests - Coming Soon'))),
Container(child: Center(child: Text('Templates - Coming Soon'))),
Container(child: Center(child: Text('Search - Coming Soon'))),
        ],
      ),
    );
  }

  void _showNotifications() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Notifications'),
      content: Container(
        width: double.maxFinite,
        height: 300,
        child: _notifications.isEmpty
            ? Center(child: Text('No notifications'))
            : ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return ListTile(
                    title: Text(notification.title),
                    subtitle: Text(notification.message),
                    trailing: notification.isRead 
                        ? null 
                        : Icon(Icons.circle, color: Colors.blue, size: 12),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    ),
  );
}

void _showProfile() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('User Profile'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Name: ${widget.currentUser.name}'),
          SizedBox(height: 8),
          Text('Email: ${widget.currentUser.email}'),
          SizedBox(height: 8),
          Text('Role: ${widget.currentUser.role.toString().split('.').last}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    ),
  );
}

  void _logout() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }
}

// Enhanced New Request Tab with Templates and Attachments
class NewRequestTab extends StatefulWidget {
  final MockApiService apiService;
  final User currentUser;

  NewRequestTab({required this.apiService, required this.currentUser});

  @override
  _NewRequestTabState createState() => _NewRequestTabState();
}

class _NewRequestTabState extends State<NewRequestTab> {
  List<RequestType> _requestTypes = [];
  List<RequestTemplate> _templates = [];
  RequestType? _selectedRequestType;
  RequestTemplate? _selectedTemplate;
  bool _loading = true;
  String _searchQuery = '';
  String? _categoryFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final types = await widget.apiService.getRequestTypes();
      final templates = await widget.apiService.getTemplates();
      setState(() {
        _requestTypes = types;
        _templates = templates;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  List<RequestType> get _filteredRequestTypes {
    return _requestTypes.where((type) {
      final matchesSearch = type.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                           type.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _categoryFilter == null || type.category == _categoryFilter;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<RequestTemplate> get _availableTemplates {
    if (_selectedRequestType == null) return [];
    return _templates.where((t) => t.typeId == _selectedRequestType!.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_requestTypes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No request types available', style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Contact admin to create request types', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_selectedRequestType == null) {
      return _buildRequestTypeSelection();
    }

    return DynamicRequestForm(
      requestType: _selectedRequestType!,
      selectedTemplate: _selectedTemplate,
      apiService: widget.apiService,
      currentUser: widget.currentUser,
      onSubmitted: () {
        setState(() {
          _selectedRequestType = null;
          _selectedTemplate = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request submitted successfully!')),
        );
      },
      onCancel: () {
        setState(() {
          _selectedRequestType = null;
          _selectedTemplate = null;
        });
      },
    );
  }

  Widget _buildRequestTypeSelection() {
    final categories = _requestTypes.map((t) => t.category).toSet().toList();

    return Column(
      children: [
        // Search and filter bar
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search request types...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  value: _categoryFilter,
                  items: [
                    DropdownMenuItem(value: null, child: Text('All Categories')),
                    ...categories.map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    )),
                  ],
                  onChanged: (value) => setState(() => _categoryFilter = value),
                ),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16),
            children: [
              Text(
                'Select Request Type',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 16),
              ..._filteredRequestTypes.map((type) => Card(
                margin: EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(type.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(type.description),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Chip(
                            label: Text(type.category, style: TextStyle(fontSize: 12)),
                            backgroundColor: Colors.blue.shade100,
                          ),
                          SizedBox(width: 8),
                          // if (type.autoAssignment)
                            Chip(
                              label: Text('Auto-assigned', style: TextStyle(fontSize: 12)),
                              backgroundColor: Colors.green.shade100,
                            ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    setState(() => _selectedRequestType = type);
                    if (_availableTemplates.isNotEmpty) {
                      _showTemplateSelection();
                    }
                  },
                ),
              )).toList(),
            ],
          ),
        ),
      ],
    );
  }

  void _showTemplateSelection() {
    if (_availableTemplates.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose Template (Optional)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Start from scratch'),
                leading: Icon(Icons.add),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedTemplate = null);
                },
              ),
              Divider(),
              ..._availableTemplates.map((template) => ListTile(
                title: Text(template.name),
                subtitle: Text(template.description),
                leading: Icon(Icons.description),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedTemplate = template);
                },
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

// Enhanced Dynamic Request Form with Attachments and Priority
class DynamicRequestForm extends StatefulWidget {
  final RequestType requestType;
  final RequestTemplate? selectedTemplate;
  final MockApiService apiService;
  final User currentUser;
  final VoidCallback onSubmitted;
  final VoidCallback onCancel;

  DynamicRequestForm({
    required this.requestType,
    this.selectedTemplate,
    required this.apiService,
    required this.currentUser,
    required this.onSubmitted,
    required this.onCancel,
  });

  @override
  _DynamicRequestFormState createState() => _DynamicRequestFormState();
}

class _DynamicRequestFormState extends State<DynamicRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _fieldValues = {};
  final Map<String, TextEditingController> _controllers = {};
  List<FileAttachment> _attachments = [];
  List<String> _tags = [];
  Priority _priority = Priority.medium;
  DateTime? _dueDate;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers for text and number fields
    for (final field in widget.requestType.fields) {
      if (field.type == FieldType.text || field.type == FieldType.number) {
        _controllers[field.id] = TextEditingController();
      }
    }
    
    // Pre-fill from template if selected
    if (widget.selectedTemplate != null) {
      _fieldValues.addAll(widget.selectedTemplate!.predefinedValues);
      // Update controllers with template values
      widget.selectedTemplate!.predefinedValues.forEach((key, value) {
        if (_controllers.containsKey(key)) {
          _controllers[key]!.text = value.toString();
        }
      });
    }
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.requestType.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: widget.onCancel,
        ),
        actions: [
          TextButton(
            onPressed: _submitting ? null : _submitRequest,
            child: _submitting
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text('SUBMIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Request Information Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Request Information', style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 8),
                    Text(widget.requestType.description),
                    if (widget.selectedTemplate != null) ...[
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.description, color: Colors.blue, size: 16),
                            SizedBox(width: 4),
                            Text('Using template: ${widget.selectedTemplate!.name}',
                                style: TextStyle(color: Colors.blue, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Priority and Due Date Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Request Settings', style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<Priority>(
                            decoration: InputDecoration(
                              labelText: 'Priority',
                              border: OutlineInputBorder(),
                            ),
                            value: _priority,
                            items: Priority.values.map((priority) => DropdownMenuItem(
                              value: priority,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.flag,
                                    color: _getPriorityColor(priority),
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(priority.toString().split('.').last.toUpperCase()),
                                ],
                              ),
                            )).toList(),
                            onChanged: (value) => setState(() => _priority = value!),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Due Date (Optional)',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            readOnly: true,
                            controller: TextEditingController(
                              text: _dueDate != null ? _formatDate(_dueDate!) : '',
                            ),
                            onTap: _selectDueDate,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Form Fields Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fill in the details', style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 16),
                    ...widget.requestType.fields.map((field) =>
                        _buildDynamicField(field)).toList(),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Tags Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tags (Optional)', style: Theme.of(context).textTheme.titleMedium),
                        TextButton.icon(
                          onPressed: _addTag,
                          icon: Icon(Icons.add),
                          label: Text('Add Tag'),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _tags.map((tag) => Chip(
                        label: Text(tag),
                        deleteIcon: Icon(Icons.close, size: 16),
                        onDeleted: () => setState(() => _tags.remove(tag)),
                      )).toList(),
                    ),
                    if (_tags.isEmpty)
                      Text('No tags added', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Attachments Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Attachments (Optional)', style: Theme.of(context).textTheme.titleMedium),
                        TextButton.icon(
                          onPressed: _addAttachment,
                          icon: Icon(Icons.attach_file),
                          label: Text('Add File'),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    if (_attachments.isNotEmpty)
                      ..._attachments.map((attachment) => ListTile(
                        leading: Icon(_getFileIcon(attachment.type)),
                        title: Text(attachment.name),
                        subtitle: Text('${_formatFileSize(attachment.size)} • ${_formatDate(attachment.uploadedAt)}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => setState(() => _attachments.remove(attachment)),
                        ),
                      )).toList()
                    else
                      Text('No files attached', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _submitting
                    ? Row(
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
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send),
                          SizedBox(width: 8),
                          Text('Submit Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicField(CustomField field) {
    Widget fieldWidget = Container();

    switch (field.type) {
      case FieldType.text:
        fieldWidget = TextFormField(
          controller: _controllers[field.id],
          decoration: InputDecoration(
            labelText: field.name + (field.required ? ' *' : ''),
            border: OutlineInputBorder(),
          ),
          validator: field.required
              ? (value) => value?.isEmpty == true ? '${field.name} is required' : null
              : null,
          onChanged: (value) => _fieldValues[field.id] = value,
        );
        break;

      case FieldType.number:
        fieldWidget = TextFormField(
          controller: _controllers[field.id],
          decoration: InputDecoration(
            labelText: field.name + (field.required ? ' *' : ''),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: field.required
              ? (value) {
                  if (value?.isEmpty == true) return '${field.name} is required';
                  if (int.tryParse(value!) == null) return 'Please enter a valid number';
                  return null;
                }
              : (value) {
                  if (value?.isNotEmpty == true && int.tryParse(value!) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
          onChanged: (value) {
            final intValue = int.tryParse(value);
            _fieldValues[field.id] = intValue ?? value;
          },
        );
        break;

      case FieldType.dropdown:
        fieldWidget = DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: field.name + (field.required ? ' *' : ''),
            border: OutlineInputBorder(),
          ),
          value: _fieldValues[field.id],
          items: field.options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option),
            );
          }).toList(),
          validator: field.required
              ? (value) => value == null ? 'Please select ${field.name}' : null
              : null,
          onChanged: (value) => setState(() => _fieldValues[field.id] = value),
        );
        break;

      case FieldType.date:
        fieldWidget = TextFormField(
          decoration: InputDecoration(
            labelText: field.name + (field.required ? ' *' : ''),
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          readOnly: true,
          validator: field.required
              ? (value) => value?.isEmpty == true ? 'Please select ${field.name}' : null
              : null,
          onTap: () => _selectDate(field),
          controller: TextEditingController(
            text: _fieldValues[field.id] != null
                ? _formatDate(_fieldValues[field.id])
                : '',
          ),
        );
        break;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: fieldWidget,
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

  IconData _getFileIcon(String fileType) {
    if (fileType.startsWith('image/')) return Icons.image;
    if (fileType.contains('pdf')) return Icons.picture_as_pdf;
    if (fileType.contains('word')) return Icons.description;
    if (fileType.contains('excel')) return Icons.table_chart;
    return Icons.insert_drive_file;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _selectDate(CustomField field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _fieldValues[field.id] = picked;
      });
    }
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _addTag() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text('Add Tag'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter tag name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty && !_tags.contains(controller.text)) {
                  setState(() => _tags.add(controller.text));
                }
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addAttachment() {
    // In a real app, this would open file picker
    // For demo purposes, we'll create a mock attachment
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Attachment'),
        content: Text('In a real app, this would open a file picker to select documents, images, or other files.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Create a mock attachment for demo
              final mockAttachment = FileAttachment(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: 'sample_document_${_attachments.length + 1}.pdf',
                type: 'application/pdf',
                size: 1024 * 256, // 256KB
                url: 'mock://files/sample.pdf',
                uploadedAt: DateTime.now(),
                uploadedBy: widget.currentUser.id,
              );
              setState(() => _attachments.add(mockAttachment));
              Navigator.pop(context);
            },
            child: Text('Add Mock File'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if all required fields are filled
    for (final field in widget.requestType.fields) {
      if (field.required && (_fieldValues[field.id] == null || 
          (_fieldValues[field.id] is String && _fieldValues[field.id].isEmpty))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill in all required fields')),
        );
        return;
      }
    }

    setState(() => _submitting = true);
    try {
      final request = Request(
        id: '',
        typeId: widget.requestType.id,
        typeName: widget.requestType.name,
        category: widget.requestType.category,
        fieldValues: Map<String, dynamic>.from(_fieldValues),
        status: widget.requestType.statusWorkflow.first.name,
        priority: _priority,
        submittedBy: widget.currentUser.id,
        submittedAt: DateTime.now(),
        dueDate: _dueDate,
        tags: _tags,
        attachments: _attachments,
      );

      await widget.apiService.createRequest(request);
      widget.onSubmitted();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting request: $e')),
      );
    } finally {
      setState(() => _submitting = false);
    }
  }
}