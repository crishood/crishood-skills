#!/usr/bin/env bash
# Transcribe audio with whisper.cpp (Metal/M2, English + Spanish)
# Usage: smoke.sh <audio_file> [language] [output_format]
#   language: en | es | auto  (default: auto)
#   output_format: txt | vtt | srt | json | all  (default: txt to stdout)
#
# Examples:
#   smoke.sh recording.mp3
#   smoke.sh recording.wav es
#   smoke.sh interview.mp3 en txt
#   smoke.sh audio.wav auto srt

set -euo pipefail

WHISPER_DIR="/Users/sircrishood/Chia/whisper.cpp"
WHISPER_BIN="$WHISPER_DIR/build/bin/whisper-cli"
WHISPER_MODEL="$WHISPER_DIR/models/ggml-small.bin"

# ── argument parsing ────────────────────────────────────────────────────────
AUDIO="${1:-}"
LANG="${2:-auto}"
OUTPUT_FMT="${3:-}"

if [ -z "$AUDIO" ]; then
  echo "Usage: $0 <audio_file> [language: en|es|auto] [output_format: txt|vtt|srt|json]" >&2
  exit 1
fi

if [ ! -f "$AUDIO" ]; then
  echo "Error: audio file not found: $AUDIO" >&2
  exit 1
fi

# ── model selection ─────────────────────────────────────────────────────────
# Override with WHISPER_MODEL env var to use a different model
WHISPER_MODEL="${WHISPER_MODEL_OVERRIDE:-$WHISPER_MODEL}"
if [ ! -f "$WHISPER_MODEL" ]; then
  echo "Error: model not found: $WHISPER_MODEL" >&2
  echo "Run: bash $WHISPER_DIR/models/download-ggml-model.sh small" >&2
  exit 1
fi

# ── build whisper-cli args ──────────────────────────────────────────────────
ARGS=(-m "$WHISPER_MODEL" -f "$AUDIO" --no-timestamps)

if [ "$LANG" = "auto" ]; then
  ARGS+=(-l auto)
else
  ARGS+=(-l "$LANG")
fi

case "${OUTPUT_FMT:-}" in
  txt)  ARGS+=(--output-txt) ;;
  vtt)  ARGS+=(--output-vtt) ;;
  srt)  ARGS+=(--output-srt) ;;
  json) ARGS+=(--output-json) ;;
  all)  ARGS+=(--output-txt --output-vtt --output-srt --output-json) ;;
  "")   ;; # stdout only (default)
  *)    echo "Unknown output format: $OUTPUT_FMT (use txt|vtt|srt|json|all)" >&2; exit 1 ;;
esac

# ── run ─────────────────────────────────────────────────────────────────────
"$WHISPER_BIN" "${ARGS[@]}" 2>/dev/null
