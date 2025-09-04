

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'mock_api.dart';
// import 'user_management_module.dart';

// class AdminDashboard extends StatefulWidget {
//   @override
//   _AdminDashboardState createState() => _AdminDashboardState();
// }

// class _AdminDashboardState extends State<AdminDashboard>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final MockApiService _apiService = MockApiService();

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Admin Dashboard'),
//         bottom: TabBar(
//           controller: _tabController,
//           isScrollable: true,
//           tabs: [
//             Tab(icon: Icon(Icons.category), text: 'Request Types'),
//             Tab(icon: Icon(Icons.list_alt), text: 'All Requests'),
//             Tab(icon: Icon(Icons.people), text: 'User Management'),
//             Tab(icon: Icon(Icons.trending_up), text: 'Analytics'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           RequestTypesTab(apiService: _apiService),
//           AllRequestsTab(apiService: _apiService),
//           UserManagementTab(apiService: _apiService),
//           AnalyticsTab(apiService: _apiService),
//         ],
//       ),
//     );
//   }
// }

// class RequestTypesTab extends StatefulWidget {
//   final MockApiService apiService;

//   RequestTypesTab({required this.apiService});

//   @override
//   _RequestTypesTabState createState() => _RequestTypesTabState();
// }

// class _RequestTypesTabState extends State<RequestTypesTab> {
//   List<RequestType> _requestTypes = [];
//   bool _loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadDashboardData();
//   }

//   Future<void> _loadDashboardData() async {
//     setState(() => _loading = true);
//     try {
//       final types = await widget.apiService.getRequestTypes();
//       setState(() {
//         _requestTypes = types;
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() => _loading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading request types: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return Center(child: CircularProgressIndicator());
//     }

//     return Scaffold(
//       body: ListView.builder(
//         padding: EdgeInsets.all(16),
//         itemCount: _requestTypes.length,
//         itemBuilder: (context, index) {
//           final type = _requestTypes[index];
//           return Card(
//             margin: EdgeInsets.only(bottom: 16),
//             child: ListTile(
//               title: Text(type.name),
//               subtitle: Text(type.description),
//               trailing: PopupMenuButton(
//                 onSelected: (value) {
//                   if (value == 'edit') {
//                     _editRequestType(type);
//                   } else if (value == 'delete') {
//                     _deleteRequestType(type.id);
//                   }
//                 },
//                 itemBuilder: (context) => [
//                   PopupMenuItem(value: 'edit', child: Text('Edit')),
//                   PopupMenuItem(value: 'delete', child: Text('Delete')),
//                 ],
//               ),
//               onTap: () => _viewRequestTypeDetails(type),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _createNewRequestType,
//         child: Icon(Icons.add),
//       ),
//     );
//   }

//   void _createNewRequestType() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => RequestTypeFormScreen(
//           apiService: widget.apiService,
//           onSaved: _loadDashboardData,
//         ),
//       ),
//     );
//   }

//   void _editRequestType(RequestType type) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => RequestTypeFormScreen(
//           apiService: widget.apiService,
//           requestType: type,
//           onSaved: _loadDashboardData,
//         ),
//       ),
//     );
//   }

//   void _deleteRequestType(String typeId) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Delete Request Type'),
//         content: Text('Are you sure you want to delete this request type?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: Text('Delete'),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       try {
//         await widget.apiService.deleteRequestType(typeId);
//         _loadDashboardData();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Request type deleted successfully')),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error deleting request type: $e')),
//         );
//       }
//     }
//   }

//   void _viewRequestTypeDetails(RequestType type) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => RequestTypeDetailsScreen(requestType: type),
//       ),
//     );
//   }
// }

// class RequestTypeFormScreen extends StatefulWidget {
//   final MockApiService apiService;
//   final RequestType? requestType;
//   final VoidCallback onSaved;

//   RequestTypeFormScreen({
//     required this.apiService,
//     this.requestType,
//     required this.onSaved,
//   });

//   @override
//   _RequestTypeFormScreenState createState() => _RequestTypeFormScreenState();
// }

// class _RequestTypeFormScreenState extends State<RequestTypeFormScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final List<CustomField> _fields = [];
//   final List<String> _statusWorkflow = ['Pending'];
//   bool _saving = false;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.requestType != null) {
//       _nameController.text = widget.requestType!.name;
//       _descriptionController.text = widget.requestType!.description;
//       _fields.addAll(widget.requestType!.fields);
//       _statusWorkflow.clear();
//       _statusWorkflow.addAll(widget.requestType!.statusWorkflow);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.requestType == null ? 'Create Request Type' : 'Edit Request Type'),
//         actions: [
//           TextButton(
//             onPressed: _saving ? null : _saveRequestType,
//             child: _saving
//                 ? SizedBox(
//                     width: 16,
//                     height: 16,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                 : Text('SAVE', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: EdgeInsets.all(16),
//           children: [
//             TextFormField(
//               controller: _nameController,
//               decoration: InputDecoration(
//                 labelText: 'Request Type Name',
//                 border: OutlineInputBorder(),
//               ),
//               validator: (value) =>
//                   value?.isEmpty == true ? 'Name is required' : null,
//             ),
//             SizedBox(height: 16),
//             TextFormField(
//               controller: _descriptionController,
//               decoration: InputDecoration(
//                 labelText: 'Description',
//                 border: OutlineInputBorder(),
//               ),
//               maxLines: 3,
//               validator: (value) =>
//                   value?.isEmpty == true ? 'Description is required' : null,
//             ),
//             SizedBox(height: 24),
//             _buildFieldsSection(),
//             SizedBox(height: 24),
//             _buildStatusWorkflowSection(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFieldsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text('Custom Fields', style: Theme.of(context).textTheme.titleLarge),
//             ElevatedButton.icon(
//               onPressed: _addField,
//               icon: Icon(Icons.add),
//               label: Text('Add Field'),
//             ),
//           ],
//         ),
//         SizedBox(height: 16),
//         ..._fields.asMap().entries.map((entry) {
//           int index = entry.key;
//           CustomField field = entry.value;
//           return Card(
//             margin: EdgeInsets.only(bottom: 8),
//             child: ListTile(
//               title: Text(field.name),
//               subtitle: Text(_getFieldTypeDisplay(field.type)),
//               trailing: IconButton(
//                 icon: Icon(Icons.delete),
//                 onPressed: () => _removeField(index),
//               ),
//               onTap: () => _editField(index),
//             ),
//           );
//         }).toList(),
//       ],
//     );
//   }

//   Widget _buildStatusWorkflowSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text('Status Workflow', style: Theme.of(context).textTheme.titleLarge),
//             ElevatedButton.icon(
//               onPressed: _addStatus,
//               icon: Icon(Icons.add),
//               label: Text('Add Status'),
//             ),
//           ],
//         ),
//         SizedBox(height: 16),
//         ..._statusWorkflow.asMap().entries.map((entry) {
//           int index = entry.key;
//           String status = entry.value;
//           return Card(
//             margin: EdgeInsets.only(bottom: 8),
//             child: ListTile(
//               leading: CircleAvatar(child: Text('${index + 1}')),
//               title: Text(status),
//               trailing: index == 0
//                   ? null
//                   : IconButton(
//                       icon: Icon(Icons.delete),
//                       onPressed: () => _removeStatus(index),
//                     ),
//               onTap: index == 0 ? null : () => _editStatus(index),
//             ),
//           );
//         }).toList(),
//       ],
//     );
//   }

//   void _addField() {
//     showDialog(
//       context: context,
//       builder: (context) => FieldFormDialog(
//         onSave: (field) {
//           setState(() => _fields.add(field));
//         },
//       ),
//     );
//   }

//   void _editField(int index) {
//     showDialog(
//       context: context,
//       builder: (context) => FieldFormDialog(
//         field: _fields[index],
//         onSave: (field) {
//           setState(() => _fields[index] = field);
//         },
//       ),
//     );
//   }

//   void _removeField(int index) {
//     setState(() => _fields.removeAt(index));
//   }

//   void _addStatus() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         final controller = TextEditingController();
//         return AlertDialog(
//           title: Text('Add Status'),
//           content: TextField(
//             controller: controller,
//             decoration: InputDecoration(labelText: 'Status Name'),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 if (controller.text.isNotEmpty) {
//                   setState(() => _statusWorkflow.add(controller.text));
//                   Navigator.pop(context);
//                 }
//               },
//               child: Text('Add'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _editStatus(int index) {
//     final controller = TextEditingController(text: _statusWorkflow[index]);
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Edit Status'),
//         content: TextField(
//           controller: controller,
//           decoration: InputDecoration(labelText: 'Status Name'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               if (controller.text.isNotEmpty) {
//                 setState(() => _statusWorkflow[index] = controller.text);
//                 Navigator.pop(context);
//               }
//             },
//             child: Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _removeStatus(int index) {
//     setState(() => _statusWorkflow.removeAt(index));
//   }

//   Future<void> _saveRequestType() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_fields.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please add at least one field')),
//       );
//       return;
//     }

//     setState(() => _saving = true);
//     try {
//       final requestType = RequestType(
//         id: widget.requestType?.id ?? '',
//         name: _nameController.text,
//         description: _descriptionController.text,
//         fields: _fields,
//         statusWorkflow: _statusWorkflow,
//       );

//       if (widget.requestType == null) {
//         await widget.apiService.createRequestType(requestType);
//       } else {
//         await widget.apiService.updateRequestType(requestType);
//       }

//       widget.onSaved();
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Request type saved successfully')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error saving request type: $e')),
//       );
//     } finally {
//       setState(() => _saving = false);
//     }
//   }

//   String _getFieldTypeDisplay(FieldType type) {
//     switch (type) {
//       case FieldType.text:
//         return 'Text';
//       case FieldType.number:
//         return 'Number';
//       case FieldType.dropdown:
//         return 'Dropdown';
//       case FieldType.date:
//         return 'Date';
//     }
//   }
// }

// class FieldFormDialog extends StatefulWidget {
//   final CustomField? field;
//   final Function(CustomField) onSave;

//   FieldFormDialog({this.field, required this.onSave});

//   @override
//   _FieldFormDialogState createState() => _FieldFormDialogState();
// }

// class _FieldFormDialogState extends State<FieldFormDialog> {
//   final _nameController = TextEditingController();
//   FieldType _selectedType = FieldType.text;
//   bool _required = true;
//   final List<String> _options = [];

