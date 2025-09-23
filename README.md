# red-team-lab — Safe Red Teaming Lab (Portfolio Ready)

**A safe, portfolio-ready Red Teaming project that demonstrates planning, benign execution, and detection engineering in a controlled lab.**  
Ships a Typer-based CLI for benign simulations, ATT&CK mappings, detections (KQL + Sigma), docs (MkDocs), CI, and a devcontainer.

> ⚠️ **Safety first:** Everything in this repo is intentionally *benign* and includes guardrails to prevent accidental execution on non-lab hosts. Use only in isolated environments you own.

---

## Quick links
- Repo: `https://github.com/qexa/red-team-lab-sentinel`  
- Author / Contact: **Alex Curtis** — https://github.com/qexa  
- License: **MIT © 2025 Alex Curtis**

---

# Overview

Red Team Lab is a demonstration project for red-team simulation + detection engineering. It is designed for portfolio, interviewing, and SOC demo purposes. The repo provides:

- A Typer CLI (`redlab`) to run **benign** recon and lateral simulations
- ATT&CK mapping across code, docs, and detections
- Detections: **KQL** (Microsoft Sentinel) and **Sigma** rules
- A Microsoft Sentinel analytic rule pack (YAML + KQL queries)
- Docs site built with **MkDocs Material**
- Hardened repo hygiene: `SECURITY.md`, `CODE_OF_CONDUCT.md`, GitHub Actions CI
- Dev experience: `Makefile`, `Dockerfile`, and a VS Code `.devcontainer/`
- Tests and linting (`pytest`, `ruff`, `mypy` where applicable)

---

# Features & Intent

- **Safe by default:** Simulations are file/echo/loopback-only and include a gating mechanism (see Lab Guardrails).
- **Interview-ready:** Clear READMEs, ATT&CK mappings, and Sentinel rule pack so you can demonstrate simulation → detection → alert in an interview.
- **Extensible:** Detections live in `detections/` and are easy to adapt for specific log formats.
- **Reproducible:** Devcontainer, Make targets, and CI let others reproduce your environment quickly.

---

# Table of Contents

1. Quick Start
2. Lab Guardrails (must-read)
3. CLI: `redlab` usage
4. Detections & Sentinel Rule Pack
5. MkDocs (docs)
6. Development (Make/venv/devcontainer)
7. Suggested lab topology
8. How to demo this repo in an interview
9. Contributing / Security / License

---

# Quick Start

> Recommended: run this in isolated VMs or a private lab network.

## Option A — Python (standard)
```bash
git clone https://github.com/qexa/red-team-lab-sentinel.git
cd red-team-lab-sentinel

python -m venv .venv
source .venv/bin/activate       # macOS / Linux
# .venv\Scripts\activate      # Windows PowerShell

pip install -e ".[dev]"
redlab --help
```

## Option B — `uv` (faster environment bootstrap, optional)
```bash
# If you use the uv wrapper described in the repo:
uv venv && source .venv/bin/activate
uv pip install -e ".[dev]"
redlab --help
```

## Run a benign simulation
```bash
# Ensure guardrails (see below) are satisfied first
export LAB_OK=1

# Recon simulation (benign)
redlab recon --targets 10.0.0.5,10.0.0.6 --label demo1

# Faux lateral movement trace (benign)
redlab lateral --user alice --host 10.0.0.9 --label demo2
```

---

# Lab Guardrails (READ BEFORE RUNNING)

To prevent accidental execution on production systems, the CLI enforces a guardrail:

- **Either** the `LAB_OK` environment variable must be set (`export LAB_OK=1`)  
- **Or** the system hostname must match the pattern: `*-lab` (for example `alex-lab`).

If neither condition is met the CLI will refuse to execute actions. Simulations are intentionally non-exploitative (file writes, echo, loopback pings, synthetic log generation only).

---

# CLI — `redlab` (summary)

Primary commands (Typer-based):

- `redlab recon --targets <IP,IP> --label <name>`  
  Performs simulated reconnaissance (service discovery shapes), writes synthetic logs/samples.

- `redlab lateral --user <username> --host <IP> --label <name>`  
  Generates synthetic lateral-movement-like traces (benign), suitable for detection testing.

- `redlab --help`  
  See full options, flags, and examples.

All CLI functionality is documented in `docs/` and in the code docstrings (usable with `mkdocs`).

---

# Detections

Detections live in `detections/`:

```
detections/
├─ kql/           # KQL rules for Microsoft Sentinel (single-file and examples)
├─ sigma/         # Sigma rules (YAML) for translating to other SIEMs
└─ sentinel/      # Sentinel analytic rule pack + queries
   └─ queries/    # KQL query files referenced by the Sentinel pack
```

Each detection contains:
- **Rule logic** (KQL or Sigma)
- **Mapping to MITRE ATT&CK** (technique IDs, tactic)
- **Rationale** and expected sample log fields

