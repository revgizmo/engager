#!/usr/bin/env python3
"""Transcribe session recordings into Zoom-style transcripts.

This script combines OpenAI Whisper for speech-to-text transcription with a
Hugging Face diarization pipeline (pyannote.audio) to assign speaker labels.
The output is a `.transcript.vtt` file compatible with the engager analytics
pipeline, plus an optional JSON metadata dump for further processing.

Example usage::

    python scripts/transcription/transcribe_session.py \
        data/recordings/session01.mp4 \
        --output-dir data/local_transcripts \
        --model medium \
        --hf-token $HUGGINGFACE_TOKEN

Requirements:
    * FFmpeg available on PATH
    * PyTorch + torchaudio (install via https://pytorch.org/get-started/locally/)
    * `pip install -r scripts/transcription/requirements.txt`
    * A Hugging Face access token with rights to `pyannote/speaker-diarization`

"""
from __future__ import annotations

import argparse
import json
import logging
import os
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Sequence


LOGGER = logging.getLogger("transcribe_session")


def configure_logging(verbose: bool = False) -> None:
    """Configure root logging for console output."""
    level = logging.DEBUG if verbose else logging.INFO
    logging.basicConfig(
        level=level,
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    )


def format_timestamp(seconds: float) -> str:
    """Convert seconds to a WebVTT timestamp (HH:MM:SS.mmm)."""
    seconds = max(0.0, float(seconds))
    milliseconds = int(round(seconds * 1000))
    hours, remainder = divmod(milliseconds, 3_600_000)
    minutes, remainder = divmod(remainder, 60_000)
    secs, millis = divmod(remainder, 1000)
    return f"{hours:02d}:{minutes:02d}:{secs:02d}.{millis:03d}"


def ensure_directory(path: Path) -> None:
    """Create path parent directories when necessary."""
    path.parent.mkdir(parents=True, exist_ok=True)


def load_speaker_mapping(mapping_path: Optional[Path]) -> Dict[str, str]:
    """Load optional speaker mapping from YAML or JSON."""
    if mapping_path is None:
        return {}

    import yaml  # Local import to avoid mandatory dependency if unused

    with mapping_path.open("r", encoding="utf-8") as handle:
        if mapping_path.suffix.lower() in {".yaml", ".yml"}:
            data = yaml.safe_load(handle)
        else:
            data = json.load(handle)

    if not isinstance(data, dict):  # pragma: no cover - defensive
        raise ValueError("Speaker mapping must be a dictionary of label -> name")

    # Normalise keys for quick lookups
    return {str(key): str(value) for key, value in data.items()}


def discover_audio_inputs(inputs: Sequence[str], extensions: Iterable[str]) -> List[Path]:
    """Expand a mix of files and directories into concrete audio paths."""
    allowed = {ext.lower() for ext in extensions}
    discovered: List[Path] = []
    for raw in inputs:
        path = Path(raw).expanduser().resolve()
        if not path.exists():
            LOGGER.warning("Input %s does not exist and will be skipped", path)
            continue
        if path.is_dir():
            for candidate in sorted(path.rglob("*")):
                if candidate.suffix.lower() in allowed:
                    discovered.append(candidate)
        else:
            if path.suffix.lower() in allowed:
                discovered.append(path)
            else:
                LOGGER.warning("Skipping %s (unsupported extension)", path)
    return discovered


def select_device(preferred: Optional[str] = None) -> str:
    """Return the compute device used by Whisper."""
    if preferred:
        return preferred
    try:
        import torch

        if torch.cuda.is_available():
            return "cuda"
        if torch.backends.mps.is_available():  # type: ignore[attr-defined]
            return "mps"
    except Exception:  # pragma: no cover - torch optional during doc builds
        pass
    return "cpu"


def load_whisper_model(model_size: str, device: str):
    import whisper

    LOGGER.info("Loading Whisper model '%s' on %s", model_size, device)
    return whisper.load_model(model_size, device=device)


def run_whisper(model, audio_path: Path, language: Optional[str] = None, temperature: float = 0.0):
    """Execute Whisper transcription and return the raw result."""
    kwargs = {
        "task": "transcribe",
        "language": language,
        "temperature": temperature,
        "condition_on_previous_text": False,
        "fp16": False,
    }
    LOGGER.debug("Transcribing %s with Whisper", audio_path)
    result = model.transcribe(str(audio_path), **kwargs)
    return result


