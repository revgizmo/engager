# Local Session Transcription Workflow

This folder contains the tooling required to generate Zoom-style transcripts
from raw session recordings entirely on your local workstation. The workflow is
based on [OpenAI Whisper](https://github.com/openai/whisper) for speech-to-text
and the [pyannote](https://huggingface.co/pyannote) diarization pipeline for
speaker attribution. The resulting `.transcript.vtt` files are compatible with
`engager`'s analytics functions.

## Quick start

1. **Create a Python virtual environment** (Python 3.9+ recommended):
   ```bash
   python -m venv .venv-transcription
   source .venv-transcription/bin/activate
   ```
2. **Install PyTorch and torchaudio** following the official
   [installation selector](https://pytorch.org/get-started/locally/) for your
   platform (choose CPU or GPU builds as appropriate).
3. **Install workflow dependencies**:
   ```bash
   pip install -r scripts/transcription/requirements.txt
   ```
4. **Provide a Hugging Face token** with access to `pyannote/speaker-diarization`:
   ```bash
   export HUGGINGFACE_TOKEN="hf_your_read_token"
   ```
5. **Ensure FFmpeg is available** (e.g. `brew install ffmpeg` on macOS or
   `sudo apt-get install ffmpeg` on Debian/Ubuntu).
6. **Run the transcription script** against one or more recordings:
   ```bash
   python scripts/transcription/transcribe_session.py \
     recordings/session01.mp4 recordings/session02.m4a \
     --output-dir data/local_transcripts \
     --model medium
   ```

The script writes `*.transcript.vtt` files (and optional metadata JSON) to the
chosen output directory. The default location `data/local_transcripts` mirrors
the structure expected by the analysis scripts in `scripts/real_world_testing`.

## Command reference

`transcribe_session.py` accepts the following options:

| Flag | Description |
| --- | --- |
| `--model` | Whisper model size (`tiny`, `base`, `small`, `medium`, `large`). Larger models improve accuracy but require more compute. |
| `--language` | Force a specific language code (e.g. `en`) instead of auto-detect. |
| `--device` | Override the compute device (`cpu`, `cuda`, `mps`). Auto-detect favours GPU if available. |
| `--hf-token` | Provide a Hugging Face token explicitly; otherwise `HUGGINGFACE_TOKEN` or `HF_TOKEN` env vars are used. |
| `--diarization-model` | Alternate Hugging Face pipeline for speaker diarization. |
| `--num-speakers` | Hint the diarization pipeline with a fixed speaker count. |
| `--speaker-map` | JSON/YAML file mapping diarization labels (e.g. `SPEAKER_00`) to canonical names. |
| `--extensions` | Extra file extensions when scanning directories for inputs. |
| `--skip-json` | Skip writing JSON metadata alongside the VTT output. |
| `--skip-diarization` | Disable diarization and emit generic speaker labels (useful when pyannote is unavailable). |
| `--verbose` | Emit detailed logs for debugging. |

## Output artefacts

For each input recording the script produces:

- `<basename>.transcript.vtt` – WebVTT transcript compatible with Zoom exports
- `<basename>.transcript.json` – (optional) machine-readable metadata with
  segment timings, diarization overlap, and aggregate speaking time summaries

## Speaker remapping

Diarization labels typically look like `SPEAKER_00`, `SPEAKER_01`, etc. Provide a
mapping file to replace these labels with roster-friendly names. Example
`speaker_map.yaml`:

```yaml
SPEAKER_00: Instructor
SPEAKER_01: Student A
SPEAKER_02: Student B
```

Run the script with `--speaker-map speaker_map.yaml` to apply the mapping.

## Troubleshooting

- **`ModuleNotFoundError: No module named 'torch'`** – Install PyTorch and
  torchaudio before installing the requirements file.
- **`HTTP 401` from pyannote** – Verify that your Hugging Face token has access
  to the diarization model and is exported in the shell session.
- **Long processing times** – Switch to a smaller Whisper model or run on GPU.
- **Poor diarization separation** – Supply `--num-speakers` with the expected
  number of voices, or experiment with alternative diarization checkpoints.

