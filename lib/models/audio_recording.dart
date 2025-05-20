import 'package:hive/hive.dart';

part 'audio_recording.g.dart';

@HiveType(typeId: 1)
class AudioRecording {
  @HiveField(0)
  final String path;
  @HiveField(1)
  final int durationSeconds;
  @HiveField(2)
  final DateTime createdAt;

  AudioRecording({
    required this.path,
    required this.durationSeconds,
    required this.createdAt,
  });
}