def load_diarization_pipeline(model_name: str, token: str):
    from pyannote.audio import Pipeline

    LOGGER.info("Loading diarization pipeline '%s'", model_name)
    return Pipeline.from_pretrained(model_name, use_auth_token=token)


def run_diarization(pipeline, audio_path: Path, speaker_count: Optional[int] = None):
    kwargs = {}
    if speaker_count is not None and speaker_count > 0:
        kwargs["num_speakers"] = speaker_count
    LOGGER.debug("Running diarization on %s", audio_path)
    diarization = pipeline(str(audio_path), **kwargs)
    segments = []
    for segment, _, speaker in diarization.itertracks(yield_label=True):
        segments.append(
            {
                "start": float(segment.start),
                "end": float(segment.end),
                "speaker": str(speaker),
            }
        )
    segments.sort(key=lambda item: item["start"])
    return segments


def compute_overlap(a_start: float, a_end: float, b_start: float, b_end: float) -> float:
    return max(0.0, min(a_end, b_end) - max(a_start, b_start))


def assign_speakers(
    whisper_segments: Sequence[dict],
    diarization_segments: Sequence[dict],
    speaker_mapping: Dict[str, str],
) -> List[dict]:
    """Attach diarization speaker labels to Whisper segments."""
    assigned: List[dict] = []
    for segment in whisper_segments:
        start = float(segment.get("start", 0.0))
        end = float(segment.get("end", start))
        duration = max(end - start, 1e-6)
        text = segment.get("text", "").strip()
        best_label: Optional[str] = None
        best_overlap = 0.0
        for diar in diarization_segments:
            overlap = compute_overlap(start, end, diar["start"], diar["end"])
            if overlap > best_overlap:
                best_overlap = overlap
                best_label = diar["speaker"]
        if best_label is None:
            if diarization_segments:
                best_label = diarization_segments[0]["speaker"]
                best_overlap = compute_overlap(start, end, diarization_segments[0]["start"], diarization_segments[0]["end"])
            else:
                best_label = "Speaker_00"
        mapped = speaker_mapping.get(best_label, best_label)
        assigned.append(
            {
                "start": start,
                "end": end,
                "text": text,
                "speaker": mapped,
                "speaker_label": best_label,
                "speaker_overlap": round(best_overlap / duration, 3),
                "avg_logprob": segment.get("avg_logprob"),
                "compression_ratio": segment.get("compression_ratio"),
                "no_speech_prob": segment.get("no_speech_prob"),
            }
        )
    return assigned


def summarise_speakers(segments: Sequence[dict]) -> Dict[str, float]:
    summary: Dict[str, float] = {}
    for segment in segments:
        duration = float(segment["end"]) - float(segment["start"])
        summary[segment["speaker"]] = summary.get(segment["speaker"], 0.0) + max(duration, 0.0)
    return summary


def write_vtt(segments: Sequence[dict], output_path: Path) -> None:
    ensure_directory(output_path)
    with output_path.open("w", encoding="utf-8") as handle:
        handle.write("WEBVTT\n\n")
        for idx, segment in enumerate(segments, start=1):
            start = format_timestamp(segment["start"])
            end = format_timestamp(segment["end"])
            text = segment["text"].replace("\n", " ").strip()
            speaker = segment["speaker"]
            handle.write(f"{idx}\n")
            handle.write(f"{start} --> {end}\n")
            handle.write(f"{speaker}: {text}\n\n")
    LOGGER.info("Wrote VTT transcript to %s", output_path)


def write_json(metadata: dict, output_path: Path) -> None:
    ensure_directory(output_path)
    with output_path.open("w", encoding="utf-8") as handle:
        json.dump(metadata, handle, indent=2)
    LOGGER.debug("Wrote metadata to %s", output_path)