> Tip: open `detections/kql/` and `detections/sigma/` first — compare field names to the samples produced by `redlab`.

---

# Sentinel Rule Pack (import instructions)

A ready-to-import Microsoft Sentinel analytic rule pack is located in `detections/sentinel/`.

**Quick import steps (manual):**
1. In Azure Portal, open **Microsoft Sentinel** and choose your workspace.
2. Go to **Analytics** → **Create** → **Scheduled query rule** (or use the ARM/YAML if provided).
3. Copy the KQL from `detections/sentinel/queries/<rule>.kql` into the query box.
4. Map the rule metadata (MITRE IDs, severity, tactics) using the YAML rule template.
5. Test by ingesting the synthetic logs generated by `redlab` and verify detection firing.

**Automated import (ARM / CI):** If the repo includes an ARM template / automation script, you can deploy that into a **test** subscription/workspace. Always test in a non-production Azure tenant.

---

# MkDocs — docs site

Start the documentation locally:
```bash
make docs
# or
mkdocs serve
# open http://127.0.0.1:8000
```

Docs show:
- ATT&CK mappings
- How-to run the CLI
- Detection rationales and example matches
- Sentinel rule pack overview

---

# Tests, Linting & Make targets

Use the provided convenience targets:

```bash
make install    # pip install -e ".[dev]"
make lint       # ruff + mypy (if configured)
make test       # pytest -q
make run        # redlab --help
make docs       # mkdocs serve
```

Run tests manually:
```bash
pytest -q
```

---

# Devcontainer & Docker

Open in VS Code with the included `.devcontainer/` to reproduce the development environment exactly (Python version, extensions, preinstalled tools). The Dockerfile provides a reproducible build for CI or local testing.

---

# ATT&CK Coverage (example)

| Tactic            | Technique (ID)                       | Where to find it |
|-------------------|--------------------------------------|------------------|
| Discovery         | Network Service Discovery — **T1046** | `recon.py`, `detections/kql` |
| Lateral Movement  | Remote Services — **T1021**          | `lateral.py`, docs, detections |
| Persistence (demo)| Scheduled Task / Service — **T1053** | docs / detections (example) |

> Full ATT&CK mapping is available in `docs/` and annotated across `detections/` and code comments.

---

# Suggested lab topology

- **Attacker VM** (`alex-lab`) — runs `redlab` to generate synthetic activity and logs.
- **Victim VM(s)** — Windows or Linux instances (isolated), referenced in sample traces.
- **SIEM** — local Elastic / Splunk dev instance, or Microsoft Sentinel workspace in a test subscription.

Keep all VMs NAT'd and isolated from production networks.

---

# How to demo (interview flow)

1. Open README → emphasize **safety guardrails**.
2. Start `mkdocs serve` → show ATT&CK mappings and detection rationale pages.
3. Export `LAB_OK=1` and run: `redlab recon --targets 10.0.0.5 --label demo`
4. Show generated sample logs (explain fields: timestamp, host, user, event_type).
5. Ingest sample logs into SIEM and run a KQL or Sigma rule (from `detections/`) to produce an alert.
6. Show `detections/sentinel/` YAML and explain how to map to production workflows.

This shows simulation → log → detection → alert in a clear, repeatable way.

---

# Troubleshooting

- `redlab` not found: ensure virtualenv is active and `pip install -e ".[dev]"` completed successfully.
- CLI refuses to run: verify `LAB_OK=1` or hostname matches `*-lab`.
- Detection mismatches: compare the sample logs format with the expected field names used in detection rules — adjust mapping or rule field selectors.

---

# Contributing

Contributions are welcome — open an issue or a PR. Please read `CONTRIBUTING.md` beforehand. Keep these principles in mind:

- Preserve safety and non-exploitative intent.
- Add tests for any new detection or simulation.
- Map new features to ATT&CK and document the rationale.

---

# Security & Responsible Use

- See `SECURITY.md` for security policy, disclosure process, and allowed use.
- This project must only be used in environments you own or are explicitly authorized to use for testing.
- Never run the repo against production systems or networks you do not control.

---

# Files of interest (quick nav)

- `README.md` — you are here
- `SECURITY.md` — security policies & guardrails
- `CODE_OF_CONDUCT.md` — community expectations
- `docs/` — MkDocs site
- `redlab/` — CLI code (`recon.py`, `lateral.py`, etc.)
- `detections/` — KQL, Sigma, Sentinel rules
- `.devcontainer/` — VS Code devcontainer
- `Makefile`, `Dockerfile`, `pyproject.toml`, `setup.cfg` / `pyproject` build config
- `.github/workflows/` — CI (lint/test)

---

# License

MIT © 2025 Alex Curtis — https://github.com/qexa

---

If you'd like, I can now:
- Create a downloadable ZIP of the repo with **this README** replaced (and a CHANGELOG), ready for you to push — or
- Open a PR branch in your GitHub (if you authorize) with the README replacement and changelog.