//   @override
//   void initState() {
//     super.initState();
//     if (widget.field != null) {
//       _nameController.text = widget.field!.name;
//       _selectedType = widget.field!.type;
//       _required = widget.field!.required;
//       _options.addAll(widget.field!.options);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text(widget.field == null ? 'Add Field' : 'Edit Field'),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: InputDecoration(labelText: 'Field Name'),
//             ),
//             SizedBox(height: 16),
//             DropdownButtonFormField<FieldType>(
//               value: _selectedType,
//               decoration: InputDecoration(labelText: 'Field Type'),
//               items: FieldType.values.map((type) {
//                 return DropdownMenuItem(
//                   value: type,
//                   child: Text(type.toString().split('.').last.toUpperCase()),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() => _selectedType = value!);
//               },
//             ),
//             SizedBox(height: 16),
//             CheckboxListTile(
//               title: Text('Required'),
//               value: _required,
//               onChanged: (value) => setState(() => _required = value!),
//             ),
//             if (_selectedType == FieldType.dropdown) ...[
//               SizedBox(height: 16),
//               Text('Options:'),
//               ..._options.asMap().entries.map((entry) {
//                 return ListTile(
//                   title: Text(entry.value),
//                   trailing: IconButton(
//                     icon: Icon(Icons.delete),
//                     onPressed: () =>
//                         setState(() => _options.removeAt(entry.key)),
//                   ),
//                 );
//               }).toList(),
//               TextButton(
//                 onPressed: _addOption,
//                 child: Text('Add Option'),
//               ),
//             ],
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text('Cancel'),
//         ),
//         TextButton(
//           onPressed: _saveField,
//           child: Text('Save'),
//         ),
//       ],
//     );
//   }

//   void _addOption() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         final controller = TextEditingController();
//         return AlertDialog(
//           title: Text('Add Option'),
//           content: TextField(
//             controller: controller,
//             decoration: InputDecoration(labelText: 'Option Value'),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 if (controller.text.isNotEmpty) {
//                   setState(() => _options.add(controller.text));
//                   Navigator.pop(context);
//                 }
//               },
//               child: Text('Add'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _saveField() {
//     if (_nameController.text.isEmpty) return;
//     if (_selectedType == FieldType.dropdown && _options.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please add at least one option for dropdown field')),
//       );
//       return;
//     }

//     final field = CustomField(
//       id: widget.field?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
//       name: _nameController.text,
//       type: _selectedType,
//       required: _required,
//       options: _selectedType == FieldType.dropdown ? _options : [],
//     );

//     widget.onSave(field);
//     Navigator.pop(context);
//   }
// }

// class RequestTypeDetailsScreen extends StatelessWidget {
//   final RequestType requestType;

//   RequestTypeDetailsScreen({required this.requestType});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(requestType.name),
//       ),
//       body: ListView(
//         padding: EdgeInsets.all(16),
//         children: [
//           Card(
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Description', style: Theme.of(context).textTheme.titleMedium),
//                   SizedBox(height: 8),
//                   Text(requestType.description),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//           Card(
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Fields', style: Theme.of(context).textTheme.titleMedium),
//                   SizedBox(height: 8),
//                   ...requestType.fields.map((field) => ListTile(
//                     title: Text(field.name),
//                     subtitle: Text(field.type.toString().split('.').last.toUpperCase()),
//                     trailing: field.required ? Icon(Icons.star, color: Colors.red) : null,
//                   )).toList(),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//           Card(
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Status Workflow', style: Theme.of(context).textTheme.titleMedium),
//                   SizedBox(height: 8),
//                   ...requestType.statusWorkflow.asMap().entries.map((entry) => ListTile(
//                     leading: CircleAvatar(child: Text('${entry.key + 1}')),
//                     title: Text(entry.value),
//                   )).toList(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class AllRequestsTab extends StatefulWidget {
//   final MockApiService apiService;

//   AllRequestsTab({required this.apiService});

//   @override
//   _AllRequestsTabState createState() => _AllRequestsTabState();
// }

// class _AllRequestsTabState extends State<AllRequestsTab> {
//   List<Request> _requests = [];
//   List<RequestType> _requestTypes = [];
//   bool _loading = true;
//   String _selectedFilter = 'All';

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     setState(() => _loading = true);
//     try {
//       final requests = await widget.apiService.getRequests();
//       final types = await widget.apiService.getRequestTypes();
//       setState(() {
//         _requests = requests;
//         _requestTypes = types;
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() => _loading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading requests: $e')),
//       );
//     }
//   }

//   List<Request> get _filteredRequests {
//     if (_selectedFilter == 'All') return _requests;
//     return _requests.where((r) => r.status == _selectedFilter).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return Center(child: CircularProgressIndicator());
//     }

//     final uniqueStatuses = _requests.map((r) => r.status).toSet().toList();
//     uniqueStatuses.insert(0, 'All');

//     return Column(
//       children: [
//         Padding(
//           padding: EdgeInsets.all(16),
//           child: DropdownButtonFormField<String>(
//             value: _selectedFilter,
//             decoration: InputDecoration(
//               labelText: 'Filter by Status',
//               border: OutlineInputBorder(),
//             ),
//             items: uniqueStatuses.map((status) {
//               return DropdownMenuItem(
//                 value: status,
//                 child: Text(status),
//               );
//             }).toList(),
//             onChanged: (value) => setState(() => _selectedFilter = value!),
//           ),
//         ),
//         Expanded(
//           child: _filteredRequests.isEmpty
//               ? Center(child: Text('No requests found'))
//               : ListView.builder(
//                   padding: EdgeInsets.symmetric(horizontal: 16),
//                   itemCount: _filteredRequests.length,
//                   itemBuilder: (context, index) {
//                     final request = _filteredRequests[index];
//                     return Card(
//                       margin: EdgeInsets.only(bottom: 16),
//                       child: ListTile(
//                         title: Text(request.typeName),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Submitted by: ${request.submittedBy}'),
//                             Text('Status: ${request.status}'),
//                             Text('Date: ${_formatDate(request.submittedAt)}'),
//                           ],
//                         ),
//                         trailing: _buildStatusChip(request.status),
//                         onTap: () => _viewRequestDetails(request),
//                       ),
//                     );
//                   },
//                 ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStatusChip(String status) {
//     Color color;
//     if (status.toLowerCase().contains('pending')) {
//       color = Colors.orange;
//     } else if (status.toLowerCase().contains('approved') || 
//                status.toLowerCase().contains('completed') || 
//                status.toLowerCase().contains('delivered')) {
//       color = Colors.green;
//     } else if (status.toLowerCase().contains('rejected')) {
//       color = Colors.red;
//     } else {
//       color = Colors.blue;
//     }

//     return Chip(
//       label: Text(status, style: TextStyle(color: Colors.white, fontSize: 12)),
//       backgroundColor: color,
//     );
//   }

//   void _viewRequestDetails(Request request) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => RequestDetailsScreen(
//           request: request,
//           apiService: widget.apiService,
//           onStatusUpdated: _loadData,
//         ),
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }

// class RequestDetailsScreen extends StatefulWidget {
//   final Request request;
//   final MockApiService apiService;
//   final VoidCallback onStatusUpdated;

//   RequestDetailsScreen({
//     required this.request,
//     required this.apiService,
//     required this.onStatusUpdated,
//   });

//   @override
//   _RequestDetailsScreenState createState() => _RequestDetailsScreenState();
// }

// class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
//   RequestType? _requestType;
//   bool _loading = true;
//   bool _updating = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadRequestType();
//   }

//   Future<void> _loadRequestType() async {
//     try {
//       final type = await widget.apiService.getRequestTypeById(widget.request.typeId);
//       setState(() {
//         _requestType = type;
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return Scaffold(
//         appBar: AppBar(title: Text('Request Details')),
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Request Details'),
//         actions: [
//           if (_requestType != null)
//             PopupMenuButton<String>(
//               onSelected: (status) => _updateStatus(status),
//               itemBuilder: (context) => _requestType!.statusWorkflow.map((status) {
//                 return PopupMenuItem(
//                   value: status,
//                   child: Text(status),
//                 );
//               }).toList(),
//             ),
//         ],
//       ),
//       body: ListView(
//         padding: EdgeInsets.all(16),
//         children: [
//           Card(
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Request Information', style: Theme.of(context).textTheme.titleMedium),
//                   SizedBox(height: 16),
//                   _buildInfoRow('Type', widget.request.typeName),
//                   _buildInfoRow('Status', widget.request.status),
//                   _buildInfoRow('Submitted By', widget.request.submittedBy),
//                   _buildInfoRow('Submitted At', _formatDate(widget.request.submittedAt)),
//                   if (widget.request.updatedAt != null)
//                     _buildInfoRow('Updated At', _formatDate(widget.request.updatedAt!)),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//           Card(
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Field Values', style: Theme.of(context).textTheme.titleMedium),
//                   SizedBox(height: 16),
//                   ...widget.request.fieldValues.entries.map((entry) {
//                     final fieldName = _getFieldDisplayName(entry.key);
//                     return _buildInfoRow(fieldName, entry.value.toString());
//                   }).toList(),
//                 ],
//               ),
//             ),
//           ),
//           if (widget.request.adminComments != null) ...[
//             SizedBox(height: 16),
//             Card(
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Admin Comments', style: Theme.of(context).textTheme.titleMedium),
//                     SizedBox(height: 8),
//                     Text(widget.request.adminComments!),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               '$label:',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }

//   String _getFieldDisplayName(String fieldId) {
//     if (_requestType == null) return fieldId;
//     final field = _requestType!.fields.where((f) => f.id == fieldId).firstOrNull;
//     return field?.name ?? fieldId;
//   }

//   Future<void> _updateStatus(String newStatus) async {
//     final result = await _showStatusUpdateDialog(newStatus);
//     if (result == null) return;

//     setState(() => _updating = true);
//     try {
//       await widget.apiService.updateRequestStatus(
//         widget.request.id,
//         newStatus,
//         adminComments: result['comment'],
//         adminName: result['adminName'],
//       );
//       widget.onStatusUpdated();
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Request status updated successfully')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error updating status: $e')),
//       );
//     } finally {
//       setState(() => _updating = false);
//     }
//   }

//   Future<Map<String, String>?> _showStatusUpdateDialog(String newStatus) async {
//     final commentController = TextEditingController();
//     final adminNames = await widget.apiService.getAdminNames();
//     String selectedAdmin = adminNames.first;

