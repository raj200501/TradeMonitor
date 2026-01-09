defmodule TradeMonitor.TestFixtures do
  @moduledoc false

  def fixture_path(name) do
    Path.join([__DIR__, "fixtures", name])
  end

  def capture_env(app) do
    Application.get_all_env(app)
  end

  def restore_env(app, previous) do
    current_keys = Application.get_all_env(app) |> Keyword.keys()
    previous_keys = Keyword.keys(previous)

    Enum.each(current_keys -- previous_keys, fn key ->
      Application.delete_env(app, key)
    end)

    Enum.each(previous, fn {key, value} ->
      Application.put_env(app, key, value)
    end)
  end
end
