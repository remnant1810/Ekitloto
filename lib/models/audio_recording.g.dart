// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_recording.dart';

class AudioRecordingAdapter extends TypeAdapter<AudioRecording> {
  @override
  final int typeId = 1;

  @override
  AudioRecording read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return AudioRecording(
      path: fields[0] as String,
      durationSeconds: fields[1] as int,
      createdAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AudioRecording obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.path)
      ..writeByte(1)
      ..write(obj.durationSeconds)
      ..writeByte(2)
      ..write(obj.createdAt);
  }
}
