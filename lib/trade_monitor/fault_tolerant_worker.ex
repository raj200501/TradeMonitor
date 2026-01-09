defmodule TradeMonitor.FaultTolerantWorker do
  @moduledoc """
  Executes a user-defined process function with retry semantics.
  """

  use GenServer

  @type process_fun :: (any() -> :ok | :error)

  def start_link(opts) do
    initial_value = Keyword.fetch!(opts, :value)
    process_fun = Keyword.get(opts, :process_fun, &default_process/1)

    GenServer.start_link(__MODULE__, {initial_value, process_fun},
      name: Keyword.get(opts, :name, __MODULE__)
    )
  end

  def init({initial_value, process_fun}) do
    max_retries = Application.fetch_env!(:trade_monitor, :max_retries)
    {:ok, %{value: initial_value, retries: 0, max_retries: max_retries, process_fun: process_fun}}
  end

  def process(pid) do
    GenServer.call(pid, :process)
  end

  def handle_call(
        :process,
        _from,
        %{value: value, retries: retries, max_retries: max_retries} = state
      )
      when retries < max_retries do
    case state.process_fun.(value) do
      :ok -> {:reply, :ok, %{state | retries: 0}}
      :error -> {:reply, :error, %{state | retries: retries + 1}}
    end
  end

  def handle_call(:process, _from, state) do
    {:reply, :give_up, state}
  end

  defp default_process(value) do
    IO.puts("Processed value: #{inspect(value)}")
    :ok
  end
end
