# red-team-lab
[![CI](https://github.com/your-org/red-team-lab/actions/workflows/ci.yml/badge.svg)](../../actions) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A safe, portfolio‑ready **Red Teaming Project** that demonstrates planning, execution, and detection engineering in a controlled lab. It ships a Typer-based CLI for benign simulations, ATT&CK mappings, detections (KQL + Sigma), docs (MkDocs), CI, and a devcontainer.

> **Safety first:** All actions are **benign** by design and include guardrails to prevent accidental execution on non‑lab hosts. Use only in isolated environments you own.

## ✨ Features
- **Typer CLI**: `redlab` with subcommands for recon and “lateral” *simulations*.
- **ATT&CK mapping**: Each technique annotated in code, docs, and detections.
- **Detections**: Sample **KQL** and **Sigma** rules with rationale.
- **Docs site**: MkDocs Material, ready to publish.
- **Hardened repo**: SECURITY.md, Code of Conduct, CI for lint/test.
- **Dev experience**: Makefile, Dockerfile, and VS Code devcontainer.

## 🏁 Quick Start
### Option A — Python (pip)
```bash
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -e ".[dev]"
redlab --help
```

### Option B — uv (faster)
```bash
uv venv && source .venv/bin/activate
uv pip install -e ".[dev]"
redlab --help
```

### Run a safe recon sim
```bash
redlab recon --targets 10.0.0.5,10.0.0.6 --label demo1
```

### Generate a faux lateral-movement trace (benign)
```bash
redlab lateral --user alice --host 10.0.0.9 --label demo2
```

## 🧰 What gets installed
- `redlab` (Typer CLI)
- Docs at `docs/` (serve with `mkdocs serve`)
- Detections: `detections/kql`, `detections/sigma`

## 🧪 Testing
```bash
pytest -q
```

## 🛠️ Make targets
```bash
make install   # pip install -e ".[dev]"
make lint      # ruff + mypy (where applicable)
make test      # pytest
make run       # redlab --help
make docs      # mkdocs serve
```

## 🧯 Lab Guardrails
- `LAB_OK` env var must be set or hostname matches `*-lab` to run simulations.
- Commands are benign (file/echo/loopback pings). No exploitation code.

## 🧭 Architecture
```mermaid
%%{init: {'theme':'neutral'}}%%
flowchart TD
  A[Operator] --> B[redlab CLI]
  B --> C[Recon Sim]
  B --> D[Lateral Sim (benign)]
  C --> E[Sample Logs]
  D --> E
  E --> F[Detections (KQL/Sigma)]
  F --> G[Docs & Reports]
```

## 🗺️ ATT&CK Coverage (examples)
| Tactic | Technique | Where |
|---|---|---|
| Discovery | T1046 Network Service Discovery | `recon.py`, detections |
| Lateral Movement | T1021 Remote Services *(simulated)* | `lateral.py`, docs |

## 🔐 Security & Compliance
See [SECURITY.md](SECURITY.md). The project maps examples to **MITRE ATT&CK** and demonstrates a responsible workflow.

## 📄 License
MIT © 2025 Alex Curtis


## Sentinel Rule Pack
A ready-to-import **Microsoft Sentinel** analytic rule pack lives in `detections/sentinel/`. Each YAML rule includes a KQL query (also provided under `detections/sentinel/queries/`) and is mapped to MITRE ATT&CK techniques for interview-ready demonstrations.
