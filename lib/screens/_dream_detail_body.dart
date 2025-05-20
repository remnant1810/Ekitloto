import 'dart:core';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'dart:async';
import '../models/audio_recording.dart';
import '../main.dart';
import 'package:hive/hive.dart';

/// Colors
const appBarBg = Color(0xff1c2331);



class DreamDetailBody extends StatefulWidget {
  final Dream dream;
  const DreamDetailBody({Key? key, required this.dream}) : super(key: key);

  @override
  State<DreamDetailBody> createState() => _DreamDetailBodyState();
}

/// Widget to display and play a saved audio file for a dream
class _AudioPlaybackWidget extends StatefulWidget {
  final AudioRecording audio;
  const _AudioPlaybackWidget({Key? key, required this.audio}) : super(key: key);

  @override
  State<_AudioPlaybackWidget> createState() => _AudioPlaybackWidgetState();
}

class _AudioPlaybackWidgetState extends State<_AudioPlaybackWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _progress = 0.0;
      });
    });
    _audioPlayer.onPositionChanged.listen((pos) {
      setState(() {
        _progress = widget.audio.durationSeconds > 0 ? pos.inSeconds / widget.audio.durationSeconds : 0.0;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.play(DeviceFileSource(widget.audio.path));
      setState(() => _isPlaying = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (widget.audio.durationSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (widget.audio.durationSeconds % 60).toString().padLeft(2, '0');
    return Row(
      children: [
        IconButton(
          icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
          onPressed: _togglePlay,
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 4,
            backgroundColor: Colors.grey[700],
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 8),
        Text('$minutes:$seconds', style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

// The following is the restored _DreamDetailBodyState class

class _DreamDetailBodyState extends State<DreamDetailBody> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;
  late List<String> _tags;
  final TextEditingController _tagInputController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final recorder = AudioRecorder();
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _audioPath;
  int? _audioDuration;
  double _playbackProgress = 0.0;

  bool _editMode = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    _recordingTimer?.cancel();
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.dream.title);
    _descriptionController = TextEditingController(text: widget.dream.description);
    _notesController = TextEditingController();
    _tags = List.from(widget.dream.tags);
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

  void _addTag() {
    final tag = _tagInputController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagInputController.clear();
      });
    }
  }

  Widget _buildAudioEditControls() {
    if (_isRecording) {
      final minutes = (_recordingSeconds ~/ 60).toString().padLeft(2, '0');
      final seconds = (_recordingSeconds % 60).toString().padLeft(2, '0');
      return Row(
        children: [
          Icon(Icons.mic, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 8),
          Text('$minutes:$seconds', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.stop, color: Theme.of(context).colorScheme.secondary),
            onPressed: _toggleRecording,
          ),
        ],
      );
    } 
    else if (_audioPath != null || widget.dream.audio != null) {
      final duration = _audioDuration ?? widget.dream.audio?.durationSeconds ?? 0;
      final path = _audioPath ?? widget.dream.audio?.path;
      final minutes = (duration ~/ 60).toString().padLeft(2, '0');
      final seconds = (duration % 60).toString().padLeft(2, '0');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                onPressed: () async {
                  if (_isPlaying) {
                    await _audioPlayer.stop();
                    setState(() => _isPlaying = false);
                  } else if (path != null) {
                    await _audioPlayer.play(DeviceFileSource(path));
                    setState(() => _isPlaying = true);
                    _audioPlayer.onPlayerComplete.listen((event) {
                      setState(() => _isPlaying = false);
                    });
                    _audioPlayer.onPositionChanged.listen((pos) {
                      setState(() {
                        _playbackProgress = duration > 0 ? pos.inSeconds / duration : 0.0;
                      });
                    });
                  }
                },
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: _playbackProgress,
                  minHeight: 4,
                  backgroundColor: Colors.grey[700],
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
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
          ),
        ],
      );
    } 
    else {
      return IconButton(
        icon: Icon(Icons.mic, color: Theme.of(context).colorScheme.secondary),
        onPressed: _toggleRecording,
      );
    }
  }

  void _enterEditMode() {
    setState(() {
      _editMode = true;
      _notesController.text = widget.dream.notes ?? '';
    });
  }

  void _saveEdits() {
    widget.dream.title = _titleController.text;
    widget.dream.description = _descriptionController.text;
    widget.dream.tags = List.from(_tags);
    widget.dream.notes = _notesController.text;
    Hive.box<Dream>('dreams').put(widget.dream.id, widget.dream);
    setState(() {
      _editMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Dream updated'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: appBarBg,
      ),
    );
  }

  void _cancelEdits() {
    setState(() {
      _editMode = false;
      _titleController.text = widget.dream.title;
      _descriptionController.text = widget.dream.description;
      _notesController.text = widget.dream.notes ?? '';
      _tags = List.from(widget.dream.tags);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_editMode)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.edit_square, color: Theme.of(context).colorScheme.secondary),
                    tooltip: 'Edit',
                    onPressed: _enterEditMode,
                  ),
                ),
              _editMode
                  ? Form(
                      key: GlobalKey<FormState>(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date selector at the top
                          GestureDetector(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: widget.dream.date,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null && picked != widget.dream.date) {
                                setState(() {
                                  widget.dream.date = picked;
                                });
                              }
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('MMMM d, yyyy').format(widget.dream.date),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('EEEE').format(widget.dream.date),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
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
                            decoration: const InputDecoration(
                              hintText: 'How was your dream?',
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
                            minLines: 8,
                            maxLines: 12,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a description';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          // Audio controls (record, playback, waveform)
                          _buildAudioEditControls(),
                          const SizedBox(height: 8),
                          // Tag input
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _tagInputController,
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
                                  onSubmitted: (value) => _addTag(),
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
                                  onDeleted: () {
                                    setState(() {
                                      _tags.remove(tag);
                                    });
                                  },
                                  backgroundColor: Theme.of(context).colorScheme.secondary.withAlpha(50),
                                  deleteIconColor: Theme.of(context).colorScheme.secondary,
                                )).toList(),
                          ),
                          // Notes Section
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor.withAlpha(5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: _notesController,
                              decoration: const InputDecoration(
                                hintText: 'Notes',
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
                              minLines: 8,
                              maxLines: 12,
                              style: TextStyle(color: Theme.of(context).hintColor),
                            ),
                          ),                         
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _titleController.text,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.normal, fontFamily: 'Montserrat'),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            DateFormat('MMMM d, yyyy').format(widget.dream.date),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), // Added padding for description
                          child: Text(
                            _descriptionController.text,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (widget.dream.audio != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _AudioPlaybackWidget(audio: widget.dream.audio!),
                          ),
                        if (_tags.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _tags.map((tag) => Text(
                                tag,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Montserrat',
                                ),
                              )).toList(),
                            ),
                          ),
                      ],
                    ),
              if (_editMode)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _cancelEdits,
                      child: const Text('Cancel', style: TextStyle(color: Colors.white, fontFamily: 'Montserrat')),
                    ),
                    ElevatedButton(
                      onPressed: _saveEdits,
                      child: const Text('Save', style: TextStyle(fontFamily: 'Montserrat')),
                    )
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}