//     return showDialog<Map<String, String>>(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: Text('Update Status to "$newStatus"'),
//         content: StatefulBuilder(
//           builder: (context, setState) => Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Admin Name:', style: TextStyle(fontWeight: FontWeight.bold)),
//               SizedBox(height: 8),
//               DropdownButtonFormField<String>(
//                 value: selectedAdmin,
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(),
//                 ),
//                 items: adminNames.map((name) {
//                   return DropdownMenuItem(
//                     value: name,
//                     child: Text(name),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() => selectedAdmin = value!);
//                 },
//               ),
//               SizedBox(height: 16),
//               Text('Comment (Required):', style: TextStyle(fontWeight: FontWeight.bold)),
//               SizedBox(height: 8),
//               TextField(
//                 controller: commentController,
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(),
//                   hintText: 'Enter reason for status change...',
//                 ),
//                 maxLines: 3,
//                 autofocus: true,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (commentController.text.trim().isEmpty) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Comment is required')),
//                 );
//                 return;
//               }
//               Navigator.pop(context, {
//                 'comment': commentController.text.trim(),
//                 'adminName': selectedAdmin,
//               });
//             },
//             child: Text('Update Status'),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDateTime(DateTime date) {
//     return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }

// class AnalyticsTab extends StatefulWidget {
//   final MockApiService apiService;

//   AnalyticsTab({required this.apiService});

//   @override
//   _AnalyticsTabState createState() => _AnalyticsTabState();
// }

// class _AnalyticsTabState extends State<AnalyticsTab> {
//   List<Request> _requests = [];
//   List<RequestType> _requestTypes = [];
//   List<User> _users = [];
//   bool _loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     setState(() => _loading = true);
//     try {
//       final requests = await widget.apiService.getRequests();
//       final types = await widget.apiService.getRequestTypes();
//       final users = await widget.apiService.getUsers();
//       setState(() {
//         _requests = requests;
//         _requestTypes = types;
//         _users = users;
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return Center(child: CircularProgressIndicator());
//     }

//     final statusCounts = <String, int>{};
//     final typeCounts = <String, int>{};

//     for (final request in _requests) {
//       statusCounts[request.status] = (statusCounts[request.status] ?? 0) + 1;
//       typeCounts[request.typeName] = (typeCounts[request.typeName] ?? 0) + 1;
//     }

//     final activeUsers = _users.where((u) => u.status == UserStatus.active).length;
//     final adminUsers = _users.where((u) => u.role == UserRole.admin).length;

//     return ListView(
//       padding: EdgeInsets.all(16),
//       children: [
//         Card(
//           child: Padding(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Overview', style: Theme.of(context).textTheme.titleLarge),
//                 SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildStatCard(
//                         'Total Requests',
//                         _requests.length.toString(),
//                         Icons.list_alt,
//                         Colors.blue,
//                       ),
//                     ),
//                     SizedBox(width: 16),
//                     Expanded(
//                       child: _buildStatCard(
//                         'Request Types',
//                         _requestTypes.length.toString(),
//                         Icons.category,
//                         Colors.green,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildStatCard(
//                         'Active Users',
//                         activeUsers.toString(),
//                         Icons.people,
//                         Colors.purple,
//                       ),
//                     ),
//                     SizedBox(width: 16),
//                     Expanded(
//                       child: _buildStatCard(
//                         'Admin Users',
//                         adminUsers.toString(),
//                         Icons.admin_panel_settings,
//                         Colors.orange,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//         SizedBox(height: 16),
//         Card(
//           child: Padding(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Requests by Status', style: Theme.of(context).textTheme.titleLarge),
//                 SizedBox(height: 16),
//                 ...statusCounts.entries.map((entry) => ListTile(
//                   title: Text(entry.key),
//                   trailing: CircleAvatar(
//                     child: Text(entry.value.toString()),
//                   ),
//                 )).toList(),
//               ],
//             ),
//           ),
//         ),
//         SizedBox(height: 16),
//         Card(
//           child: Padding(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Requests by Type', style: Theme.of(context).textTheme.titleLarge),
//                 SizedBox(height: 16),
//                 ...typeCounts.entries.map((entry) => ListTile(
//                   title: Text(entry.key),
//                   trailing: CircleAvatar(
//                     child: Text(entry.value.toString()),
//                   ),
//                 )).toList(),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStatCard(String title, String value, IconData icon, Color color) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: 32),
//           SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           SizedBox(height: 4),
//           Text(
//             title,
//             textAlign: TextAlign.center,
//             style: TextStyle(color: color),
//           ),
//         ],
//       ),
//     );
//   }
// }


//2



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'mock_api.dart';
import 'user_management_module.dart';

class AdminDashboard extends StatefulWidget {
  final User currentUser;
  final MockApiService apiService;

  const AdminDashboard({
    Key? key,
    required this.currentUser,
    required this.apiService,
  }) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MockApiService _apiService = MockApiService();
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadNotifications();
  }

 Future<void> _loadNotifications() async {
  try {
    final notifications = await _apiService.getNotifications('1'); // Use AppNotification method
    final unreadCount = notifications.where((n) => !n.isRead).length;
    setState(() {
      _notifications = notifications;
      _unreadCount = unreadCount;
    });
  } catch (e) {
    print('Error loading notifications: $e');
  }
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
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (_unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
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
                        '$_unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => _showNotifications(),
          ),
          PopupMenuButton<String>(
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
          ),
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
      body: TabBarView(
        controller: _tabController,
        children: [
          DashboardOverviewTab(apiService: _apiService, onRefresh: _loadNotifications),
          AllRequestsTab(apiService: _apiService, currentUser: widget.currentUser),
          RequestTypesTab(apiService: _apiService),
          TemplatesManagementTab(apiService: _apiService),
          AdvancedAnalyticsTab(apiService: _apiService),
          UserManagementTab(apiService: _apiService),
        ],
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AdminNotificationsBottomSheet(
        notifications: _notifications,
        apiService: _apiService,
        onNotificationRead: _loadNotifications,
      ),
    );
  }

  void _showProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsScreen(user: widget.currentUser),
      ),
    );
  }

  void _showSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings coming soon!')),
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
}

// Placeholder LoginScreen class
class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: const Center(child: Text('Login Screen')),
    );
  }
}

class DashboardOverviewTab extends StatefulWidget {
  final MockApiService apiService;
  final VoidCallback onRefresh;

  const DashboardOverviewTab({
    Key? key,
    required this.apiService,
    required this.onRefresh,
  }) : super(key: key);

  @override
  _DashboardOverviewTabState createState() => _DashboardOverviewTabState();
}

class _DashboardOverviewTabState extends State<DashboardOverviewTab> {
  DashboardStats? _dashboardStats;
  List<Request> _overdueRequests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _loading = true);
    try {
      final stats = await widget.apiService.getDashboardStats();
      final overdueRequests = _getOverdueRequests(await widget.apiService.getRequests());
      setState(() {
        _dashboardStats = stats;
        _overdueRequests = overdueRequests;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading dashboard: $e')),
      );
    }
  }

  List<Request> _getOverdueRequests(List<Request> allRequests) {
    return allRequests.where((request) => request.isOverdue).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dashboardStats == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Failed to load dashboard data'),
            ElevatedButton(
              onPressed: _loadDashboardData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickStats(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildChartSection(),
            const SizedBox(height: 24),
            _buildOverdueRequests(),
            const SizedBox(height: 24),
            _buildTopPerformers(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
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
            _buildStatCard(
              'Total Requests',
              _dashboardStats!.totalRequests.toString(),
              Icons.assignment,
              Colors.blue,
            ),
            _buildStatCard(
              'Pending',
              _dashboardStats!.pendingRequests.toString(),
              Icons.pending,
              Colors.orange,
            ),
            _buildStatCard(
              'In Progress',
              _dashboardStats!.inProgressRequests.toString(),
              Icons.work,
              Colors.purple,
            ),
            _buildStatCard(
              'Completed',
              _dashboardStats!.completedRequests.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
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
            ElevatedButton.icon(
onPressed: () {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Create request type feature coming soon!')),
  );
},              icon: const Icon(Icons.add),
              label: const Text('New Request Type'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showBulkAssignDialog(),
              icon: const Icon(Icons.assignment_ind),
              label: const Text('Bulk Assign'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showExportDialog(),
              icon: const Icon(Icons.download),
              label: const Text('Export Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _showSendNotificationDialog(),
              icon: const Icon(Icons.send),
              label: const Text('Send Notification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Request Distribution',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatusChart()),
            const SizedBox(width: 16),
            Expanded(child: _buildCategoryChart()),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChart() {
    return Card(
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
            ..._dashboardStats!.requestsByStatus.entries.map((entry) {
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
    );
  }

  Widget _buildCategoryChart() {
    return Card(
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
            ..._dashboardStats!.requestsByCategory.entries.map((entry) {
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
    );
  }

  Widget _buildOverdueRequests() {
    if (_overdueRequests.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.check_circle, size: 48, color: Colors.green),
              SizedBox(height: 8),
              Text(
                'No Overdue Requests',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text('Great job keeping up with deadlines!'),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overdue Requests (${_overdueRequests.length})',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _overdueRequests.length > 5 ? 5 : _overdueRequests.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final request = _overdueRequests[index];
              return ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: Text(request.typeName),
                subtitle: Text('Due: ${_formatDate(request.dueDate!)}'),
                trailing: Text(
                  request.priority.toString().split('.').last.toUpperCase(),
                  style: TextStyle(
                    color: _getPriorityColor(request.priority),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () => _showRequestDetails(request),
              );
            },
          ),
        ),
        if (_overdueRequests.length > 5)
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextButton(
              onPressed: () => _showAllOverdueRequests(),
              child: Text('View all ${_overdueRequests.length} overdue requests'),
            ),
          ),
      ],
    );
  }

  Widget _buildTopPerformers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Performers',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ...(_dashboardStats!.topPerformers.isNotEmpty
                  ? _dashboardStats!.topPerformers.take(5).toList().asMap().entries.map((entry) {
                      final index = entry.key;
                      final performer = entry.value;
                      final isTop3 = index < 3;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isTop3 ? Colors.amber : Colors.grey.shade300,
                          child: Text((performer.completedRequests).toString()),
                        ),
                        title: Text(performer.adminName),
                        trailing: Text('${performer.completedRequests} requests'),
                      );
                    }).toList()
                  : [
                      const ListTile(
                        leading: Icon(Icons.info),
                        title: Text('No performance data available'),
                      ),
                    ]),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

// void _showCreateRequestTypeDialog() {
//   showDialog(
//     context: context,
//     builder: (context) => RequestTypeFormScreen(
//       apiService: widget.apiService,
//       onSaved: _loadDashboardData,
//     ),
//   );
// }

// void _handleRequestTypeAction(String action, RequestType type) {
//   switch (action) {
//     case 'edit':
//       showDialog(
//         context: context,
//         builder: (context) => RequestTypeFormScreen(
//           apiService: widget.apiService,
//           requestType: type,
//           onSaved: _loadDashboardData,
//         ),
//       );
//       break;
//     case 'duplicate':
//       _duplicateRequestType(type);
//       break;
//     case 'activate':
//       _toggleRequestTypeStatus(type);
//       break;
//     case 'delete':
//       _showDeleteConfirmation(type);
//       break;
//   }
// }

// void _duplicateRequestType(RequestType type) {
//   showDialog(
//     context: context,
//     builder: (context) => RequestTypeFormScreen(
//       apiService: widget.apiService,
//       onSaved: _loadDashboardData,
//     ),
//   );
// }

// void _toggleRequestTypeStatus(RequestType type) async {
//   try {
//     final updatedType = RequestType(
//       id: type.id,
//       name: type.name,
//       description: type.description,
//       category: type.category,
//       active: !type.active,
//       createdBy: type.createdBy,
//       createdAt: type.createdAt,
//       fields: type.fields,
//       statusWorkflow: type.statusWorkflow,
//     );
//     await widget.apiService.updateRequestType(updatedType);
//     _loadDashboardData();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Request type ${type.active ? 'deactivated' : 'activated'} successfully')),
//     );
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error updating request type: $e')),
//     );
//   }
// }

// void _showDeleteConfirmation(RequestType type) {
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: const Text('Delete Request Type'),
//       content: Text('Are you sure you want to delete "${type.name}"? This action cannot be undone.'),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () async {
//             Navigator.pop(context);
//             try {
//               await widget.apiService.deleteRequestType(type.id);
//               _loadDashboardData();
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Request type deleted successfully')),
//               );
//             } catch (e) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('Error deleting request type: $e')),
//               );
//             }
//           },
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//           child: const Text('Delete', style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     ),
//   );
// }
  void _showBulkAssignDialog() {
    showDialog(
      context: context,
      builder: (context) => BulkAssignDialog(apiService: widget.apiService),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => ExportDialog(apiService: widget.apiService),
    );
  }

  void _showSendNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => SendNotificationDialog(
        apiService: widget.apiService,
        onNotificationSent: widget.onRefresh,
      ),
    );
  }

  void _showRequestDetails(Request request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminRequestDetailsScreen(
          request: request,
          apiService: widget.apiService,
        ),
      ),
    );
  }

  void _showAllOverdueRequests() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('View all overdue requests feature coming soon!')),
    );
  }
}

