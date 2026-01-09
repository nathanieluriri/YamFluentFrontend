import 'dart:async';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart' as record;

class AudioRecorderService {
  final record.AudioRecorder _record = record.AudioRecorder();
  StreamSubscription<record.Amplitude>? _amplitudeSub;
  final StreamController<double> _amplitudeController =
      StreamController<double>.broadcast();
  Stream<record.Amplitude>? _amplitudeStream;

  String? _currentWavPath;

  Stream<double> get amplitudeStream => _amplitudeController.stream;

  Future<bool> hasPermission() => _record.hasPermission();

  Future<String?> startRecording(String fileBaseName) async {
    final hasPermission = await _record.hasPermission();
    if (!hasPermission) return null;
    final directory = await getTemporaryDirectory();
    final wavPath = '${directory.path}/$fileBaseName.wav';
    _currentWavPath = wavPath;
    await _record.start(
      const record.RecordConfig(
        encoder: record.AudioEncoder.wav,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: wavPath,
    );
    _amplitudeSub?.cancel();
    _amplitudeStream ??= _record
        .onAmplitudeChanged(const Duration(milliseconds: 120))
        .asBroadcastStream();
    _amplitudeSub = _amplitudeStream!.listen(
      (amplitude) {
        final normalized = _normalizeAmplitude(amplitude.current);
        _amplitudeController.add(normalized);
      },
    );
    return wavPath;
  }

  Future<String?> stopRecordingAndConvert(String fileBaseName) async {
    await _record.stop();
    await _amplitudeSub?.cancel();
    _amplitudeSub = null;
    _amplitudeController.add(0);
    if (_currentWavPath == null) return null;
    final directory = await getTemporaryDirectory();
    final mp3Path = '${directory.path}/$fileBaseName.mp3';
    final result = await FFmpegKit.execute(
      '-y -i "${_currentWavPath!}" -codec:a libmp3lame -qscale:a 2 "$mp3Path"',
    );
    final code = await result.getReturnCode();
    if (ReturnCode.isSuccess(code)) {
      return mp3Path;
    }
    return null;
  }

  Future<void> cancelRecording() async {
    await _record.stop();
    await _amplitudeSub?.cancel();
    _amplitudeSub = null;
    _amplitudeController.add(0);
    if (_currentWavPath != null) {
      final file = File(_currentWavPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }
    _currentWavPath = null;
  }

  double _normalizeAmplitude(double db) {
    final clamped = db.clamp(-60, 0);
    return (clamped + 60) / 60;
  }

  Future<void> dispose() async {
    await _amplitudeSub?.cancel();
    await _amplitudeController.close();
    await _record.dispose();
  }
}

final audioRecorderServiceProvider = Provider<AudioRecorderService>((ref) {
  final service = AudioRecorderService();
  ref.onDispose(service.dispose);
  return service;
});
