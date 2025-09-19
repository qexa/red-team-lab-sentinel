SHELL := /bin/bash

.PHONY: install dev lint test fmt run docs

install:
	pip install -e ".[dev]"

dev: install
	@echo "Dev env ready. Try: redlab --help"

lint:
	ruff check .

fmt:
	ruff format .

test:
	pytest -q

run:
	redlab --help

docs:
	mkdocs serve -a 0.0.0.0:8000
