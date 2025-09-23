# Session transcription workflow

## CI-based process assessment

- The repository currently assumes that Zoom-style `.transcript.vtt` files are
  provided ahead of time. Both the package README and the real-world testing
  harness focus on consuming transcripts that already exist rather than
  generating them through automation.
- No GitHub Actions workflow or script in `scripts/` is responsible for
  invoking Whisper or another speech-to-text service; instead, guidance tells
  contributors to copy transcript exports into the working directory manually.
  This indicates the CI pipeline does not currently own transcription and is
  limited to analysis once transcripts are available.
- Because transcripts are captured outside of the repository, secrets management
  (e.g. Whisper API keys, Hugging Face tokens, Box credentials) is not modelled
  in CI. The existing documentation therefore cannot guarantee reproducible
  transcription runs or data provenance for new recordings.

## Local transcription workflow

To close the gap, the repository now ships a self-contained local transcription
pipeline under `scripts/transcription/`. The workflow is based on
OpenAI Whisper for transcription and the `pyannote` diarization pipeline for
speaker attribution, producing `.transcript.vtt` files that slot directly into
existing analyses.

Key capabilities:

- **Single command execution** – `transcribe_session.py` accepts individual
  files or directories and processes each into a Zoom-compatible transcript with
  optional JSON metadata for auditing and downstream tooling.
- **Speaker labelling** – Diarization output is merged with Whisper segments,
  with optional YAML/JSON mappings to translate diarization labels into roster
  names used elsewhere in the project.
- **Configurable runtime** – Command-line switches expose model size, device
  selection, diarization parameters, and output location so contributors can
  balance accuracy, runtime, and hardware constraints.

## How to run locally

A detailed quick-start guide covers environment setup, dependency installation,
FFmpeg requirements, and practical command examples for generating transcripts
from raw recordings. The default
output location `data/local_transcripts` mirrors the structure expected by the
existing real-world testing workflow, making integration straightforward.

## Operational considerations

- PyTorch/torchaudio binaries are intentionally excluded from
  `requirements.txt` to let contributors install the appropriate GPU/CPU build
  for their platform before pulling the remaining Python dependencies.
- Hugging Face authentication is handled through the `HUGGINGFACE_TOKEN`
  environment variable (or the `--hf-token` flag), and diarization can be skipped
  when working offline or without token access, albeit with generic speaker
  labels.

