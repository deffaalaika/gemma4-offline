# gemma4-offline

Offline installer for the Ollama model **`gemma4:12b`** on macOS, for machines
where `ollama.com` / `registry.ollama.ai` is blocked but GitHub is reachable.

The model files are attached to the
[`gemma4-12b` release](../../releases/tag/gemma4-12b) as a zip split into
parts (GitHub limits release assets to 2 GB each). No GitHub login is needed.

## Requirements

- macOS with Ollama installed (`brew install ollama`), recent enough to support gemma4
  (check with `ollama --version`)
- ~25 GB free disk during install (parts + joined zip + unzipped files + installed model);
  ~8 GB after cleanup

## Install (one command)

```bash
curl -fLO https://raw.githubusercontent.com/deffaalaika/gemma4-offline/main/get-gemma4.sh
bash get-gemma4.sh
```

The script downloads the parts into `./gemma4-download`, verifies SHA-256 checksums,
joins and unzips them, copies the model into `~/.ollama/models`
(or `$OLLAMA_MODELS`), restarts the brew `ollama` service, and checks `ollama list`.
Re-running it resumes and skips parts already downloaded.

Then:

```bash
ollama run gemma4:12b
```

Afterwards you can delete the `gemma4-download` folder.

## Install (manual, via browser)

1. From the release, download `SHA256SUMS` and every `gemma4-12b-offline.zip.part-*` into one folder.
2. Download `get-gemma4.sh` into the same folder and run it with that folder:
   ```bash
   bash get-gemma4.sh .
   ```
   Or by hand:
   ```bash
   cat gemma4-12b-offline.zip.part-* > gemma4-12b-offline.zip
   shasum -a 256 -c SHA256SUMS --ignore-missing
   unzip gemma4-12b-offline.zip
   bash gemma4-12b-offline/install.sh
   ```

## What's in the model package

Pulled unmodified from the Ollama registry (`registry.ollama.ai/library/gemma4:12b`):

| Layer | Size |
|---|---|
| Model weights (q4_K_M GGUF) | 7.4 GB |
| Draft model (speculative decoding) | 465 MB |
| Vision projector | 175 MB |
| Config, template, params, license | < 1 MB |

## License

Gemma 4 model weights are licensed under the Apache License 2.0 by Google; the license
text is included in the package (`models/blobs/sha256-0d542e0c…`) and in [`LICENSE-GEMMA`](LICENSE-GEMMA).
The scripts in this repo are provided as-is.
