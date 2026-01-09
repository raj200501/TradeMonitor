defmodule TradeMonitor.JSON do
  @moduledoc """
  Minimal JSON decoder implemented in pure Elixir.

  Supports objects, arrays, strings, numbers, booleans, and null.
  """

  @whitespace_chars [10, 32, 9, 13]

  @type json ::
          nil
          | boolean()
          | number()
          | binary()
          | [json()]
          | %{optional(binary()) => json()}

  @spec decode(binary()) :: {:ok, json()} | {:error, String.t()}
  def decode(input) when is_binary(input) do
    input
    |> skip_whitespace()
    |> parse_value()
    |> finalize_parse()
  end

  defp finalize_parse({:ok, value, rest}) do
    case rest |> skip_whitespace() do
      "" -> {:ok, value}
      extra -> {:error, "Unexpected trailing content: #{inspect(extra)}"}
    end
  end

  defp finalize_parse({:error, _} = error), do: error

  defp parse_value(<<"\"", rest::binary>>), do: parse_string(rest, [])
  defp parse_value(<<"{", rest::binary>>), do: parse_object(rest, %{})
  defp parse_value(<<"[", rest::binary>>), do: parse_array(rest, [])
  defp parse_value(<<"t", rest::binary>>), do: parse_literal(rest, "rue", true)
  defp parse_value(<<"f", rest::binary>>), do: parse_literal(rest, "alse", false)
  defp parse_value(<<"n", rest::binary>>), do: parse_literal(rest, "ull", nil)
  defp parse_value(<<"-", _::binary>> = input), do: parse_number(input)
  defp parse_value(<<digit, _::binary>> = input) when digit in ?0..?9, do: parse_number(input)
  defp parse_value(<<>>), do: {:error, "Unexpected end of input"}
  defp parse_value(other), do: {:error, "Unexpected token: #{inspect(other)}"}

  defp parse_literal(rest, literal, value) do
    case rest do
      <<^literal::binary, remainder::binary>> -> {:ok, value, remainder}
      _ -> {:error, "Invalid literal"}
    end
  end

  defp parse_string(rest, acc) do
    case rest do
      <<"\"", remainder::binary>> ->
        {:ok, acc |> Enum.reverse() |> IO.iodata_to_binary(), remainder}

      <<"\\", "\"", remainder::binary>> ->
        parse_string(remainder, ["\"" | acc])

      <<"\\", "\\", remainder::binary>> ->
        parse_string(remainder, ["\\" | acc])

      <<"\\", "/", remainder::binary>> ->
        parse_string(remainder, ["/" | acc])

      <<"\\", "b", remainder::binary>> ->
        parse_string(remainder, ["\b" | acc])

      <<"\\", "f", remainder::binary>> ->
        parse_string(remainder, ["\f" | acc])

      <<"\\", "n", remainder::binary>> ->
        parse_string(remainder, ["\n" | acc])

      <<"\\", "r", remainder::binary>> ->
        parse_string(remainder, ["\r" | acc])

      <<"\\", "t", remainder::binary>> ->
        parse_string(remainder, ["\t" | acc])

      <<"\\", "u", rest::binary>> ->
        parse_unicode_escape(rest, acc)

      <<char::utf8, remainder::binary>> ->
        parse_string(remainder, [<<char::utf8>> | acc])

      _ ->
        {:error, "Unterminated string"}
    end
  end

  defp parse_unicode_escape(<<hex::binary-size(4), remainder::binary>>, acc) do
    case Integer.parse(hex, 16) do
      {codepoint, _} ->
        parse_string(remainder, [<<codepoint::utf8>> | acc])

      :error ->
        {:error, "Invalid unicode escape"}
    end
  end

  defp parse_unicode_escape(_rest, _acc), do: {:error, "Invalid unicode escape"}

  defp parse_array(rest, acc) do
    rest = skip_whitespace(rest)

    case rest do
      <<"]", remainder::binary>> -> {:ok, Enum.reverse(acc), remainder}
      _ -> parse_array_values(rest, acc)
    end
  end

  defp parse_array_values(rest, acc) do
    with {:ok, value, remainder} <- parse_value(skip_whitespace(rest)) do
      remainder = skip_whitespace(remainder)

      case remainder do
        <<",", next::binary>> -> parse_array_values(next, [value | acc])
        <<"]", next::binary>> -> {:ok, Enum.reverse([value | acc]), next}
        _ -> {:error, "Invalid array syntax"}
      end
    end
  end

  defp parse_object(rest, acc) do
    rest = skip_whitespace(rest)

    case rest do
      <<"}", remainder::binary>> -> {:ok, acc, remainder}
      _ -> parse_object_pairs(rest, acc)
    end
  end

  defp parse_object_pairs(rest, acc) do
    with {:ok, key, remainder} <- parse_value(skip_whitespace(rest)),
         true <- is_binary(key) do
      remainder = skip_whitespace(remainder)

      case remainder do
        <<":", after_colon::binary>> ->
          with {:ok, value, after_value} <- parse_value(skip_whitespace(after_colon)) do
            after_value = skip_whitespace(after_value)

            case after_value do
              <<",", next::binary>> -> parse_object_pairs(next, Map.put(acc, key, value))
              <<"}", next::binary>> -> {:ok, Map.put(acc, key, value), next}
              _ -> {:error, "Invalid object syntax"}
            end
          end

        _ ->
          {:error, "Expected ':' after object key"}
      end
    else
      false -> {:error, "Object keys must be strings"}
      {:error, reason} -> {:error, reason}
    end
  end

  defp parse_number(input) do
    {number, rest} = take_number(input, "")

    case number do
      "" ->
        {:error, "Invalid number"}

      _ ->
        case Float.parse(number) do
          {value, ""} -> {:ok, value, rest}
          _ -> {:error, "Invalid number"}
        end
    end
  end

  defp take_number(<<char, rest::binary>>, acc)
       when char in ~c"0123456789+-.eE" do
    take_number(rest, acc <> <<char>>)
  end

  defp take_number(rest, acc), do: {acc, rest}

  defp skip_whitespace(<<char, rest::binary>>) when char in @whitespace_chars,
    do: skip_whitespace(rest)

  defp skip_whitespace(rest), do: rest
end
