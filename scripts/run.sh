#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

export TRADE_SOURCE="${TRADE_SOURCE:-data/trades.json}"

mix run --no-halt
