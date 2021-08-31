defmodule Eliro do
  @doc """
  Config for Eliro.
  """
  defp config() do
    case File.read("config/eliro.conf") do
      {:ok, body} ->
        String.split(body, ~r/\||[\r\n]/, trim: true)
        |> Enum.chunk_every(2)
        |> Enum.map(fn [a, b] -> {a, b} end)
        |> Map.new()

      {:error, reason} ->
        IO.puts(:stderr, "Error: #{reason}")
    end
  end

  def run do
    #IO.puts(config())
  end
end

Eliro.run()
