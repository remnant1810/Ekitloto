import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'main.dart';

class DreamFormScreen extends StatefulWidget {
  final Dream? dream;
  final bool isEditing;

  const DreamFormScreen({
    Key? key,
    this.dream,
    this.isEditing = false,
  }) : super(key: key);

  @override
  _DreamFormScreenState createState() => _DreamFormScreenState();
}

class _DreamFormScreenState extends State<DreamFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final TextEditingController _tagController = TextEditingController();
  late DateTime _selectedDate;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    
    if (widget.isEditing && widget.dream != null) {
      _titleController = TextEditingController(text: widget.dream!.title);
      _descriptionController = TextEditingController(text: widget.dream!.description);
      _selectedDate = widget.dream!.date;
      _tags = List.from(widget.dream!.tags);
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedDate = DateTime.now();
      _tags = [];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text.trim());
        _tagController.clear();
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveDream() {
    if (_formKey.currentState!.validate()) {
      final dreamBox = Hive.box<Dream>('dreams');
      
      if (widget.isEditing && widget.dream != null) {
        final existingDreamKey = dreamBox.keyAt(
          dreamBox.values.toList().indexWhere((d) => d.id == widget.dream!.id)
        );
        
        final updatedDream = widget.dream!;
        updatedDream.title = _titleController.text;
        updatedDream.description = _descriptionController.text;
        updatedDream.date = _selectedDate;
        updatedDream.tags = List.from(_tags);
        
        dreamBox.put(existingDreamKey, updatedDream);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dream updated successfully')),
        );
      } else {
        final newDream = Dream(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          description: _descriptionController.text,
          date: _selectedDate,
          tags: List.from(_tags),
        );
        
        dreamBox.add(newDream);
      }
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Dream' : 'Add New Dream'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Dream Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Dream Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Dream Date'),
                subtitle: Text(DateFormat('EEEE, MMM d, yyyy').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              const Text('Tags',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        labelText: 'Add a tag',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addTag(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addTag,
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _tags.remove(tag);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveDream,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(widget.isEditing ? 'UPDATE DREAM' : 'SAVE DREAM'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddDreamScreen extends StatelessWidget {
  const AddDreamScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const DreamFormScreen(isEditing: false);
  }
}

class EditDreamScreen extends StatelessWidget {
  final Dream dream;

  const EditDreamScreen({Key? key, required this.dream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DreamFormScreen(
      dream: dream,
      isEditing: true,
    );
  }
}

class DreamDetailScreen extends StatelessWidget {
  final Dream dream;

  const DreamDetailScreen({Key? key, required this.dream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dream.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Dream'),
                  content: const Text('Are you sure you want to delete this dream?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () {
                        final dreamBox = Hive.box<Dream>('dreams');
                        final dreamIndex = dreamBox.values.toList().indexWhere(
                          (d) => d.id == dream.id,
                        );
                        if (dreamIndex != -1) {
                          dreamBox.deleteAt(dreamIndex);
                        }
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Return to list
                      },
                      child: const Text('DELETE'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('EEEE, MMM d, yyyy').format(dream.date),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dream.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    if (dream.tags.isNotEmpty) ...[
                      const Text(
                        'Tags',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: dream.tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha:0.3),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditDreamScreen(dream: dream),
            ),
          );
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}
