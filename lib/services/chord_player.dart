import 'package:audioplayers/audioplayers.dart';

// Audio files needed in assets/audio/chords/
// Major: C.mp3 Cs.mp3 D.mp3 Eb.mp3 E.mp3 F.mp3 Fs.mp3 G.mp3 Ab.mp3 A.mp3 Bb.mp3 B.mp3
// Minor: Cm.mp3 Csm.mp3 Dm.mp3 Dsm.mp3 Em.mp3 Fm.mp3 Fsm.mp3 Gm.mp3 Gsm.mp3 Am.mp3 Asm.mp3 Bbm.mp3 Bm.mp3
// Free guitar/piano chord samples: freesound.org, sampleswap.org, or record your own.
class ChordPlayer {
  static const Map<String, String> _chordFiles = {
    'C': 'C',    'C#': 'Cs',  'Db': 'Cs',
    'D': 'D',    'D#': 'Ds',  'Eb': 'Eb',
    'E': 'E',    'F': 'F',    'F#': 'Fs',  'Gb': 'Fs',
    'G': 'G',    'G#': 'Gs',  'Ab': 'Ab',
    'A': 'A',    'A#': 'As',  'Bb': 'Bb',  'B': 'B',
    'Cm': 'Cm',  'C#m': 'Csm', 'Dbm': 'Csm',
    'Dm': 'Dm',  'D#m': 'Dsm', 'Ebm': 'Dsm',
    'Em': 'Em',  'Fm': 'Fm',  'F#m': 'Fsm',
    'Gm': 'Gm',  'G#m': 'Gsm', 'Abm': 'Gsm',
    'Am': 'Am',  'A#m': 'Asm', 'Bbm': 'Bbm', 'Bm': 'Bm',
  };

  final AudioPlayer _player = AudioPlayer();

  Future<void> playChord(String chordName) async {
    final fileName = _chordFiles[chordName];
    if (fileName == null) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/chords/$fileName.mp3'));
    } catch (_) {}
  }

  Future<void> stop() async {
    await _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}
