defmodule TradeMonitor.TradeSource do
  @moduledoc """
  Loads trades from JSON or JSONL sources on disk.
  """

  alias TradeMonitor.{JSON, Trade}

  @type load_result :: {:ok, [Trade.t()], [String.t()]} | {:error, String.t()}

  def load(path) when is_binary(path) do
    with {:ok, contents} <- File.read(path),
         {:ok, records} <- decode(contents) do
      parse_records(records)
    else
      {:error, reason} -> {:error, "Failed to load trades: #{inspect(reason)}"}
    end
  end

  defp decode(contents) do
    case JSON.decode(contents) do
      {:ok, list} when is_list(list) -> {:ok, list}
      {:ok, _other} -> {:error, :expected_list}
      {:error, _} -> decode_jsonl(contents)
    end
  end

  defp decode_jsonl(contents) do
    lines =
      contents
      |> String.split("\n", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    decoded =
      Enum.map(lines, fn line ->
        case JSON.decode(line) do
          {:ok, record} -> {:ok, record}
          {:error, reason} -> {:error, "Invalid JSONL line: #{inspect(reason)}"}
        end
      end)

    case Enum.split_with(decoded, &match?({:ok, _}, &1)) do
      {oks, []} ->
        {:ok, Enum.map(oks, fn {:ok, record} -> record end)}

      {_oks, errors} ->
        {:error, Enum.map(errors, fn {:error, reason} -> reason end) |> Enum.join("; ")}
    end
  end

  defp parse_records(records) when is_list(records) do
    {trades, errors} =
      records
      |> Enum.map(&parse_record/1)
      |> Enum.split_with(&match?({:ok, _}, &1))

    parsed = Enum.map(trades, fn {:ok, trade} -> trade end)
    reasons = Enum.map(errors, fn {:error, reason} -> reason end)
    {:ok, parsed, reasons}
  end

  defp parse_record(record) when is_map(record) do
    with {:ok, trade} <- Trade.from_map(record) do
      {:ok, Trade.enrich(trade, record)}
    end
  end

  defp parse_record(_), do: {:error, "Invalid trade record"}
end