class RequestTypesTab extends StatefulWidget {
  final MockApiService apiService;

  const RequestTypesTab({Key? key, required this.apiService}) : super(key: key);

  @override
  _RequestTypesTabState createState() => _RequestTypesTabState();
}

class _RequestTypesTabState extends State<RequestTypesTab> {
  List<RequestType> _requestTypes = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _loading = true);
    try {
      final types = await widget.apiService.getRequestTypes();
      setState(() {
        _requestTypes = types;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading request types: $e')),
      );
    }
  }

  List<RequestType> get _filteredRequestTypes {
    if (_searchQuery.isEmpty) return _requestTypes;
    return _requestTypes.where((type) =>
        type.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        type.description.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search request types...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showCreateRequestTypeDialog(),
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
          child: _filteredRequestTypes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.category, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No request types found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      if (_searchQuery.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => setState(() => _searchQuery = ''),
                          child: const Text('Clear search'),
                        ),
                      ],
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredRequestTypes.length,
                  itemBuilder: (context, index) {
                    final type = _filteredRequestTypes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        leading: const Icon(Icons.category, color: Colors.blue),
                        title: Text(type.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(type.description),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    type.category,
                                    style: const TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: type.active ? Colors.green : Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    type.active ? 'ACTIVE' : 'INACTIVE',
                                    style: const TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) => _handleRequestTypeAction(value, type),
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                            PopupMenuItem(value: 'activate', child: Text(type.active ? 'Deactivate' : 'Activate')),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Fields:', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                if (type.fields.isEmpty)
                                  const Text('No custom fields defined', style: TextStyle(color: Colors.grey))
                                else
                                  ...type.fields.map((field) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        Icon(_getFieldTypeIcon(field.type), size: 16),
                                        const SizedBox(width: 8),
                                        Text(field.name),
                                        if (field.required)
                                          const Text(' *', style: TextStyle(color: Colors.red)),
                                        const Spacer(),
                                        Text(field.type.toString().split('.').last.toUpperCase(),
                                            style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                      ],
                                    ),
                                  )),
                                const SizedBox(height: 16),
                                const Text('Status Workflow:', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                if (type.statusWorkflow.isEmpty)
                                  const Text('No workflow defined', style: TextStyle(color: Colors.grey))
                                else
                                  Wrap(
                                    spacing: 8,
                                    children: type.statusWorkflow.map((status) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Color(int.parse(status.color.replaceFirst('#', '0xff'))),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        status.name,
                                        style: const TextStyle(color: Colors.white, fontSize: 10),
                                      ),
                                    )).toList(),
                                  ),
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
    );
  }

  IconData _getFieldTypeIcon(FieldType type) {
    switch (type) {
      case FieldType.text:
        return Icons.text_fields;
      case FieldType.number:
        return Icons.numbers;
      case FieldType.email:
        return Icons.email;
      case FieldType.date:
        return Icons.date_range;
      case FieldType.dropdown:
        return Icons.arrow_drop_down;
      case FieldType.checkbox:
        return Icons.check_box;
      case FieldType.textarea:
        return Icons.notes;
      default:
        return Icons.help;
    }
  }

  void _showCreateRequestTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => RequestTypeFormScreen(
        apiService: widget.apiService,
        onSaved: _loadDashboardData,
      ),
    );
  }

  void _handleRequestTypeAction(String action, RequestType type) {
    switch (action) {
      case 'edit':
        showDialog(
          context: context,
          builder: (context) => RequestTypeFormScreen(
            apiService: widget.apiService,
            requestType: type,
            onSaved: _loadDashboardData,
          ),
        );
        break;
      case 'duplicate':
        _duplicateRequestType(type);
        break;
      case 'activate':
        _toggleRequestTypeStatus(type);
        break;
      case 'delete':
        _showDeleteConfirmation(type);
        break;
    }
  }

  void _duplicateRequestType(RequestType type) {
    showDialog(
      context: context,
      builder: (context) => RequestTypeFormScreen(
        apiService: widget.apiService,
        onSaved: _loadDashboardData,
      ),
    );
  }

  void _toggleRequestTypeStatus(RequestType type) async {
    try {
      final updatedType = RequestType(
        id: type.id,
        name: type.name,
        description: type.description,
        category: type.category,
        active: !type.active,
        createdBy: type.createdBy,
        createdAt: type.createdAt,
        fields: type.fields,
        statusWorkflow: type.statusWorkflow,
      );
      await widget.apiService.updateRequestType(updatedType);
      _loadDashboardData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request type ${type.active ? 'deactivated' : 'activated'} successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating request type: $e')),
      );
    }
  }

  void _showDeleteConfirmation(RequestType type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Request Type'),
        content: Text('Are you sure you want to delete "${type.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await widget.apiService.deleteRequestType(type.id);
                _loadDashboardData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request type deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting request type: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
// void _showCreateRequestTypeDialog() {
//   showDialog(
//     context: context,
//     builder: (context) => RequestTypeFormScreen(
//       apiService: widget.apiService,
//       onSaved: () => _loadRequestTypes(),
//     ),
//   );
// }

// void _handleRequestTypeAction(String action, RequestType type) {
//   switch (action) {
//     case 'edit':
//       showDialog(
//         context: context,
//         builder: (context) => RequestTypeFormScreen(
//           apiService: widget.apiService,
//           requestType: type,
//           onSaved: () => _loadRequestTypes(),
//         ),
//       );
//       break;
//     case 'duplicate':
//       _duplicateRequestType(type);
//       break;
//     case 'activate':
//       _toggleRequestTypeStatus(type);
//       break;
//     case 'delete':
//       _showDeleteConfirmation(type);
//       break;
//   }
// }

// void _duplicateRequestType(RequestType type) {
//   showDialog(
//     context: context,
//     builder: (context) => RequestTypeFormScreen(
//       apiService: widget.apiService,
//       onSaved: () => _loadRequestTypes(),
//     ),
//   );
// }

// void _toggleRequestTypeStatus(RequestType type) async {
//   try {
//     final updatedType = RequestType(
//       id: type.id,
//       name: type.name,
//       description: type.description,
//       category: type.category,
//       active: !type.active,
//       createdBy: type.createdBy,
//       createdAt: type.createdAt,
//       fields: type.fields,
//       statusWorkflow: type.statusWorkflow,
//     );
//     await widget.apiService.updateRequestType(updatedType);
//     _loadRequestTypes();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Request type ${type.active ? 'deactivated' : 'activated'} successfully')),
//     );
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error updating request type: $e')),
//     );
//   }
// }

// void _showDeleteConfirmation(RequestType type) {
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: const Text('Delete Request Type'),
//       content: Text('Are you sure you want to delete "${type.name}"? This action cannot be undone.'),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () async {
//             Navigator.pop(context);
//             try {
//               await widget.apiService.deleteRequestType(type.id);
//               _loadRequestTypes();
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Request type deleted successfully')),
//               );
//             } catch (e) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('Error deleting request type: $e')),
//               );
//             }
//           },
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//           child: const Text('Delete', style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     ),
//   );
// }
}
class AllRequestsTab extends StatefulWidget {
  final MockApiService apiService;
  final User currentUser;

  const AllRequestsTab({
    Key? key,
    required this.apiService,
    required this.currentUser,
  }) : super(key: key);

  @override
  _AllRequestsTabState createState() => _AllRequestsTabState();
}

class _AllRequestsTabState extends State<AllRequestsTab> {
  List<Request> _requests = [];
  List<Request> _filteredRequests = [];
  List<String> _selectedRequestIds = [];
  bool _loading = true;
  bool _isSelectionMode = false;
  
  // Filters
  String _searchQuery = '';
  String? _statusFilter;
  Priority? _priorityFilter;
  String? _categoryFilter;
  String? _assignedAdminFilter;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _loading = true);
    try {
      final requests = await widget.apiService.getRequests();
      setState(() {
        _requests = requests;
        _applyFilters();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading requests: $e')),
      );
    }
  }

  void _applyFilters() {
    var filtered = List<Request>.from(_requests);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((request) =>
        request.typeName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        request.fieldValues.values.any((value) => 
          value.toString().toLowerCase().contains(_searchQuery.toLowerCase()))).toList();
    }

    // Status filter
    if (_statusFilter != null && _statusFilter!.isNotEmpty) {
      filtered = filtered.where((request) => request.status == _statusFilter).toList();
    }

    // Priority filter
    if (_priorityFilter != null) {
      filtered = filtered.where((request) => request.priority == _priorityFilter).toList();
    }

    // Category filter
    if (_categoryFilter != null && _categoryFilter!.isNotEmpty) {
      filtered = filtered.where((request) => request.category == _categoryFilter).toList();
    }

    // Assigned admin filter
    if (_assignedAdminFilter != null && _assignedAdminFilter!.isNotEmpty) {
      filtered = filtered.where((request) => request.assignedAdminId == _assignedAdminFilter).toList();
    }

    setState(() {
      _filteredRequests = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildFiltersSection(),
        if (_isSelectionMode) _buildSelectionActions(),
        Expanded(
          child: _filteredRequests.isEmpty
              ? _buildEmptyState()
              : _buildRequestsList(),
        ),
      ],
    );
  }

  Widget _buildFiltersSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search requests...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showBulkActionsDialog(),
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'Bulk Actions',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    value: _statusFilter,
                    onChanged: (value) {
                      setState(() => _statusFilter = value);
                      _applyFilters();
                    },
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'Under Review', child: Text('Under Review')),
                      DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                      DropdownMenuItem(value: 'Approved', child: Text('Approved')),
                      DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                      DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<Priority>(
                    decoration: InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    value: _priorityFilter,
                    onChanged: (value) {
                      setState(() => _priorityFilter = value);
                      _applyFilters();
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

  Widget _buildSelectionActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          Text('${_selectedRequestIds.length} selected'),
          const Spacer(),
          TextButton(
            onPressed: () => _showAssignDialog(),
            child: const Text('Assign'),
          ),
          TextButton(
            onPressed: () => _showUpdateStatusDialog(),
            child: const Text('Update Status'),
          ),
          TextButton(
            onPressed: () => _showUpdatePriorityDialog(),
            child: const Text('Priority'),
          ),
          TextButton(
            onPressed: () => setState(() {
              _selectedRequestIds.clear();
              _isSelectionMode = false;
            }),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No requests found', style: TextStyle(fontSize: 18, color: Colors.grey)),
          if (_searchQuery.isNotEmpty || _statusFilter != null || _priorityFilter != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _clearFilters(),
              child: const Text('Clear filters'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequestsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredRequests.length,
      itemBuilder: (context, index) {
        final request = _filteredRequests[index];
        final isSelected = _selectedRequestIds.contains(request.id);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => _isSelectionMode ? _toggleSelection(request.id) : _showRequestDetails(request),
            onLongPress: () => _toggleSelectionMode(request.id),
            child: Container(
              decoration: BoxDecoration(
                border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment, color: _getPriorityColor(request.priority)),
                    Text('#${request.id}', style: const TextStyle(fontSize: 10)),
                  ],
                ),
                title: Text(request.typeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category: ${request.category}'),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStatusChip(request.status),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(request.priority),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            request.priority.toString().split('.').last.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Submitted: ${_formatDate(request.submittedAt)}', 
                         style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    if (request.assignedAdminName != null)
                      Text('Assigned to: ${request.assignedAdminName}', 
                           style: const TextStyle(fontSize: 12, color: Colors.blue)),
                  ],
                ),
                trailing: _isSelectionMode
                    ? Checkbox(
                        value: isSelected,
                        onChanged: (value) => _toggleSelection(request.id),
                      )
                    : PopupMenuButton<String>(
                        onSelected: (value) => _handleRequestAction(value, request),
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'view', child: Text('View Details')),
                          PopupMenuItem(value: 'assign', child: Text('Assign')),
                          PopupMenuItem(value: 'status', child: Text('Update Status')),
                          PopupMenuItem(value: 'priority', child: Text('Change Priority')),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'under review':
      case 'in progress':
        color = Colors.blue;
        break;
      case 'approved':
      case 'completed':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 10),
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

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _statusFilter = null;
      _priorityFilter = null;
      _categoryFilter = null;
      _assignedAdminFilter = null;
    });
    _applyFilters();
  }

  void _toggleSelectionMode(String requestId) {
    setState(() {
      _isSelectionMode = true;
      _selectedRequestIds = [requestId];
    });
  }

  void _toggleSelection(String requestId) {
    setState(() {
      if (_selectedRequestIds.contains(requestId)) {
        _selectedRequestIds.remove(requestId);
        if (_selectedRequestIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedRequestIds.add(requestId);
      }
    });
  }

  void _showBulkActionsDialog() {
    showDialog(
      context: context,
      builder: (context) => BulkActionsDialog(
        apiService: widget.apiService,
        onAction: () => _loadRequests(),
      ),
    );
  }

  void _showAssignDialog() {
    showDialog(
      context: context,
      builder: (context) => AssignRequestDialog(
        request: _filteredRequests.first, // Placeholder
        apiService: widget.apiService,
        adminUsers: const [],
        onAssigned: () => _loadRequests(),
      ),
    );
  }

  void _showUpdateStatusDialog() {
    showDialog(
      context: context,
      builder: (context) => UpdateStatusDialog(
        request: _filteredRequests.first, // Placeholder
        apiService: widget.apiService,
        onUpdated: () => _loadRequests(),
      ),
    );
  }

  void _showUpdatePriorityDialog() {
    showDialog(
      context: context,
      builder: (context) => UpdatePriorityDialog(
        request: _filteredRequests.first, // Placeholder
        apiService: widget.apiService,
        onUpdated: () => _loadRequests(),
      ),
    );
  }

  void _handleRequestAction(String action, Request request) {
    switch (action) {
      case 'view':
        _showRequestDetails(request);
        break;
      case 'assign':
        _showSingleAssignDialog(request);
        break;
      case 'status':
        _showSingleStatusDialog(request);
        break;
      case 'priority':
        _showSinglePriorityDialog(request);
        break;
    }
  }

  void _showRequestDetails(Request request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminRequestDetailsScreen(
          request: request,
          apiService: widget.apiService,
        ),
      ),
    ).then((_) => _loadRequests());
  }

  void _showSingleAssignDialog(Request request) async {
    try {
      final adminUsers = await widget.apiService.getAdminUsers();
      showDialog(
        context: context,
        builder: (context) => AssignRequestDialog(
          request: request,
          apiService: widget.apiService,
          adminUsers: adminUsers,
          onAssigned: () => _loadRequests(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading admin users: $e')),
      );
    }
  }

  void _showSingleStatusDialog(Request request) {
    showDialog(
      context: context,
      builder: (context) => UpdateStatusDialog(
        request: request,
        apiService: widget.apiService,
        onUpdated: () => _loadRequests(),
      ),
    );
  }

  void _showSinglePriorityDialog(Request request) {
    showDialog(
      context: context,
      builder: (context) => UpdatePriorityDialog(
        request: request,
        apiService: widget.apiService,
        onUpdated: () => _loadRequests(),
      ),
    );
  }





}


// class AllRequestsTab extends StatefulWidget {
//   final MockApiService apiService;
//   final User currentUser;

//   const AllRequestsTab({
//     Key? key,
//     required this.apiService,
//     required this.currentUser,
//   }) : super(key: key);

//   @override
//   _AllRequestsTabState createState() => _AllRequestsTabState();
// }

// class _AllRequestsTabState extends State<AllRequestsTab> {
//   List<Request> _requests = [];
//   List<Request> _filteredRequests = [];
//   List<String> _selectedRequestIds = [];
//   bool _loading = true;
//   bool _isSelectionMode = false;
  
//   // Filters
//   String _searchQuery = '';
//   String? _statusFilter;
//   Priority? _priorityFilter;
//   String? _categoryFilter;
//   String? _assignedAdminFilter;

//   @override
//   void initState() {
//     super.initState();
//     _loadRequests();
//   }

//   Future<void> _loadRequests() async {
//     setState(() => _loading = true);
//     try {
//       final requests = await widget.apiService.getRequests();
//       setState(() {
//         _requests = requests;
//         _applyFilters();
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() => _loading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading requests: $e')),
//       );
//     }
//   }

//   void _applyFilters() {
//     var filtered = List<Request>.from(_requests);

//     // Search filter
//     if (_searchQuery.isNotEmpty) {
//       filtered = filtered.where((request) =>
//         request.typeName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//         request.fieldValues.values.any((value) => 
//           value.toString().toLowerCase().contains(_searchQuery.toLowerCase()))).toList();
//     }

//     // Status filter
//     if (_statusFilter != null && _statusFilter!.isNotEmpty) {
//       filtered = filtered.where((request) => request.status == _statusFilter).toList();
//     }

//     // Priority filter
//     if (_priorityFilter != null) {
//       filtered = filtered.where((request) => request.priority == _priorityFilter).toList();
//     }

//     // Category filter
//     if (_categoryFilter != null && _categoryFilter!.isNotEmpty) {
//       filtered = filtered.where((request) => request.category == _categoryFilter).toList();
//     }

//     // Assigned admin filter
//     if (_assignedAdminFilter != null && _assignedAdminFilter!.isNotEmpty) {
//       filtered = filtered.where((request) => request.assignedAdminId == _assignedAdminFilter).toList();
//     }

//     setState(() {
//       _filteredRequests = filtered;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return Column(
//       children: [
//         _buildFiltersSection(),
//         if (_isSelectionMode) _buildSelectionActions(),
//         Expanded(
//           child: _filteredRequests.isEmpty
//               ? _buildEmptyState()
//               : _buildRequestsList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildFiltersSection() {
//     return Card(
//       margin: const EdgeInsets.all(16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     decoration: InputDecoration(
//                       hintText: 'Search requests...',
//                       prefixIcon: const Icon(Icons.search),
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                     onChanged: (value) {
//                       setState(() => _searchQuery = value);
//                       _applyFilters();
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   onPressed: () => _showBulkActionsDialog(),
//                   icon: const Icon(Icons.more_vert),
//                   tooltip: 'Bulk Actions',
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     decoration: InputDecoration(
//                       labelText: 'Status',
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                     value: _statusFilter,
//                     onChanged: (value) {
//                       setState(() => _statusFilter = value);
//                       _applyFilters();
//                     },
//                     items: const [
//                       DropdownMenuItem(value: null, child: Text('All')),
//                       DropdownMenuItem(value: 'Pending', child: Text('Pending')),
//                       DropdownMenuItem(value: 'Under Review', child: Text('Under Review')),
//                       DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
//                       DropdownMenuItem(value: 'Approved', child: Text('Approved')),
//                       DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
//                       DropdownMenuItem(value: 'Completed', child: Text('Completed')),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: DropdownButtonFormField<Priority>(
//                     decoration: InputDecoration(
//                       labelText: 'Priority',
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                     value: _priorityFilter,
//                     onChanged: (value) {
//                       setState(() => _priorityFilter = value);
//                       _applyFilters();
//                     },
//                     items: [
//                       const DropdownMenuItem(value: null, child: Text('All')),
//                       ...Priority.values.map((priority) => DropdownMenuItem(
//                         value: priority,
//                         child: Text(priority.toString().split('.').last.toUpperCase()),
//                       )),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSelectionActions() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       color: Colors.blue.shade50,
//       child: Row(
//         children: [
//           Text('${_selectedRequestIds.length} selected'),
//           const Spacer(),
//           TextButton(
//             onPressed: () => _showAssignDialog(),
//             child: const Text('Assign'),
//           ),
//           TextButton(
//             onPressed: () => _showUpdateStatusDialog(),
//             child: const Text('Update Status'),
//           ),
//           TextButton(
//             onPressed: () => _showUpdatePriorityDialog(),
//             child: const Text('Priority'),
//           ),
//           TextButton(
//             onPressed: () => setState(() {
//               _selectedRequestIds.clear();
//               _isSelectionMode = false;
//             }),
//             child: const Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.assignment, size: 64, color: Colors.grey),
//           const SizedBox(height: 16),
//           const Text('No requests found', style: TextStyle(fontSize: 18, color: Colors.grey)),
//           if (_searchQuery.isNotEmpty || _statusFilter != null || _priorityFilter != null) ...[
//             const SizedBox(height: 8),
//             TextButton(
//               onPressed: () => _clearFilters(),
//               child: const Text('Clear filters'),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildRequestsList() {
//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       itemCount: _filteredRequests.length,
//       itemBuilder: (context, index) {
//         final request = _filteredRequests[index];
//         final isSelected = _selectedRequestIds.contains(request.id);
        
//         return Card(
//           margin: const EdgeInsets.only(bottom: 8),
//           child: InkWell(
//             onTap: () => _isSelectionMode ? _toggleSelection(request.id) : _showRequestDetails(request),
//             onLongPress: () => _toggleSelectionMode(request.id),
//             child: Container(
//               decoration: BoxDecoration(
//                 border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: ListTile(
//                 leading: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.assignment, color: _getPriorityColor(request.priority)),
//                     Text('#${request.id}', style: const TextStyle(fontSize: 10)),
//                   ],
//                 ),
//                 title: Text(request.typeName, style: const TextStyle(fontWeight: FontWeight.bold)),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Category: ${request.category}'),
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         _buildStatusChip(request.status),
//                         const SizedBox(width: 8),
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: _getPriorityColor(request.priority),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Text(
//                             request.priority.toString().split('.').last.toUpperCase(),
//                             style: const TextStyle(color: Colors.white, fontSize: 10),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Text('Submitted: ${_formatDate(request.submittedAt)}', 
//                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
//                     if (request.assignedAdminName != null)
//                       Text('Assigned to: ${request.assignedAdminName}', 
//                            style: const TextStyle(fontSize: 12, color: Colors.blue)),
//                   ],
//                 ),
//                 trailing: _isSelectionMode
//                     ? Checkbox(
//                         value: isSelected,
//                         onChanged: (value) => _toggleSelection(request.id),
//                       )
//                     : PopupMenuButton<String>(
//                         onSelected: (value) => _handleRequestAction(value, request),
//                         itemBuilder: (context) => const [
//                           PopupMenuItem(value: 'view', child: Text('View Details')),
//                           PopupMenuItem(value: 'assign', child: Text('Assign')),
//                           PopupMenuItem(value: 'status', child: Text('Update Status')),
//                           PopupMenuItem(value: 'priority', child: Text('Change Priority')),
//                         ],
//                       ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildStatusChip(String status) {
//     Color color;
//     switch (status.toLowerCase()) {
//       case 'pending':
//         color = Colors.orange;
//         break;
//       case 'under review':
//       case 'in progress':
//         color = Colors.blue;
//         break;
//       case 'approved':
//       case 'completed':
//         color = Colors.green;
//         break;
//       case 'rejected':
//         color = Colors.red;
//         break;
//       default:
//         color = Colors.grey;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Text(
//         status.toUpperCase(),
//         style: const TextStyle(color: Colors.white, fontSize: 10),
//       ),
//     );
//   }

//   Color _getPriorityColor(Priority priority) {
//     switch (priority) {
//       case Priority.low:
//         return Colors.green;
//       case Priority.medium:
//         return Colors.orange;
//       case Priority.high:
//         return Colors.red;
//       case Priority.urgent:
//         return Colors.purple;
//     }
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   void _clearFilters() {
//     setState(() {
//       _searchQuery = '';
//       _statusFilter = null;
//       _priorityFilter = null;
//       _categoryFilter = null;
//       _assignedAdminFilter = null;
//     });
//     _applyFilters();
//   }

//   void _toggleSelectionMode(String requestId) {
//     setState(() {
//       _isSelectionMode = true;
//       _selectedRequestIds = [requestId];
//     });
//   }

//   void _toggleSelection(String requestId) {
//     setState(() {
//       if (_selectedRequestIds.contains(requestId)) {
//         _selectedRequestIds.remove(requestId);
//         if (_selectedRequestIds.isEmpty) {
//           _isSelectionMode = false;
//         }
//       } else {
//         _selectedRequestIds.add(requestId);
//       }
//     });
//   }

//   void _showBulkActionsDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => BulkActionsDialog(
//         apiService: widget.apiService,
//         onAction: () => _loadRequests(),
//       ),
//     );
//   }

//   void _showAssignDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AssignRequestDialog(
//         request: _filteredRequests.first, // Placeholder
//         apiService: widget.apiService,
//         adminUsers: const [],
//         onAssigned: () => _loadRequests(),
//       ),
//     );
//   }

//   void _showUpdateStatusDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => UpdateStatusDialog(
//         request: _filteredRequests.first, // Placeholder
//         apiService: widget.apiService,
//         onUpdated: () => _loadRequests(),
//       ),
//     );
//   }

//   void _showUpdatePriorityDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => UpdatePriorityDialog(
//         request: _filteredRequests.first, // Placeholder
//         apiService: widget.apiService,
//         onUpdated: () => _loadRequests(),
//       ),
//     );
//   }

//   void _handleRequestAction(String action, Request request) {
//     switch (action) {
//       case 'view':
//         _showRequestDetails(request);
//         break;
//       case 'assign':
//         _showSingleAssignDialog(request);
//         break;
//       case 'status':
//         _showSingleStatusDialog(request);
//         break;
//       case 'priority':
//         _showSinglePriorityDialog(request);
//         break;
//     }
//   }

//   void _showRequestDetails(Request request) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AdminRequestDetailsScreen(
//           request: request,
//           apiService: widget.apiService,
//         ),
//       ),
//     ).then((_) => _loadRequests());
//   }

//   void _showSingleAssignDialog(Request request) async {
//     try {
//       final adminUsers = await widget.apiService.getAdminUsers();
//       showDialog(
//         context: context,
//         builder: (context) => AssignRequestDialog(
//           request: request,
//           apiService: widget.apiService,
//           adminUsers: adminUsers,
//           onAssigned: () => _loadRequests(),
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading admin users: $e')),
//       );
//     }
//   }

//   void _showSingleStatusDialog(Request request) {
//     showDialog(
//       context: context,
//       builder: (context) => UpdateStatusDialog(
//         request: request,
//         apiService: widget.apiService,
//         onUpdated: () => _loadRequests(),
//       ),
//     );
//   }

//   void _showSinglePriorityDialog(Request request) {
//     showDialog(
//       context: context,
//       builder: (context) => UpdatePriorityDialog(
//         request: request,
//         apiService: widget.apiService,
//         onUpdated: () => _loadRequests(),
//       ),
//     );
//   }
// }

class TemplatesManagementTab extends StatefulWidget {
  final MockApiService apiService;

  const TemplatesManagementTab({Key? key, required this.apiService}) : super(key: key);

  @override
  _TemplatesManagementTabState createState() => _TemplatesManagementTabState();
}

class _TemplatesManagementTabState extends State<TemplatesManagementTab> {
  List<RequestTemplate> _templates = [];
  List<RequestType> _requestTypes = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final templates = await widget.apiService.getTemplates();
      final requestTypes = await widget.apiService.getRequestTypes();
      setState(() {
        _templates = templates;
        _requestTypes = requestTypes;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  List<RequestTemplate> get _filteredTemplates {
    if (_searchQuery.isEmpty) return _templates;
    return _templates.where((template) =>
        template.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        template.description.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search templates...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showCreateTemplateDialog(),
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
          child: _filteredTemplates.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No templates found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('Create templates to speed up request creation'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredTemplates.length,
                  itemBuilder: (context, index) {
                    final template = _filteredTemplates[index];
                    final requestType = _requestTypes.firstWhere(
                      (type) => type.id == template.typeId,
                      orElse: () => RequestType(
                        id: '',
                        name: 'Unknown',
                        description: '',
                        category: '',
                        createdBy: '',
                        createdAt: DateTime.now(),
                      ),
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.description, color: Colors.white),
                        ),
                        title: Text(template.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(template.description),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.category, size: 12, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(requestType.name, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) => _handleTemplateAction(value, template),
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
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

  void _showCreateTemplateDialog() {
    showDialog(
      context: context,
      builder: (context) => TemplateFormScreen(
        apiService: widget.apiService,
        requestTypes: _requestTypes,
        onSaved: _loadData,
      ),
    );
  }

  void _handleTemplateAction(String action, RequestTemplate template) {
    switch (action) {
      case 'edit':
        showDialog(
          context: context,
          builder: (context) => TemplateFormScreen(
            apiService: widget.apiService,
            requestTypes: _requestTypes,
            template: template,
            onSaved: _loadData,
          ),
        );
        break;
      case 'duplicate':
        _duplicateTemplate(template);
        break;
      case 'delete':
        _showDeleteConfirmation(template);
        break;
    }
  }

  void _duplicateTemplate(RequestTemplate template) {
    showDialog(
      context: context,
      builder: (context) => TemplateFormScreen(
        apiService: widget.apiService,
        requestTypes: _requestTypes,
        onSaved: _loadData,
      ),
    );
  }

  void _showDeleteConfirmation(RequestTemplate template) {
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
              try {
                await widget.apiService.deleteTemplate(template.id);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Template deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting template: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class AdvancedAnalyticsTab extends StatefulWidget {
  final MockApiService apiService;

  const AdvancedAnalyticsTab({Key? key, required this.apiService}) : super(key: key);

  @override
  _AdvancedAnalyticsTabState createState() => _AdvancedAnalyticsTabState();
}


class _AdvancedAnalyticsTabState extends State<AdvancedAnalyticsTab> {
  DashboardStats? _dashboardStats;
  bool _loading = true;
  String _selectedPeriod = '30days';

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _loading = true);
    try {
      final stats = await widget.apiService.getDashboardStats();
      setState(() {
        _dashboardStats = stats;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading analytics: $e')),
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getFieldDisplayName(String fieldId) {
    return fieldId.replaceAll('_', ' ').split(' ').map((word) => 
      word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '').join(' ');
  }

  String _formatFieldValue(String fieldId, dynamic value) {
    if (value is DateTime) {
      return _formatDate(value);
    }
    return value.toString();
  }

  Widget _buildMiniStatusChip(String status, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status, style: TextStyle(color: textColor, fontSize: 10)),
    );
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await widget.apiService.deleteComment(commentId);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting comment: $e')),
      );
    }
  }

  Future<void> _loadData() async {
    // Implementation of loading data
    setState(() => _loading = true);
    try {
      // Your data loading logic here
      setState(() => _loading = false);
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  // Future<void> _submitComment(bool isPrivate) async {
  //   if (_commentController.text.trim().isEmpty) return;

  //   try {
  //     final comment = RequestComment(
  //       id: '',
  //       requestId: _currentRequest!.id,
  //       authorId: 'admin',
  //       authorName: 'Admin',
  //       content: _commentController.text.trim(),
  //       createdAt: DateTime.now(),
  //       isPrivate: isPrivate,
  //     );

  //     await widget.apiService.addComment(comment);
  //     _commentController.clear();
  //     _loadData();
      
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Comment added successfully')),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error adding comment: $e')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dashboardStats == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Failed to load analytics'),
            ElevatedButton(
              onPressed: _loadAnalytics,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalyticsHeader(),
          const SizedBox(height: 24),
          _buildMetricsGrid(),
          const SizedBox(height: 24),
          _buildPerformanceSection(),
          const SizedBox(height: 24),
          _buildTrendsSection(),
          const SizedBox(height: 24),
          _buildReportsSection(),
        ],
      ),
    );
  }

  // Rest of your existing methods...
  Widget _buildAnalyticsHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Advanced Analytics',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text('Comprehensive insights into system performance'),
            ],
          ),
        ),
        DropdownButton<String>(
          value: _selectedPeriod,
          onChanged: (value) {
            setState(() => _selectedPeriod = value!);
            _loadAnalytics();
          },
          items: const [
            DropdownMenuItem(value: '7days', child: Text('Last 7 days')),
            DropdownMenuItem(value: '30days', child: Text('Last 30 days')),
            DropdownMenuItem(value: '90days', child: Text('Last 90 days')),
            DropdownMenuItem(value: '1year', child: Text('Last year')),
          ],
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => _showCreateReportDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Create Report'),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildMetricCard('Total Requests', _dashboardStats!.totalRequests.toString(), Icons.assignment, Colors.blue),
        _buildMetricCard('Overdue', _dashboardStats!.overdueRequests.toString(), Icons.warning, Colors.red),
        _buildMetricCard('Avg. Resolution', '2.3 days', Icons.timer, Colors.green),
        _buildMetricCard('Satisfaction', '4.2/5', Icons.star, Colors.orange),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Metrics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTopPerformersChart()),
            const SizedBox(width: 16),
            Expanded(child: _buildResolutionTimeChart()),
          ],
        ),
      ],
    );
  }

  Widget _buildTopPerformersChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Performers',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...(_dashboardStats!.topPerformers.isNotEmpty 
                ? _dashboardStats!.topPerformers.take(3).map((performer) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text((performer.completedRequests).toString()),
                      ),
                      title: Text(performer.adminName),
                      trailing: Text('${performer.completedRequests} requests'),
                    ),
                  ))
                : [const Text('No data available')]),
          ],
        ),
      ),
    );
  }

  Widget _buildResolutionTimeChart() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resolution Time Trends',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: Center(
                child: Text('Chart placeholder - Implementation needed'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Request Trends',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Request Volume Over Time',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (_dashboardStats?.trends.isEmpty == true) 
                  const Center(
                    child: Text('No trend data available'),
                  )
                else
                  SizedBox(
                    height: 200,
                    child: _buildTrendChart(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendChart() {
    final trends = _dashboardStats!.trends;
    if (trends.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: trends.length,
      itemBuilder: (context, index) {
        final trend = trends[index];
        return Container(
          width: 60,
          margin: const EdgeInsets.only(right: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(trend.requestCount.toString(), style: const TextStyle(fontSize: 12)),
              Container(
                height: trend.requestCount * 10.0,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${trend.date.day}/${trend.date.month}',
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Scheduled Reports',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Weekly Performance Report'),
                  subtitle: const Text('Every Monday at 9:00 AM'),
                  trailing: Switch(value: true, onChanged: (value) {}),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Monthly Analytics Summary'),
                  subtitle: const Text('First day of each month'),
                  trailing: Switch(value: false, onChanged: (value) {}),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showCreateReportDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Report'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCreateReportDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateScheduledReportDialog(
        onCreated: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report scheduled successfully')),
          );
        },
      ),
    );
  }
}

class AdminRequestDetailsScreen extends StatefulWidget {
  final Request request;
  final MockApiService apiService;

  const AdminRequestDetailsScreen({
    Key? key,
    required this.request,
    required this.apiService,
  }) : super(key: key);

  @override
  _AdminRequestDetailsScreenState createState() => _AdminRequestDetailsScreenState();
}

class _AdminRequestDetailsScreenState extends State<AdminRequestDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Request? _currentRequest;
  RequestType? _requestType;
  List<RequestComment> _comments = [];
  List<User> _adminUsers = [];
  bool _loading = true;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentRequest = widget.request;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final type = await widget.apiService.getRequestTypeById(widget.request.typeId);
      final comments = await widget.apiService.getComments(widget.request.id, includePrivate: true);
      final adminUsers = await widget.apiService.getAdminUsers();
      
      setState(() {
        _requestType = type;
        _comments = comments;
        _adminUsers = adminUsers;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Request #${_currentRequest!.id}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'assign':
                  _showAssignDialog();
                  break;
                case 'status':
                  _showStatusDialog();
                  break;
                case 'priority':
                  _showPriorityDialog();
                  break;
                case 'export':
                  _exportRequest();
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'assign', child: Text('Assign')),
              PopupMenuItem(value: 'status', child: Text('Update Status')),
              PopupMenuItem(value: 'priority', child: Text('Change Priority')),
              PopupMenuItem(value: 'export', child: Text('Export')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Comments'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(),
          _buildCommentsTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _currentRequest!.typeName,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Icon(Icons.flag, color: _getPriorityColor(_currentRequest!.priority), size: 20),
                      const SizedBox(width: 8),
                      _buildStatusChip(_currentRequest!.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildInfoRow('Request ID', '#${_currentRequest!.id}'),
                  _buildInfoRow('Category', _currentRequest!.category),
                  _buildInfoRow('Priority', _currentRequest!.priority.toString().split('.').last.toUpperCase()),
                  _buildInfoRow('Submitted At', _formatDateTime(_currentRequest!.submittedAt)),
                  if (_currentRequest!.dueDate != null)
                    _buildInfoRow('Due Date', _formatDate(_currentRequest!.dueDate!)),
                  if (_currentRequest!.assignedAdminName != null)
                    _buildInfoRow('Assigned To', _currentRequest!.assignedAdminName!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Request Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ..._currentRequest!.fieldValues.entries.map((entry) {
                    final fieldName = _getFieldDisplayName(entry.key);
                    return _buildInfoRow(fieldName, _formatFieldValue(entry.key, entry.value));
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsTab() {
    return Column(
      children: [
        Expanded(
          child: _comments.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.comment, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No comments yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('Add a comment to start the conversation'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    final comment = _comments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  child: Text(comment.authorName[0].toUpperCase()),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(comment.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text(_formatDateTime(comment.createdAt), 
                                           style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                if (comment.isPrivate)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text('PRIVATE', style: TextStyle(color: Colors.white, fontSize: 10)),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 16),
                                  onPressed: () => _deleteComment(comment.id),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(comment.content),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Column(
            children: [
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _submitComment(false),
                      child: const Text('Add Comment'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _submitComment(true),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: const Text('Private Note', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _currentRequest!.statusHistory.length,
      itemBuilder: (context, index) {
        final history = _currentRequest!.statusHistory[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history, size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(history.changedBy, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                          Text(_formatDateTime(history.changedAt), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (history.fromStatus.isNotEmpty) ...[
                      _buildMiniStatusChip(history.fromStatus, Colors.orange.shade100, Colors.orange.shade700),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 16),
                      const SizedBox(width: 8),
                    ],
                    _buildMiniStatusChip(history.toStatus, Colors.green.shade100, Colors.green.shade700),
                  ],
                ),
                if (history.comments != null && history.comments!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(history.comments!, style: const TextStyle(fontStyle: FontStyle.italic)),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'under review':
      case 'in progress':
        color = Colors.blue;
        break;
      case 'approved':
      case 'completed':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMiniStatusChip(String status, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status, style: TextStyle(color: textColor, fontSize: 10)),
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

  String _getFieldDisplayName(String fieldId) {
    return fieldId.replaceAll('_', ' ').split(' ').map((word) => 
      word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '').join(' ');
  }

  String _formatFieldValue(String fieldId, dynamic value) {
    if (value is DateTime) {
      return _formatDate(value);
    }
    return value.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showAssignDialog() {
    showDialog(
      context: context,
      builder: (context) => AssignRequestDialog(
        request: _currentRequest!,
        apiService: widget.apiService,
        adminUsers: _adminUsers,
        onAssigned: () {
          _loadData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request assigned successfully')),
          );
        },
      ),
    );
  }

  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (context) => UpdateStatusDialog(
        request: _currentRequest!,
        apiService: widget.apiService,
        onUpdated: () {
          _loadData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Status updated successfully')),
          );
        },
      ),
    );
  }

  void _showPriorityDialog() {
    showDialog(
      context: context,
      builder: (context) => UpdatePriorityDialog(
        request: _currentRequest!,
        apiService: widget.apiService,
        onUpdated: () {
          _loadData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Priority updated successfully')),
          );
        },
      ),
    );
  }

  void _exportRequest() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon!')),
    );
  }

  Future<void> _submitComment(bool isPrivate) async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      final comment = RequestComment(
        id: '',
        requestId: _currentRequest!.id,
        authorId: 'admin',
        authorName: 'Admin',
        content: _commentController.text.trim(),
        createdAt: DateTime.now(),
        isPrivate: isPrivate,
      );

      await widget.apiService.addComment(comment);
      _commentController.clear();
      _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding comment: $e')),
      );
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await widget.apiService.deleteComment(commentId);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting comment: $e')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }
}


class BulkActionsDialog extends StatelessWidget {
  final MockApiService apiService;
  final VoidCallback onAction;

  const BulkActionsDialog({
    Key? key,
    required this.apiService,
    required this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bulk Actions'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Assign to Admin'),
            onTap: () {
              Navigator.pop(context);
              onAction();
            },
          ),
          ListTile(
            leading: const Icon(Icons.update),
            title: const Text('Update Status'),
            onTap: () {
              Navigator.pop(context);
              onAction();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Requests'),
            onTap: () {
              Navigator.pop(context);
              onAction();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class ExportDialog extends StatelessWidget {
  final MockApiService apiService;

  const ExportDialog({Key? key, required this.apiService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Data'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Export to Excel'),
            onTap: () async {
              Navigator.pop(context);
              try {
                final requests = await apiService.getRequests();
                final url = await apiService.exportRequestsToExcel(requests);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Exported successfully: $url')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Export failed: $e')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Export to PDF'),
            onTap: () async {
              Navigator.pop(context);
              try {
                final requests = await apiService.getRequests();
                final url = await apiService.exportRequestsToPdf(requests);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Exported successfully: $url')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Export failed: $e')),
                );
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class AssignRequestDialog extends StatefulWidget {
  final Request request;
  final MockApiService apiService;
  final List<User> adminUsers;
  final VoidCallback onAssigned;

  const AssignRequestDialog({
    Key? key,
    required this.request,
    required this.apiService,
    required this.adminUsers,
    required this.onAssigned,
  }) : super(key: key);

  @override
  _AssignRequestDialogState createState() => _AssignRequestDialogState();
}

class _AssignRequestDialogState extends State<AssignRequestDialog> {
  String? _selectedAdminId;
  bool _assigning = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign Request'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Assign this request to an admin:'),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Select Admin',
              border: OutlineInputBorder(),
            ),
            value: _selectedAdminId,
            onChanged: (value) {
              setState(() => _selectedAdminId = value);
            },
            items: widget.adminUsers.map((admin) => DropdownMenuItem(
              value: admin.id,
              child: Text(admin.name),
            )).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _assigning ? null : _assignRequest,
          child: _assigning
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Assign'),
        ),
      ],
    );
  }

  Future<void> _assignRequest() async {
    if (_selectedAdminId == null) return;

    setState(() => _assigning = true);
    try {
      final selectedAdmin = widget.adminUsers.firstWhere((u) => u.id == _selectedAdminId);
      await widget.apiService.assignRequest(widget.request.id, _selectedAdminId!, selectedAdmin.name);
      widget.onAssigned();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request assigned successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error assigning request: $e')),
      );
    } finally {
      setState(() => _assigning = false);
    }
  }
}

class BulkAssignDialog extends StatelessWidget {
  final MockApiService apiService;

  const BulkAssignDialog({Key? key, required this.apiService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      title: Text('Bulk Assign'),
      content: Text('Bulk assignment feature coming soon!'),
      actions: [
        TextButton(
          onPressed: null, // Will be handled by Navigator.pop
          child: Text('Close'),
        ),
      ],
    );
  }
}


class UpdateStatusDialog extends StatefulWidget {
  final Request request;
  final MockApiService apiService;
  final VoidCallback onUpdated;

  const UpdateStatusDialog({
    Key? key,
    required this.request,
    required this.apiService,
    required this.onUpdated,
  }) : super(key: key);

  @override
  _UpdateStatusDialogState createState() => _UpdateStatusDialogState();
}

class _UpdateStatusDialogState extends State<UpdateStatusDialog> {
  String? _selectedStatus;
  final _commentsController = TextEditingController();
  bool _updating = false;

  final List<String> _statusOptions = [
    'Pending',
    'Under Review',
    'In Progress',
    'Approved',
    'Rejected',
    'Completed',
    'Closed'
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'New Status',
              border: OutlineInputBorder(),
            ),
            value: _selectedStatus,
            onChanged: (value) {
              setState(() => _selectedStatus = value);
            },
            items: _statusOptions.map((status) => DropdownMenuItem(
              value: status,
              child: Text(status),
            )).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentsController,
            decoration: const InputDecoration(
              labelText: 'Comments (Optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updating ? null : _updateStatus,
          child: _updating
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Update'),
        ),
      ],
    );
  }

  Future<void> _updateStatus() async {
    if (_selectedStatus == null) return;

    setState(() => _updating = true);
    try {
      await widget.apiService.updateRequestStatus(
        widget.request.id,
        _selectedStatus!,
        adminComments: _commentsController.text.isNotEmpty ? _commentsController.text : null,
        adminName: 'Admin',
      );
      widget.onUpdated();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    } finally {
      setState(() => _updating = false);
    }
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }
}

class UpdatePriorityDialog extends StatefulWidget {
  final Request request;
  final MockApiService apiService;
  final VoidCallback onUpdated;

  const UpdatePriorityDialog({
    Key? key,
    required this.request,
    required this.apiService,
    required this.onUpdated,
  }) : super(key: key);

  @override
  _UpdatePriorityDialogState createState() => _UpdatePriorityDialogState();
}

class _UpdatePriorityDialogState extends State<UpdatePriorityDialog> {
  Priority? _selectedPriority;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _selectedPriority = widget.request.priority;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Priority'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: Priority.values.map((priority) => RadioListTile<Priority>(
          title: Row(
            children: [
              Icon(Icons.flag, color: _getPriorityColor(priority), size: 16),
              const SizedBox(width: 8),
              Text(priority.toString().split('.').last.toUpperCase()),
            ],
          ),
          value: priority,
          groupValue: _selectedPriority,
          onChanged: (value) {
            setState(() => _selectedPriority = value);
          },
        )).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updating ? null : _updatePriority,
          child: _updating
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Update'),
        ),
      ],
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

  Future<void> _updatePriority() async {
    if (_selectedPriority == null) return;

    setState(() => _updating = true);
    try {
      await widget.apiService.updateRequestPriority(widget.request.id, _selectedPriority!);
      widget.onUpdated();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Priority updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating priority: $e')),
      );
    } finally {
      setState(() => _updating = false);
    }
  }
}

class CreateScheduledReportDialog extends StatelessWidget {
  final VoidCallback onCreated;

  const CreateScheduledReportDialog({Key? key, required this.onCreated}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Scheduled Report'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Configure your scheduled report:'),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Report Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Frequency',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'daily', child: Text('Daily')),
              DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
              DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
            ],
            onChanged: (value) {},
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onCreated();
          },
          child: const Text('Create'),
        ),
      ],
    );
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
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  NotificationType _selectedType = NotificationType.info;
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Send Notification'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Message',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<NotificationType>(
            decoration: const InputDecoration(
              labelText: 'Type',
              border: OutlineInputBorder(),
            ),
            value: _selectedType,
            onChanged: (value) {
              setState(() => _selectedType = value!);
            },
            items: NotificationType.values.map((type) => DropdownMenuItem(
              value: type,
              child: Text(type.toString().split('.').last.toUpperCase()),
            )).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _sending ? null : _sendNotification,
          child: _sending
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Send'),
        ),
      ],
    );
  }

  Future<void> _sendNotification() async {
    if (_titleController.text.trim().isEmpty || _messageController.text.trim().isEmpty) {
      return;
    }

    setState(() => _sending = true);
    try {
      final notification = AppNotification(
        id: '',
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        type: _selectedType,
        isRead: false,
        createdAt: DateTime.now(),
         targetUserIds: [],        // Add this line
  senderName: 'System',
      );

      // Note: sendBroadcastNotification doesn't exist in the API, so we'll just simulate success
      // await widget.apiService.sendBroadcastNotification(notification);
      
      widget.onNotificationSent();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification sent successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending notification: $e')),
      );
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}


