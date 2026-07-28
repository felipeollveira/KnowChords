class ChordShape {
  final List<int> frets; // [str6, str5, str4, str3, str2, str1]; -1=muted, 0=open, N=absolute fret
  final int baseFret; // fret where diagram starts (1 = nut)
  final int? barreString; // lowest string index (0-5) of barre, null if no barre
  const ChordShape(this.frets, {this.baseFret = 1, this.barreString});
}

const Map<String, ChordShape> kChordShapes = {
  // ── Major chords ──────────────────────────────────────────────────────────
  'A': ChordShape([-1, 0, 2, 2, 2, 0]),
  'Ab': ChordShape([4, 6, 6, 5, 4, 4], baseFret: 4, barreString: 0),
  'B': ChordShape([-1, 2, 4, 4, 4, 2], baseFret: 2, barreString: 1),
  'Bb': ChordShape([-1, 1, 3, 3, 3, 1], barreString: 1),
  'C': ChordShape([-1, 3, 2, 0, 1, 0]),
  'C#': ChordShape([-1, 4, 6, 6, 6, 4], baseFret: 4, barreString: 1),
  'Db': ChordShape([-1, 4, 6, 6, 6, 4], baseFret: 4, barreString: 1),
  'D': ChordShape([-1, -1, 0, 2, 3, 2]),
  'E': ChordShape([0, 2, 2, 1, 0, 0]),
  'Eb': ChordShape([-1, 6, 8, 8, 8, 6], baseFret: 6, barreString: 1),
  'F': ChordShape([1, 3, 3, 2, 1, 1], barreString: 0),
  'F#': ChordShape([2, 4, 4, 3, 2, 2], baseFret: 2, barreString: 0),
  'G': ChordShape([3, 2, 0, 0, 0, 3]),
  'G#': ChordShape([4, 6, 6, 5, 4, 4], baseFret: 4, barreString: 0),

  // ── Minor chords ──────────────────────────────────────────────────────────
  'Am': ChordShape([-1, 0, 2, 2, 1, 0]),
  'A#m': ChordShape([-1, 1, 3, 3, 2, 1], barreString: 1),
  'Bbm': ChordShape([-1, 1, 3, 3, 2, 1], barreString: 1),
  'Bm': ChordShape([-1, 2, 4, 4, 3, 2], baseFret: 2, barreString: 1),
  'C#m': ChordShape([-1, 4, 6, 6, 5, 4], baseFret: 4, barreString: 1),
  'Cm': ChordShape([-1, 3, 5, 5, 4, 3], baseFret: 3, barreString: 1),
  'D#m': ChordShape([-1, 6, 8, 8, 7, 6], baseFret: 6, barreString: 1),
  'Dm': ChordShape([-1, -1, 0, 2, 3, 1]),
  'Em': ChordShape([0, 2, 2, 0, 0, 0]),
  'Fm': ChordShape([1, 3, 3, 1, 1, 1], barreString: 0),
  'F#m': ChordShape([2, 4, 4, 2, 2, 2], baseFret: 2, barreString: 0),
  'Gm': ChordShape([3, 5, 5, 3, 3, 3], baseFret: 3, barreString: 0),
  'G#m': ChordShape([4, 6, 6, 4, 4, 4], baseFret: 4, barreString: 0),
};
