import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../main.dart';
import 'package:uuid/uuid.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import '../models/audio_recording.dart';

/// Colors
const appBarBg = Color(0xff1c2331);

class AddDreamScreen extends StatefulWidget {
  const AddDreamScreen({Key? key}) : super(key: key);

  @override
  _AddDreamScreenState createState() => _AddDreamScreenState();
}

class _AddDreamScreenState extends State<AddDreamScreen> {
  final TextEditingController _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];
  DateTime _selectedDate = DateTime.now();

  // Audio recording state
  final recorder = AudioRecorder();
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  bool _isRecording = false;
  String? _audioPath;
  int? _audioDuration;
  bool _isPlaying = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _notesController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    _recordingTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await recorder.stop();
      _recordingTimer?.cancel();
      setState(() {
        _isRecording = false;
        _audioPath = path;
        _audioDuration = _recordingSeconds;
      });
    } else {
      if (await recorder.hasPermission()) {
        // Use path_provider to get directory if needed, or just let record handle the path
        final filePath = '/storage/emulated/0/Download/dream_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: filePath,
        );
        setState(() {
          _isRecording = true;
          _recordingSeconds = 0;
        });
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordingSeconds++;
            if (_recordingSeconds >= 600) {
              _toggleRecording();
            }
          });
        });
      }
    }
  }

  Widget _buildAudioControls() {
    if (_isRecording) {
      final minutes = (_recordingSeconds ~/ 60).toString().padLeft(2, '0');
      final seconds = (_recordingSeconds % 60).toString().padLeft(2, '0');
      return Row(
        children: [
          const Icon(Icons.mic, color: Colors.red),
          const SizedBox(width: 8),
          Text('$minutes:$seconds', style: const TextStyle(color: Colors.red)),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.stop, color: Colors.red),
            onPressed: _toggleRecording,
          ),
        ],
      );
    } else if (_audioPath != null) {
      final minutes = ((_audioDuration ?? 0) ~/ 60).toString().padLeft(2, '0');
      final seconds = ((_audioDuration ?? 0) % 60).toString().padLeft(2, '0');
      return Row(
        children: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
            onPressed: () async {
              if (_isPlaying) {
                await _audioPlayer.stop();
                setState(() => _isPlaying = false);
              } else {
                if (_audioPath != null) {
                  await _audioPlayer.play(DeviceFileSource(_audioPath!));
                  setState(() => _isPlaying = true);
                  _audioPlayer.onPlayerComplete.listen((event) {
                    setState(() => _isPlaying = false);
                  });
                }
              }
            },
          ),
          Text('$minutes:$seconds', style: const TextStyle(color: Colors.white)),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                _audioPath = null;
                _audioDuration = null;
              });
            },
          ),
        ],
      );
    } else {
      return IconButton(
        icon: Icon(Icons.mic, color: Theme.of(context).colorScheme.secondary),
        onPressed: _toggleRecording,
      );
    }
  }



  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
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

  String _formatDate(DateTime date) {
    // Example: April 23, 2025
    return "${_monthName(date.month)} ${date.day}, ${date.year}";
  }

  String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

  String _getDayOfWeek(DateTime date) {
    const days = [
      'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
    ];
    return days[date.weekday % 7];
  }

  void _saveDream() {
    if (_formKey.currentState!.validate()) {
      AudioRecording? audio;
      if (_audioPath != null && _audioDuration != null) {
        audio = AudioRecording(
          path: _audioPath!,
          durationSeconds: _audioDuration!,
          createdAt: DateTime.now(),
        );
      }
      final dream = Dream(
        id: const Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        date: _selectedDate,
        tags: _tags,
        audio: audio,
        notes: _notesController.text,
      );

      final dreamBox = Hive.box<Dream>('dreams');
      dreamBox.put(dream.id, dream);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Dream added'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: appBarBg,
        ),
      );
      Future.delayed(const Duration(milliseconds: 400), () {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveDream,
            style: TextButton.styleFrom(
              textStyle: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
              ),
              foregroundColor: Theme.of(context).colorScheme.secondary,
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),            
            child: const Text('Save'),
          ),
        ],
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date selector at the top
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(_selectedDate),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getDayOfWeek(_selectedDate),
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
              // Borderless Title Field
              TextFormField(
                controller: _titleController,
                style: Theme.of(context).textTheme.titleLarge,
                decoration: const InputDecoration(
                  hintText: 'Untitled',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.all(5),
                  fillColor: Colors.transparent,
                  filled: true,
                  hoverColor: Colors.transparent,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              // Borderless Description Field
              TextFormField(
                controller: _descriptionController,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: const InputDecoration(
                  hintText: 'Describe your dream...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.all(5),
                  fillColor: Colors.transparent,
                  filled: true,
                  hoverColor: Colors.transparent,
                ),
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              
              // Speech-to-Text Placeholder
              Row(
                children: [
                  _buildAudioControls(),
                ],
              ),
              const SizedBox(height: 8),
              // Borderless Tag Input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        hintText: 'Add tags',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.all(5),
                        fillColor: Colors.transparent,
                        filled: true,
                        hoverColor: Colors.transparent,
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) _addTag();
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Theme.of(context).colorScheme.secondary),
                    onPressed: _addTag,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Display tags as chips
              Wrap(
                spacing: 8.0,
                children: _tags.map((tag) => Chip(
                  label: Text(tag),
                  onDeleted: () => _removeTag(tag),
                  backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha:0.2),
                )).toList(),
              ),  
              // Notes Field
              TextFormField(
                controller: _notesController,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: const InputDecoration(
                  hintText: 'Additional notes (optional)...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.all(5),
                  fillColor: Colors.transparent,
                  filled: true,
                  hoverColor: Colors.transparent,
                ),
                maxLines: null,
              ),               
            ],
          ),
        ),
      ),
    );
  }
}
