#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

mix deps.get
mix format --check-formatted
mix test --no-start
mix run -e "TradeMonitor.Verify.run()"
