const fs = require('fs');
const path = require('path');

const SAMPLE_RATE = 44100;
const DURATION = 3.5;
const NUM_SAMPLES = Math.floor(SAMPLE_RATE * DURATION);

function midiToFreq(midi) {
  return 440.0 * Math.pow(2, (midi - 69) / 12);
}

// Karplus-Strong plucked string synthesis
function karplusStrong(freq, numSamples, damping) {
  const N = Math.max(2, Math.round(SAMPLE_RATE / freq));

  // Initialize ring buffer with white noise, then pre-filter for a warmer tone
  const buf = new Float64Array(N);
  for (let i = 0; i < N; i++) buf[i] = Math.random() * 2 - 1;
  for (let pass = 0; pass < 2; pass++) {
    for (let i = 0; i < N; i++) {
      buf[i] = 0.5 * (buf[i] + buf[(i + 1) % N]);
    }
  }

  const out = new Float64Array(numSamples);
  for (let n = 0; n < numSamples; n++) {
    const ptr = n % N;
    const nextPtr = (n + 1) % N;
    out[n] = buf[ptr];
    buf[ptr] = damping * 0.5 * (buf[ptr] + buf[nextPtr]);
  }
  return out;
}

// Compute damping to reach ~-60dB after `t60` seconds
function computeDamping(freq, t60 = 2.5) {
  const N = Math.round(SAMPLE_RATE / freq);
  return Math.exp(-Math.log(1000) * N / (t60 * SAMPLE_RATE));
}

function writeWav(samples, filePath) {
  const n = samples.length;
  const dataSize = n * 2;
  const buf = Buffer.alloc(44 + dataSize);

  buf.write('RIFF', 0, 'ascii');
  buf.writeUInt32LE(36 + dataSize, 4);
  buf.write('WAVE', 8, 'ascii');
  buf.write('fmt ', 12, 'ascii');
  buf.writeUInt32LE(16, 16);
  buf.writeUInt16LE(1, 20);   // PCM
  buf.writeUInt16LE(1, 22);   // mono
  buf.writeUInt32LE(SAMPLE_RATE, 24);
  buf.writeUInt32LE(SAMPLE_RATE * 2, 28);
  buf.writeUInt16LE(2, 32);
  buf.writeUInt16LE(16, 34);
  buf.write('data', 36, 'ascii');
  buf.writeUInt32LE(dataSize, 40);

  for (let i = 0; i < n; i++) {
    const v = Math.max(-1, Math.min(1, samples[i]));
    buf.writeInt16LE(Math.round(v * 32767), 44 + i * 2);
  }

  fs.writeFileSync(filePath, buf);
}

// Build a strummed chord: strings plucked one by one from bass to treble
function generateGuitarChord(midiNotes) {
  const out = new Float64Array(NUM_SAMPLES);
  const strumIntervalMs = 18; // ms between each string

  midiNotes.forEach((midi, i) => {
    const freq = midiToFreq(midi);
    const damping = computeDamping(freq, 2.5);
    const offsetSamples = Math.floor((i * strumIntervalMs * SAMPLE_RATE) / 1000);
    const stringSamples = NUM_SAMPLES - offsetSamples;
    if (stringSamples <= 0) return;

    const sig = karplusStrong(freq, stringSamples, damping);

    // Bass strings slightly louder
    const vol = 0.85 + (midiNotes.length - 1 - i) * 0.03;
    for (let n = 0; n < stringSamples; n++) {
      out[n + offsetSamples] += sig[n] * vol;
    }
  });

  // Normalize to 0.88 peak
  let peak = 0;
  for (let i = 0; i < NUM_SAMPLES; i++) peak = Math.max(peak, Math.abs(out[i]));
  if (peak > 0) {
    const scale = 0.88 / peak;
    for (let i = 0; i < NUM_SAMPLES; i++) out[i] *= scale;
  }

  return out;
}

// Guitar-style voicings: [bass, low-mid, mid, high-mid, treble]
// Root in the C3–B3 range (MIDI 48–59) so bass sits around C2–B2
const NOTE_MIDI = {
  'C': 48, 'Cs': 49, 'D': 50, 'Ds': 51, 'Eb': 51,
  'E': 52, 'F': 53, 'Fs': 54, 'G': 55,
  'Gs': 56, 'Ab': 56, 'A': 57, 'As': 58, 'Bb': 58, 'B': 59,
};

function majorVoicing(root) {
  return [root - 12, root, root + 4, root + 7, root + 12, root + 16];
}

function minorVoicing(root) {
  return [root - 12, root, root + 3, root + 7, root + 12, root + 15];
}

const chords = [
  // Major — usa nomes bemóis para sustenidos (Db=C#, Eb=D#, Gb=F#, Ab=G#, Bb=A#)
  { file: 'C',  root: 'C',  minor: false },
  { file: 'Db', root: 'Cs', minor: false },
  { file: 'D',  root: 'D',  minor: false },
  { file: 'Eb', root: 'Eb', minor: false },
  { file: 'E',  root: 'E',  minor: false },
  { file: 'F',  root: 'F',  minor: false },
  { file: 'Gb', root: 'Fs', minor: false },
  { file: 'G',  root: 'G',  minor: false },
  { file: 'Ab', root: 'Ab', minor: false },
  { file: 'A',  root: 'A',  minor: false },
  { file: 'Bb', root: 'Bb', minor: false },
  { file: 'B',  root: 'B',  minor: false },
  // Minor
  { file: 'Cm',  root: 'C',  minor: true },
  { file: 'Dbm', root: 'Cs', minor: true },
  { file: 'Dm',  root: 'D',  minor: true },
  { file: 'Ebm', root: 'Ds', minor: true },
  { file: 'Em',  root: 'E',  minor: true },
  { file: 'Fm',  root: 'F',  minor: true },
  { file: 'Gbm', root: 'Fs', minor: true },
  { file: 'Gm',  root: 'G',  minor: true },
  { file: 'Abm', root: 'Gs', minor: true },
  { file: 'Am',  root: 'A',  minor: true },
  { file: 'Bbm', root: 'Bb', minor: true },
  { file: 'Bm',  root: 'B',  minor: true },
];

const outputDir = path.resolve(__dirname, '..', 'assets', 'audio', 'chords');
fs.mkdirSync(outputDir, { recursive: true });

console.log('Generating guitar chord sounds (Karplus-Strong)...\n');

for (const { file, root, minor } of chords) {
  const rootMidi = NOTE_MIDI[root];
  const voicing = minor ? minorVoicing(rootMidi) : majorVoicing(rootMidi);
  const samples = generateGuitarChord(voicing);
  writeWav(samples, path.join(outputDir, `${file}.wav`));
  console.log(`  OK  ${file}.wav`);
}

console.log(`\nDone! ${chords.length} files in ${outputDir}`);