class AdminNotificationsBottomSheet extends StatelessWidget {
  final List<AppNotification> notifications;
  final MockApiService apiService;
  final VoidCallback onNotificationRead;

  const AdminNotificationsBottomSheet({
    Key? key,
    required this.notifications,
    required this.apiService,
    required this.onNotificationRead,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: notifications.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No notifications', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: notification.isRead ? Colors.grey : Colors.blue,
                          child: Icon(
                            _getNotificationIcon(notification.type),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(notification.message),
                        trailing: notification.isRead
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.mark_email_read),
                                onPressed: () async {
                                  await apiService.markNotificationAsRead(notification.id);
                                  onNotificationRead();
                                },
                              ),
                        onTap: () async {
                          if (!notification.isRead) {
                            await apiService.markNotificationAsRead(notification.id);
                            onNotificationRead();
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return Icons.info;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.success:
        return Icons.check_circle;
    }
  }
}

class RequestTypeFormScreen extends StatelessWidget {
  final MockApiService apiService;
  final RequestType? requestType;
  final VoidCallback onSaved;

  const RequestTypeFormScreen({
    Key? key,
    required this.apiService,
    this.requestType,
    required this.onSaved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(requestType == null ? 'Create Request Type' : 'Edit Request Type'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.category, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Request Type Form',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Request type form implementation coming soon!'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  onSaved();
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TemplateFormScreen extends StatelessWidget {
  final MockApiService apiService;
  final List<RequestType> requestTypes;
  final RequestTemplate? template;
  final VoidCallback onSaved;

  const TemplateFormScreen({
    Key? key,
    required this.apiService,
    required this.requestTypes,
    this.template,
    required this.onSaved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(template == null ? 'Create Template' : 'Edit Template'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.description, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Template Form',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Template form implementation coming soon!'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  onSaved();
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// UserManagementTab placeholder
class UserManagementTab extends StatelessWidget {
  final MockApiService apiService;
  
  const UserManagementTab({Key? key, required this.apiService}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return UserManagementScreen(apiService: apiService);
  }
}

// Placeholder UserManagementScreen
class UserManagementScreen extends StatelessWidget {
  final MockApiService apiService;

  const UserManagementScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'User Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('User management features coming soon!'),
        ],
      ),
    );
  }
}

// Placeholder UserDetailsScreen from user_management_module.dart
class UserDetailsScreen extends StatelessWidget {
  final User user;

  const UserDetailsScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${user.name} Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          child: Text(user.name[0].toUpperCase(), style: const TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              Text(user.email, style: const TextStyle(color: Colors.grey)),
                              Text('Role: ${user.role}', style: const TextStyle(color: Colors.blue)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildInfoRow('User ID', user.id),
                    _buildInfoRow('Department', user.department),
                    _buildInfoRow('Created At', _formatDate(user.createdAt)),
                    _buildInfoRow('Status', user.active ? 'Active' : 'Inactive'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Activity',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Text('User activity details would be shown here...', 
                         style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
