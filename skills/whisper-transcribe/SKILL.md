---
name: whisper-transcribe
description: transcribe audio files to text using whisper.cpp; run whisper, transcribe speech, convert audio to text, speech recognition, transcribir audio, transcripción de voz, english, spanish, español
---

Transcribe audio files (wav, mp3, ogg, flac) to text using whisper.cpp with Metal GPU acceleration on Apple M2. Supports English, Spanish, and auto-detection. The driver is `skills/whisper-transcribe/smoke.sh` in crishood-skills, and whisper.cpp lives at `/Users/sircrishood/Chia/whisper.cpp/`.

## Prerequisites

Already installed and built (no action needed on this machine):

- whisper.cpp compiled at `/Users/sircrishood/Chia/whisper.cpp/build/bin/whisper-cli`
- Metal GPU enabled (Apple M2 Pro, verified in build)
- Model: `ggml-small.bin` (465 MB, multilingual, at `/Users/sircrishood/Chia/whisper.cpp/models/`)
- cmake installed via Homebrew

If running on a new machine, see **Setup from scratch** below.

## Transcribe (agent path)

Use the smoke script directly:

```bash
# Auto-detect language (recommended for mixed or unknown content)
bash /Users/sircrishood/Chia/crishood-skills/skills/whisper-transcribe/smoke.sh <audio_file>

# Explicit English
bash /Users/sircrishood/Chia/crishood-skills/skills/whisper-transcribe/smoke.sh <audio_file> en

# Explicit Spanish
bash /Users/sircrishood/Chia/crishood-skills/skills/whisper-transcribe/smoke.sh <audio_file> es

# Save as SRT subtitle file (output saved next to audio file)
bash /Users/sircrishood/Chia/crishood-skills/skills/whisper-transcribe/smoke.sh <audio_file> es srt

# All output formats at once (txt, vtt, srt, json)
bash /Users/sircrishood/Chia/crishood-skills/skills/whisper-transcribe/smoke.sh <audio_file> auto all
```

Output formats: `txt` | `vtt` | `srt` | `json` | `all`. Without format argument, transcript goes to stdout.

Output files are saved next to the audio file with the same base name (e.g. `recording.mp3` → `recording.txt`).

## Transcribe (direct whisper-cli)

```bash
WHISPER=/Users/sircrishood/Chia/whisper.cpp
$WHISPER/build/bin/whisper-cli \
  -m $WHISPER/models/ggml-small.bin \
  -f <audio_file> \
  -l en \
  --no-timestamps
```

Key flags:
- `-l en` / `-l es` / `-l auto` — language (auto = detect automatically)
- `--translate` — translate non-English audio to English
- `--output-srt` / `--output-txt` / `--output-vtt` / `--output-json` — save to file
- `-t 8` — use 8 threads (default 4; M2 Pro has 10 logical cores)
- `--word-thold 0.01` — word timestamp confidence threshold

## Available models

| Model | Size | Speed on M2 | Quality |
|-------|------|-------------|---------|
| tiny | 75 MB | ~0.2s/11s audio | Low |
| base | 142 MB | ~0.3s | OK |
| small | 465 MB | ~1s | Good ← installed |
| medium | 1.5 GB | ~3s | Better |
| large-v3 | 3 GB | ~8s | Best |

Download a different model:
```bash
bash /Users/sircrishood/Chia/whisper.cpp/models/download-ggml-model.sh medium
```

Use it by overriding the model path:
```bash
WHISPER_MODEL_OVERRIDE=/Users/sircrishood/Chia/whisper.cpp/models/ggml-medium.bin \
  bash /Users/sircrishood/Chia/crishood-skills/skills/whisper-transcribe/smoke.sh audio.mp3
```

## Setup from scratch (new machine)

```bash
# 1. Install cmake
brew install cmake

# 2. Build whisper.cpp with Metal
cd /Users/sircrishood/Chia/whisper.cpp
cmake -B build -DGGML_METAL=ON -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release -j$(sysctl -n hw.logicalcpu)

# 3. Download model
bash models/download-ggml-model.sh small
```

## Gotchas

- **Metal GPU family warning `ggml_metal_device_init: tensor API disabled for pre-M5`** — normal on M2, Metal still runs via the standard API. Transcription is still GPU-accelerated. Not an error.
- **Audio must be mono or stereo WAV/MP3/OGG/FLAC** — whisper-cli resamples internally to 16kHz mono. If you get a decode error, convert first: `ffmpeg -i input.m4a -ar 16000 -ac 1 output.wav`
- **`--detect-language` flag** — doesn't output transcript, just detects. Use `-l auto` instead to both detect and transcribe in the original language.
- **Output files land next to the audio file** — not in the current directory. If the audio is in a read-only location, pass a temp copy.
- **First run takes ~10s to load Metal library** (`ggml_metal_library_init: loaded in 8.5 sec`). Subsequent runs in the same session are fast.
- **`say` on macOS exports AIFF** — convert to WAV with `afconvert file.aiff file.wav -f WAVE -d LEI16@16000` or `ffmpeg -i file.aiff -ar 16000 -ac 1 file.wav`.

## Troubleshooting

**`cmake not found`** → `brew install cmake`

**`whisper-cli: command not found`** → Build hasn't been done. Run the Setup from scratch steps above.

**`Error: model not found`** → Run `bash /Users/sircrishood/Chia/whisper.cpp/models/download-ggml-model.sh small`

**Blank output / no transcription** → Audio might be too short (<1s) or silent. Check with `ffprobe audio.wav`.

**`read_audio_data: failed to open`** → Format not supported or file is corrupt. Convert with ffmpeg first.