def process_file(
    audio_path: Path,
    whisper_model,
    diarization_pipeline,
    speaker_mapping: Dict[str, str],
    output_dir: Path,
    language: Optional[str],
    temperature: float,
    speaker_count: Optional[int],
    emit_json: bool,
) -> None:
    LOGGER.info("Processing %s", audio_path)
    whisper_result = run_whisper(whisper_model, audio_path, language, temperature)
    diarization_segments: List[dict] = []
    if diarization_pipeline is not None:
        diarization_segments = run_diarization(diarization_pipeline, audio_path, speaker_count)
    else:
        LOGGER.warning("No diarization pipeline configured; using placeholder speaker labels")
    segments = assign_speakers(whisper_result.get("segments", []), diarization_segments, speaker_mapping)
    base_name = audio_path.stem
    vtt_path = output_dir / f"{base_name}.transcript.vtt"
    write_vtt(segments, vtt_path)

    if emit_json:
        summary = summarise_speakers(segments)
        metadata = {
            "audio_file": str(audio_path),
            "model": whisper_model.name if hasattr(whisper_model, "name") else None,
            "language": whisper_result.get("language"),
            "segments": segments,
            "speaker_summary_seconds": summary,
        }
        json_path = output_dir / f"{base_name}.transcript.json"
        write_json(metadata, json_path)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "inputs",
        nargs="+",
        help="Audio files or directories containing recordings",
    )
    parser.add_argument(
        "--output-dir",
        default="data/local_transcripts",
        help="Directory where transcripts will be written",
    )
    parser.add_argument(
        "--model",
        default="medium",
        help="Whisper model size (tiny, base, small, medium, large)",
    )
    parser.add_argument(
        "--language",
        default=None,
        help="Force Whisper language (e.g. 'en'); defaults to auto-detect",
    )
    parser.add_argument(
        "--temperature",
        type=float,
        default=0.0,
        help="Temperature for Whisper decoding (higher -> more diverse)",
    )
    parser.add_argument(
        "--device",
        default=None,
        help="Compute device override for Whisper (cpu, cuda, mps)",
    )
    parser.add_argument(
        "--hf-token",
        default=None,
        help="Hugging Face access token (falls back to HUGGINGFACE_TOKEN env)",
    )
    parser.add_argument(
        "--diarization-model",
        default="pyannote/speaker-diarization-3.1",
        help="Hugging Face model id used for diarization",
    )
    parser.add_argument(
        "--num-speakers",
        type=int,
        default=None,
        help="Optional fixed number of speakers to guide diarization",
    )
    parser.add_argument(
        "--speaker-map",
        type=Path,
        default=None,
        help="JSON or YAML mapping from diarization labels to canonical names",
    )
    parser.add_argument(
        "--extensions",
        nargs="+",
        default=[".mp3", ".mp4", ".m4a", ".wav", ".aac"],
        help="Audio/video extensions to scan when directories are provided",
    )
    parser.add_argument(
        "--skip-json",
        action="store_true",
        help="Skip writing JSON metadata alongside the VTT output",
    )
    parser.add_argument(
        "--skip-diarization",
        action="store_true",
        help="Disable speaker diarization (every segment labelled generically)",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Increase log verbosity",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    configure_logging(args.verbose)

    output_dir = Path(args.output_dir).expanduser().resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    speaker_mapping = load_speaker_mapping(args.speaker_map)

    device = select_device(args.device)
    whisper_model = load_whisper_model(args.model, device)

    diarization_pipeline = None
    if not args.skip_diarization:
        token = args.hf_token or os.environ.get("HUGGINGFACE_TOKEN") or os.environ.get("HF_TOKEN")
        if not token:
            raise SystemExit("A Hugging Face token is required unless --skip-diarization is provided.")
        diarization_pipeline = load_diarization_pipeline(args.diarization_model, token)
    else:
        LOGGER.warning("Diarization disabled via --skip-diarization")

    inputs = discover_audio_inputs(args.inputs, args.extensions)
    if not inputs:
        raise SystemExit("No audio files discovered. Check the provided paths and extensions.")

    for audio_path in inputs:
        try:
            process_file(
                audio_path=audio_path,
                whisper_model=whisper_model,
                diarization_pipeline=diarization_pipeline,
                speaker_mapping=speaker_mapping,
                output_dir=output_dir,
                language=args.language,
                temperature=args.temperature,
                speaker_count=args.num_speakers,
                emit_json=not args.skip_json,
            )
        except Exception as exc:  # pragma: no cover - runtime safety
            LOGGER.exception("Failed to process %s: %s", audio_path, exc)


if __name__ == "__main__":  # pragma: no cover
    main()
