import 'package:audioplayers/audioplayers.dart';

class SpiritualAudioManager {
  static final SpiritualAudioManager _instance = SpiritualAudioManager._internal();
  factory SpiritualAudioManager() => _instance;

  SpiritualAudioManager._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isMuted = false;

  bool get isMuted => _isMuted;
  bool get isPlaying => _isPlaying;

  Future<void> iniciarAmbiente() async {
    if (_isPlaying) return;
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(_isMuted ? 0.0 : 0.55); // Volumen místico y suave
      await _player.play(AssetSource('audio/mystic.wav'));
      _isPlaying = true;
    } catch (e) {
      print('Error al reproducir audio ambiental: $e');
    }
  }

  Future<void> detenerAmbiente() async {
    if (!_isPlaying) return;
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (_) {}
  }

  Future<void> pausarAmbiente() async {
    if (!_isPlaying) return;
    try {
      await _player.pause();
    } catch (_) {}
  }

  Future<void> reanudarAmbiente() async {
    if (!_isPlaying) return;
    try {
      await _player.resume();
    } catch (_) {}
  }

  Future<void> alternarMute() async {
    _isMuted = !_isMuted;
    try {
      await _player.setVolume(_isMuted ? 0.0 : 0.55);
    } catch (_) {}
  }
}
