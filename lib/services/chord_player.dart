import 'package:audioplayers/audioplayers.dart';

class ChordPlayer {
  static const Map<String, String> _chordFiles = {
    'C': 'C',    'C#': 'Db',  'Db': 'Db',
    'D': 'D',    'D#': 'Eb',  'Eb': 'Eb',
    'E': 'E',    'F': 'F',    'F#': 'Gb',  'Gb': 'Gb',
    'G': 'G',    'G#': 'Ab',  'Ab': 'Ab',
    'A': 'A',    'A#': 'Bb',  'Bb': 'Bb',  'B': 'B',
    'Cm': 'Cm',  'C#m': 'Dbm', 'Dbm': 'Dbm',
    'Dm': 'Dm',  'D#m': 'Ebm', 'Ebm': 'Ebm',
    'Em': 'Em',  'Fm': 'Fm',  'F#m': 'Gbm', 'Gbm': 'Gbm',
    'Gm': 'Gm',  'G#m': 'Abm', 'Abm': 'Abm',
    'Am': 'Am',  'A#m': 'Bbm', 'Bbm': 'Bbm', 'Bm': 'Bm',
  };

  final AudioPlayer _player = AudioPlayer();


  Future<void> playChord(String chordName) async {
    final fileName = _chordFiles[chordName];
    if (fileName == null) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/chords/$fileName.wav', mimeType: 'audio/wav'));
    } catch (_) {}
  }

  Future<void> stop() async {
    await _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}
