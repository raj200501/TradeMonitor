# TradeMonitor

**TradeMonitor** is an Elixir application designed to monitor financial trades and detect anomalies with fault-tolerant worker processes. The application ingests trades from JSON/JSONL files, evaluates each trade against configurable rules, and logs anomalies in real time.

## Features

- Real-time trade monitoring from JSON and JSONL sources
- Anomaly detection rules for notional, quantity, symbol allow-listing, and price deviation
- Fault-tolerant worker process with retry semantics
- Supervision tree with ETS-backed trade/anomaly storage
- Deterministic verification workflow

## Requirements

- Elixir ~> 1.11 (OTP 24+ recommended)

## Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/your-username/TradeMonitor.git
    cd TradeMonitor
    ```

2. Install dependencies:
    ```bash
    mix deps.get
    ```

## Verified Quickstart

Run the application with the default dataset:

```bash
./scripts/run.sh
```

Expected behavior:

- Trades are read from `data/trades.json` on an interval.
- Each trade prints a `Trade processed:` message.
- Trades that violate anomaly rules print an `Anomaly detected:` message.

Stop the application with `Ctrl+C` twice.

### Load-test dataset

For a larger dataset, point the monitor at `data/trades_extended.jsonl`:

```bash
TRADE_SOURCE=data/trades_extended.jsonl ./scripts/run.sh
```

## Configuration

TradeMonitor reads configuration from application config with environment variable overrides. See `.env.example` for all supported variables.

| Variable | Purpose | Default |
| --- | --- | --- |
| `TRADE_SOURCE` | Path to JSON/JSONL trades file | `data/trades.json` |
| `ANOMALY_THRESHOLD` | Minimum notional to flag | `1000` |
| `MAX_RETRIES` | Fault-tolerant worker retries | `5` |
| `POLL_INTERVAL_MS` | Trade polling interval | `2000` |
| `ALLOWED_SYMBOLS` | Comma-delimited allow-list | `AAPL,MSFT,TSLA,AMZN,NVDA` |
| `MAX_QUANTITY` | Max share quantity | `10000` |
| `MAX_NOTIONAL` | Max notional value | `25000000` |
| `PRICE_DEVIATION_PCT` | Max deviation from rolling average | `0.15` |

## Verified Verification

The canonical verification command is:

```bash
./scripts/verify.sh
```

This command:

- Fetches dependencies
- Runs formatting checks
- Executes the unit test suite (without starting the full application)
- Executes an integration verification that processes `data/trades.json` and asserts anomalies are detected

## Troubleshooting

- **`Trade source error: ...`** verify `TRADE_SOURCE` points to a readable JSON/JSONL file.
- **Unexpected JSON decoding errors:** ensure the file contains valid JSON arrays or JSONL lines.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
