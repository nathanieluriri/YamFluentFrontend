import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../authentication/data/auth_local_data_source.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  final AuthLocalDataSource _authLocalDataSource;
  String? _currentUrl;

  AudioPlayerService(this._authLocalDataSource);

  String? get currentUrl => _currentUrl;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Future<bool> toggle(String url) async {
    if (_currentUrl == url && _player.playing) {
      await _player.pause();
      return false;
    }
    if (_currentUrl != url) {
      _currentUrl = url;
      await _player.setUrl(url);
    }
    await _player.play();
    return true;
  }

  Future<bool> toggleWithAuth(String url) async {
    debugPrint('AudioPlayerService.toggleWithAuth url=$url');
    final resolvedUrl = _normalizeAudioUrl(url);
    debugPrint('AudioPlayerService.toggleWithAuth resolvedUrl=$resolvedUrl');
    if (_currentUrl == url && _player.playing) {
      await _player.pause();
      return false;
    }
    final token = await _authLocalDataSource.getAccessToken();
    final headers = <String, String>{
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    _currentUrl = resolvedUrl;
    await _player.setUrl(resolvedUrl, headers: headers);
    await _player.play();
    return true;
  }

  String _normalizeAudioUrl(String url) {
    if (url.startsWith('https://')) return url;
    if (url.startsWith('http://api-yamfluent.uriri.com.ng')) {
      return url.replaceFirst('http://', 'https://');
    }
    return url;
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService(ref.watch(authLocalDataSourceProvider));
  ref.onDispose(service.dispose);
  return service;
});
