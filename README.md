# TradeMonitor

**TradeMonitor** is an Elixir application designed to monitor financial trades and ensure fault tolerance in a trading system. The application leverages Elixir's robust concurrency model and fault tolerance capabilities to handle real-time trade data, detect anomalies, and ensure system resilience.

## Features

- Real-time trade monitoring
- Anomaly detection in trades
- Fault-tolerant worker processes
- Supervision tree for system resilience

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

3. Run the application:
    ```bash
    mix run --no-halt
    ```

## Usage

- The application will start monitoring trades and detecting anomalies in real-time.
- Fault-tolerant worker processes ensure system resilience.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
