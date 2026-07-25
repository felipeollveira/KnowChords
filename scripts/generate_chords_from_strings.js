// Gera os WAVs de acorde misturando os samples reais das 6 cordas do violão.
// Usa resampling linear (mesma operação que playbackRate no browser):
//   rate = 2^(fret/12)  →  leitura acelerada do sample = pitch mais alto
//
// Convenção: string_0.wav = Mi grave (E2), string_5.wav = Mi agudo (E4)
// Voicings: [lowE, A, D, G, B, highE]   -1 = muda/silenciada

const fs   = require('fs');
const path = require('path');

// ── Leitura de WAV (PCM 16-bit stereo) ───────────────────────────────────────

function readWav(filePath) {
  const buf = fs.readFileSync(filePath);
  if (buf.toString('ascii', 0, 4) !== 'RIFF') throw new Error('Not RIFF: ' + filePath);

  let numChannels, sampleRate, bitsPerSample;
  let dataOffset = -1, dataSize = -1;
  let offset = 12;

  while (offset < buf.length - 8) {
    const id   = buf.toString('ascii', offset, offset + 4);
    const size = buf.readUInt32LE(offset + 4);
    if (id === 'fmt ') {
      numChannels   = buf.readUInt16LE(offset + 10);
      sampleRate    = buf.readUInt32LE(offset + 12);
      bitsPerSample = buf.readUInt16LE(offset + 22);
    } else if (id === 'data') {
      dataOffset = offset + 8;
      dataSize   = size;
    }
    offset += 8 + size + (size % 2); // word-align
  }

  const bytesPerSample = bitsPerSample / 8;
  const numSamples = Math.floor(dataSize / (bytesPerSample * numChannels));
  const out = new Float64Array(numSamples);

  for (let i = 0; i < numSamples; i++) {
    let s = 0;
    for (let c = 0; c < numChannels; c++) {
      s += buf.readInt16LE(dataOffset + (i * numChannels + c) * 2) / 32768;
    }
    out[i] = s / numChannels; // downmix to mono
  }
  return { samples: out, sampleRate };
}

// ── Escrita de WAV (PCM 16-bit mono) ─────────────────────────────────────────

function writeWav(samples, filePath, sampleRate = 44100) {
  const n       = samples.length;
  const dataSz  = n * 2;
  const buf     = Buffer.alloc(44 + dataSz);
  buf.write('RIFF', 0, 'ascii');
  buf.writeUInt32LE(36 + dataSz, 4);
  buf.write('WAVE', 8, 'ascii');
  buf.write('fmt ', 12, 'ascii');
  buf.writeUInt32LE(16, 16);
  buf.writeUInt16LE(1, 20);           // PCM
  buf.writeUInt16LE(1, 22);           // mono
  buf.writeUInt32LE(sampleRate, 24);
  buf.writeUInt32LE(sampleRate * 2, 28);
  buf.writeUInt16LE(2, 32);
  buf.writeUInt16LE(16, 34);
  buf.write('data', 36, 'ascii');
  buf.writeUInt32LE(dataSz, 40);
  for (let i = 0; i < n; i++) {
    buf.writeInt16LE(Math.round(Math.max(-1, Math.min(1, samples[i])) * 32767), 44 + i * 2);
  }
  fs.writeFileSync(filePath, buf);
}

// ── Resampling com interpolação linear ────────────────────────────────────────

function resample(src, rate) {
  if (rate === 1.0) return src;
  const outLen = Math.floor(src.length / rate);
  const out    = new Float64Array(outLen);
  for (let i = 0; i < outLen; i++) {
    const pos  = i * rate;
    const idx  = Math.floor(pos);
    const frac = pos - idx;
    out[i] = idx + 1 < src.length
      ? src[idx] * (1 - frac) + src[idx + 1] * frac
      : src[idx] ?? 0;
  }
  return out;
}

// ── Voicings ──────────────────────────────────────────────────────────────────
// Formato: [lowE, A, D, G, B, highE]   -1 = corda muda

const VOICINGS = {
  // Maior — apenas nomes naturais e bemóis (sem 's' de sustenido)
  'C':  [-1,  3,  2,  0,  1,  0],
  'Db': [-1,  4,  3,  1,  2,  1],  // C# = Db
  'D':  [-1, -1,  0,  2,  3,  2],
  'Eb': [-1, -1,  1,  3,  4,  3],  // D# = Eb
  'E':  [ 0,  2,  2,  1,  0,  0],
  'F':  [ 1,  3,  3,  2,  1,  1],
  'Gb': [ 2,  4,  4,  3,  2,  2],  // F# = Gb
  'G':  [ 3,  2,  0,  0,  0,  3],
  'Ab': [ 4,  6,  6,  5,  4,  4],  // G# = Ab
  'A':  [-1,  0,  2,  2,  2,  0],
  'Bb': [-1,  1,  3,  3,  3,  1],  // A# = Bb
  'B':  [-1,  2,  4,  4,  4,  2],
  // Menor
  'Cm':  [-1,  3,  5,  5,  4,  3],
  'Dbm': [-1,  4,  6,  6,  5,  4],  // C#m = Dbm
  'Dm':  [-1, -1,  0,  2,  3,  1],
  'Ebm': [-1, -1,  1,  3,  4,  2],  // D#m = Ebm
  'Em':  [ 0,  2,  2,  0,  0,  0],
  'Fm':  [ 1,  3,  3,  1,  1,  1],
  'Gbm': [ 2,  4,  4,  2,  2,  2],  // F#m = Gbm
  'Gm':  [ 3,  5,  5,  3,  3,  3],
  'Abm': [ 4,  6,  6,  4,  4,  4],  // G#m = Abm
  'Am':  [-1,  0,  2,  2,  1,  0],
  'Bbm': [-1,  1,  3,  3,  2,  1],  // A#m = Bbm
  'Bm':  [-1,  2,  4,  4,  3,  2],
};

// ── Configuração ──────────────────────────────────────────────────────────────

const SAMPLE_RATE  = 44100;
const DURATION_S   = 3.5;
const NUM_SAMPLES  = Math.floor(SAMPLE_RATE * DURATION_S);
const STRUM_MS     = 18; // ms entre cada corda (baixo → agudo)

const rootDir    = path.resolve(__dirname, '..');
const stringsDir = path.join(rootDir, 'assets', 'audio', 'strings');
const chordsDir  = path.join(rootDir, 'assets', 'audio', 'chords');
fs.mkdirSync(chordsDir, { recursive: true });

// ── Carrega os 6 samples ──────────────────────────────────────────────────────

console.log('Carregando samples das cordas...');
const strings = [];
for (let i = 0; i < 6; i++) {
  const { samples } = readWav(path.join(stringsDir, `string_${i}.wav`));
  strings.push(samples);
  const dur = (samples.length / SAMPLE_RATE).toFixed(2);
  console.log(`  string_${i}.wav  →  ${dur}s  (${samples.length} amostras)`);
}

// ── Gera os acordes ───────────────────────────────────────────────────────────

console.log(`\nGerando ${Object.keys(VOICINGS).length} WAVs de acorde...\n`);

for (const [name, frets] of Object.entries(VOICINGS)) {
  const out = new Float64Array(NUM_SAMPLES);

  frets.forEach((fret, i) => {
    if (fret < 0) return; // corda muda

    const rate         = Math.pow(2, fret / 12);
    const strumOffset  = Math.floor((i * STRUM_MS * SAMPLE_RATE) / 1000);
    const shifted      = resample(strings[i], rate);
    const available    = Math.min(shifted.length, NUM_SAMPLES - strumOffset);
    // Cordas mais graves um pouco mais altas
    const vol          = 0.85 + (5 - i) * 0.025;

    for (let n = 0; n < available; n++) {
      out[n + strumOffset] += shifted[n] * vol;
    }
  });

  // Normaliza para pico 0.88
  let peak = 0;
  for (let n = 0; n < NUM_SAMPLES; n++) if (Math.abs(out[n]) > peak) peak = Math.abs(out[n]);
  if (peak > 0) {
    const scale = 0.88 / peak;
    for (let n = 0; n < NUM_SAMPLES; n++) out[n] *= scale;
  }

  writeWav(out, path.join(chordsDir, `${name}.wav`));
  console.log(`  OK  ${name}.wav`);
}

console.log(`\nPronto! ${Object.keys(VOICINGS).length} arquivos em ${chordsDir}`);
